package Sake::ProductsTag;
use v5.10;
use strict;
use warnings;

use DBI;

=pod
商品に関連付けられたタグ: t_products_tags
    product_id: 商品ID
    tag_id: タグID
=cut

sub insert {
    my ( $dbh, $params ) = @_;

    die if not exists($params->{product_id});
    die if not exists($params->{tag_id});

    my @args = map {
        exists($params->{$_}) ? $params->{$_} : "";
    } qw/product_id tag_id/;

    my $sql = 'INSERT INTO t_products_tags(product_id, tag_id) values(?, ?);';
    my $sth = $dbh->prepare( $sql );
    my $rv = $sth->execute( @args );
    die(DBI::errstr) if $rv != 1;
}

sub select_all {
    my ( $dbh ) = @_;

    my $sql = 'SELECT * FROM t_products_tags;';
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

    my $sql = 'SELECT * FROM t_products_tags' . $where . ';';
    my $sth = $dbh->prepare( $sql );
    $sth->execute(map { $params->{$_}; } @columns) or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub _fetch_all {
    my $sth = shift;

    my @columns = qw/product_id tag_id/;
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