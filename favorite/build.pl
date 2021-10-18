use strict;
use warnings;
use v5.10;
use lib '../lib';

use Sake::DB;

my $db_file = 'sake.db';
if ( @ARGV ) {
    my $arg = $ARGV[0];
    if ( $arg !~ /.+\.db$/ ) {
        die "warn ${arg}";
    }

    $db_file = $arg;
}

Sake::DB::init( $db_file );

die "${db_file} not found." if not (-e $db_file);

my $dbh = DBI->connect("dbi:SQLite:dbname=${db_file}");

my @files = glob './src/*.pl';
foreach my $file ( @files ) {
    say $file;
    my $fav = do $file;

    # 銘柄ごとにファイルを分けているので酒造が同じ場合がある
    my $brewery_id = select_brewery_id( $dbh, $fav->{brewery} );
    if ( not defined($brewery_id) ) {
        $brewery_id = Sake::Brewery::insert( $dbh, $fav->{brewery} );
    }

    my $brand = $fav->{brand};
    $brand->{brewery_id} = $brewery_id;
    my $brand_id = Sake::Brand::insert( $dbh, $brand );

    foreach my $product ( @{$fav->{products}} ) {
        $product->{brand_id} = $brand_id;
        Sake::Product::insert( $dbh, $product );
    }
}

my $sql = <<SQL;
SELECT kura.name, b.name, b.kana, sake.name from t_products sake
    JOIN t_brands b ON sake.brand_id = b.brand_id
    JOIN t_breweries kura ON b.brewery_id = kura.brewery_id;
SQL

my $sth = $dbh->prepare( $sql );
$sth->execute() or die(DBI::errstr);

my @fav_list = ();
while (my $row = $sth->fetch()) {
    my ( $kura, $b_name, $b_kana, $sake_name ) = @{$row};

    push @fav_list, +{
        kura => $kura,
        b_name => $b_name,
        b_kana => $b_kana,
        sake_name => $sake_name
    };
}

$dbh->disconnect;

while ( @fav_list ) {

    my $fav = $fav_list[0];
    my @tmp = ();
    my @new_fav_list = ();
    foreach ( @fav_list ) {
        if ( $fav->{kura} eq $_->{kura} and $fav->{b_name} eq $_->{b_name} ) {
            push @tmp, $_;
        }
        else {
            push @new_fav_list, $_;
        }
    }

    @fav_list = @new_fav_list;

    say "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";
    say $fav->{kura};
    say "  " . $fav->{b_name} . "（" . $fav->{b_kana} . "）";
    foreach ( @tmp ) {
        say "  - ", $_->{sake_name};
    }
}
say "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";
say 'done!';

sub select_brewery_id {
    my ( $dbh, $brewery ) = @_;

    my $breweries = Sake::Brewery::select_by( $dbh, $brewery );
    return @{$breweries} ? $breweries->[0]->{brewery_id} : undef;
}
