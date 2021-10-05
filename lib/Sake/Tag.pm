package Sake::Tag;
use v5.10;
use strict;
use warnings;

use DBI;

=pod
タグ: t_tags
    tag_id: INTEGER PRIMARY KEY AUTOINCREMENT
    tag: タグ（ex. 純米酒, 山廃）
=cut

sub insert {
    my ( $dbh, $tag ) = @_;

    my $sql = 'INSERT INTO t_tags(tag) values(?);';
    my $sth = $dbh->prepare( $sql );
    my $rv = $sth->execute( $tag );
    die(DBI::errstr) if $rv != 1;

    $sth = $dbh->prepare( 'SELECT tag_id FROM t_tags WHERE rowid = last_insert_rowid();' );
    $sth->execute() or die(DBI::errstr);

    my $row = $sth->fetch();
    return $row->[0];
}

sub select_all {
    my ( $dbh ) = @_;

    my $sql = 'SELECT * FROM t_tags;';
    my $sth = $dbh->prepare( $sql );
    $sth->execute() or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub select_by {
    my ( $dbh, $params ) = @_;

    my @columns = keys( %{$params} );
    my @places = map { '?'; } @columns;

    my $where = '';
    if ( @columns ) {
        $where = ' WHERE ' . join( ' AND ', map { $_ . ' = ?'; } @columns );
    }

    my $sql = 'SELECT * FROM t_tags' . $where . ';';
    my $sth = $dbh->prepare( $sql );
    $sth->execute(map { $params->{$_}; } @columns) or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub select_by_tags {
    my ( $dbh, $tags ) = @_;

    my $where = '';
    if ( @{$tags} ) {
        $where = ' WHERE tag IN (' . join( ', ', map { '?'; } @{$tags} ) . ')';
    }

    my $sql = 'SELECT * FROM t_tags' . $where . ';';
    my $sth = $dbh->prepare( $sql );
    $sth->execute(@{$tags}) or die(DBI::errstr);

    return _fetch_all( $sth );
}

sub _fetch_all {
    my $sth = shift;

    my @columns = qw/tag_id tag/;
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