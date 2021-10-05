package Sake::Brewery;
use v5.10;
use strict;
use warnings;

use DBI;

=pod
酒蔵: t_breweries
    brewery_id: INTEGER PRIMARY KEY AUTOINCREMENT
    name: 酒蔵（ex. 猫の酒造）
    kana: 酒蔵（ex. ねこのしゅぞう）
    prefecture: 都道府県（ex. 北海道）
=cut

sub insert {
    my ( $dbh, $params ) = @_;

    my @args = map {
        exists($params->{$_}) ? $params->{$_} : "";
    } qw/name kana prefecture/;

    my $sql = 'INSERT INTO t_breweries(name, kana, prefecture) values(?, ?, ?);';
    my $sth = $dbh->prepare( $sql );
    my $rv = $sth->execute( @args );
    die(DBI::errstr) if $rv != 1;

    $sth = $dbh->prepare( 'SELECT brewery_id FROM t_breweries WHERE rowid = last_insert_rowid();' );
    $sth->execute() or die(DBI::errstr);

    my $row = $sth->fetch();
    return $row->[0];
}

sub select_all {
    my ( $dbh ) = @_;

    my $sql = 'SELECT * FROM t_breweries;';
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

    my $sql = 'SELECT * FROM t_breweries' . $where . ';';
    my $sth = $dbh->prepare( $sql );
    $sth->execute(map { $params->{$_}; } @columns) or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub _fetch_all {
    my $sth = shift;

    my @columns = qw/brewery_id name kana prefecture/;
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