package Sake::Brand;
use v5.10;
use strict;
use warnings;

use DBI;

=pod
銘柄: t_brands
    brand_id: INTEGER PRIMARY KEY AUTOINCREMENT
    brewery_id: 酒蔵ID
    name: 銘柄（ex. 猫のお酒）
    kana: 銘柄（ex. ねこのおさけ）
    url: URL（ex. http://neko-no-osake.jp/）
=cut

sub insert {
    my ( $dbh, $params ) = @_;

    die if not exists($params->{brewery_id});

    my @args = map {
        exists($params->{$_}) ? $params->{$_} : "";
    } qw/brewery_id name kana url/;

    my $sql = 'INSERT INTO t_brands(brewery_id, name, kana, url) values(?, ?, ?, ?);';
    my $sth = $dbh->prepare( $sql );
    my $rv = $sth->execute( @args );
    die(DBI::errstr) if $rv != 1;

    $sth = $dbh->prepare( 'SELECT brand_id FROM t_brands WHERE rowid = last_insert_rowid();' );
    $sth->execute() or die(DBI::errstr);

    my $row = $sth->fetch();
    return $row->[0];
}

sub select_all {
    my ( $dbh ) = @_;

    my $sql = 'SELECT * FROM t_brands;';
    my $sth = $dbh->prepare( $sql );
    $sth->execute() or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub select_by {
    my ( $dbh, $params ) = @_;

    my @columns = keys( %{$params} );
    my $where = '';
    if ( @columns ) {
        $where = ' WHERE ' . join( ' AND ', map { $_ . ' = ?'; } @columns );
    }

    my $sql = 'SELECT * FROM t_brands' . $where . ';';
    my $sth = $dbh->prepare( $sql );
    $sth->execute(map { $params->{$_}; } @columns) or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub _fetch_all {
    my $sth = shift;

    my @columns = qw/beand_id brewery_id name kana url/;
    my @ret = ();
    while (my $row = $sth->fetch()) {
        my $brewery = {};
        for (my $i=0; $i<scalar(@columns); $i++) {
            $brewery->{$columns[$i]} = $row->[$i];
        }

        push @ret, $brewery;
    }

    return \@ret;
}

1;

__END__