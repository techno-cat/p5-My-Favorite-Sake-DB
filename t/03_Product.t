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

my $brand_id = 1;

my $product_id = Sake::Product::insert( $dbh, {
    brand_id => $brand_id,
    name => 'foo',
    comment => 'ふー',
    memo => 'メモ',
    updated_date => '2021/10/09'
} );
is $product_id, 1;

$product_id = Sake::Product::insert( $dbh, {
    brand_id => $brand_id,
    name => 'bar',
    comment => 'ばー',
    memo => 'メモ',
    updated_date => '2021/10/09'
} );
is $product_id, 2;

my $products = Sake::Product::select_all( $dbh );
is scalar(@{$products}), 2;

is $products->[0]->{product_id}, 1;
is $products->[0]->{brand_id}, 1;
is $products->[0]->{name}, 'foo';
is $products->[0]->{comment}, 'ふー';
is $products->[0]->{memo}, 'メモ';
is $products->[0]->{updated_date}, '2021/10/09';

$products = Sake::Product::select_by( $dbh, { brand_id => 1 } );
is scalar(@{$products}), 2;

$products = Sake::Product::select_by( $dbh, { name => 'bar' } );
is scalar(@{$products}), 1;
is $products->[0]->{name}, 'bar';

$products = Sake::Product::select_by( $dbh, { brand_id => 1, name => 'bar' } );
is scalar(@{$products}), 1;

$products = Sake::Brand::select_by( $dbh, { brand_id => 2, name => 'bar' } );
is scalar(@{$products}), 0;

$dbh->disconnect;

done_testing;
