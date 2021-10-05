package Sake::Product;
use v5.10;
use strict;
use warnings;

use DBI;

=pod
商品: t_products
    product_id: INTEGER PRIMARY KEY AUTOINCREMENT
    brand_id: 銘柄ID
    name: 純米酒
    comment: 感想
    memo: メモ
    updated_date: 更新日
=cut

sub insert {
    my ( $dbh, $params ) = @_;

    die if not exists($params->{brand_id});

    my @args = map {
        exists($params->{$_}) ? $params->{$_} : "";
    } qw/brand_id name comment memo updated_date/;

    my $sql = 'INSERT INTO t_products(brand_id, name, comment, memo, updated_date) values(?, ?, ?, ?, ?);';
    my $sth = $dbh->prepare( $sql );
    my $rv = $sth->execute( @args );
    die(DBI::errstr) if $rv != 1;

    $sth = $dbh->prepare( 'SELECT product_id FROM t_products WHERE rowid = last_insert_rowid();' );
    $sth->execute() or die(DBI::errstr);

    my $row = $sth->fetch();
    return $row->[0];
}

sub select_all {
    my ( $dbh ) = @_;

    my $sql = 'SELECT * FROM t_products;';
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

    my $sql = 'SELECT * FROM t_products' . $where . ';';
    my $sth = $dbh->prepare( $sql );
    $sth->execute(map { $params->{$_}; } @columns) or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub _fetch_all {
    my $sth = shift;

    my @columns = qw/product_id brand_id name comment memo updated_date/;
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