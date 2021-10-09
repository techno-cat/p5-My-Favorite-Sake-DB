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

my $product_id = 1;
foreach my $tag ( qw/aaa bbb ccc/ ) {
    my $tag_id = Sake::Tag::insert( $dbh, $tag );
    Sake::ProductsTag::insert( $dbh, {
        product_id => $product_id,
        tag_id => $tag_id
    } );
}

my $productsTags = Sake::ProductsTag::select_all( $dbh );
is scalar(@{$productsTags}), 3;

is $productsTags->[0]->{product_id}, 1;
is $productsTags->[0]->{tag_id}, 1;
is $productsTags->[1]->{tag_id}, 2;

$productsTags = Sake::ProductsTag::select_by( $dbh, { product_id => 1 } );
is scalar(@{$productsTags}), 3;

$productsTags = Sake::ProductsTag::select_by( $dbh, { tag_id => 1 } );
is scalar(@{$productsTags}), 1;

$productsTags = Sake::ProductsTag::select_by( $dbh, { tag_id => 0 } );
is scalar(@{$productsTags}), 0;

$dbh->disconnect;

done_testing;
