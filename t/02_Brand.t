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

my $brewery_id = 1;

my $brand_id = Sake::Brand::insert( $dbh, {
    brewery_id => $brewery_id,
    name => 'foo',
    kana => 'ふー',
    url => 'http://foo.jp/'
} );
is $brand_id, 1;

$brand_id = Sake::Brand::insert( $dbh, {
    brewery_id => $brewery_id,
    name => 'bar',
    kana => 'ばー',
    url => 'http://bar.jp/'
} );
is $brand_id, 2;

my $brands = Sake::Brand::select_all( $dbh );
is scalar(@{$brands}), 2;

is $brands->[0]->{brand_id}, 1;
is $brands->[0]->{brewery_id}, 1;
is $brands->[0]->{name}, 'foo';
is $brands->[0]->{kana}, 'ふー';
is $brands->[0]->{url}, 'http://foo.jp/';

$brands = Sake::Brand::select_by( $dbh, { brewery_id => 1 } );
is scalar(@{$brands}), 2;

$brands = Sake::Brand::select_by( $dbh, { name => 'bar' } );
is scalar(@{$brands}), 1;
is $brands->[0]->{name}, 'bar';

$brands = Sake::Brand::select_by( $dbh, { brewery_id => 1, name => 'bar' } );
is scalar(@{$brands}), 1;

$brands = Sake::Brand::select_by( $dbh, { brewery_id => 2, name => 'bar' } );
is scalar(@{$brands}), 0;

$dbh->disconnect;

done_testing;
