use strict;
use Test::More 0.98;
use lib './lib';
use File::Temp qw/tempdir/;

use Sake::DB;

my $tmp_dir = tempdir ( DIR => '.', CLEANUP => 1 );
my $db_file = "./${tmp_dir}/test.db";

Sake::DB::init( $db_file );
ok (-e $db_file);

my $dbh = DBI->connect("dbi:SQLite:dbname=${db_file}");

foreach my $tag ( qw/aaa bbb ccc/ ) {
    Sake::Tag::insert( $dbh, $tag );
}

my $tags = Sake::Tag::select_all( $dbh );
is scalar(@{$tags}), 3;

is $tags->[0]->{tag_id}, 1;
is $tags->[0]->{tag}, 'aaa';
is $tags->[1]->{tag_id}, 2;

$tags = Sake::Tag::select_by( $dbh, { tag_id => 1 } );
is scalar(@{$tags}), 1;
is $tags->[0]->{tag}, 'aaa';

$tags = Sake::Tag::select_by( $dbh, { tag_id => 0 } );
is scalar(@{$tags}), 0;

$tags = Sake::Tag::select_by_tags( $dbh, [ 'bbb', 'ccc' ] );
is scalar(@{$tags}), 2;
ok grep( { $_->{tag} eq 'bbb' } @{$tags} );
ok grep( { $_->{tag} eq 'ccc' } @{$tags} );

$tags = Sake::Tag::select_by_tags( $dbh, [ 'ccc', 'ddd' ] );
is scalar(@{$tags}), 1;
is $tags->[0]->{tag}, 'ccc';

$dbh->disconnect;

done_testing;
