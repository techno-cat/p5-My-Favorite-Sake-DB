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

    my $brewery = $fav->{brewery};
    my $brewery_id = Sake::Brewery::insert( $dbh, $brewery );

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

while (my $row = $sth->fetch()) {
    my ( $kura, $b_name, $b_kana, $sake_name ) = @{$row};

    say "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";
    say $kura;
    say "  ${b_name}（${b_kana}）";
    say "  - ", $sake_name;
}
say "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";

$dbh->disconnect;

say 'done!';
