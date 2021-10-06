use strict;
use Test::More 0.98;
use lib './lib';
use File::Temp qw/tempdir cleanup/;

use_ok $_ for qw(
    Sake::DB
);

my $tmp_dir = tempdir ( DIR => '.', CLEANUP => 1 );
my $db_file = "./${tmp_dir}/test.db";

Sake::DB::init( $db_file );
ok (-e $db_file);

my $dbh = DBI->connect("dbi:SQLite:dbname=${db_file}");

my $brewery_id = Sake::Brewery::insert( $dbh, {
    name => 'foo',
    kana => 'ふー',
    prefecture => 'hoge'
} );
is $brewery_id, 1;

$brewery_id = Sake::Brewery::insert( $dbh, {
    name => 'bar',
    kana => 'ばー',
    prefecture => 'fuga'
} );
is $brewery_id, 2;

my $breweries = Sake::Brewery::select_all( $dbh );
is scalar(@{$breweries}), 2;

is $breweries->[0]->{brewery_id}, 1;
is $breweries->[0]->{name}, 'foo';
is $breweries->[0]->{kana}, 'ふー';
is $breweries->[0]->{prefecture}, 'hoge';

is $breweries->[1]->{brewery_id}, 2;

$breweries = Sake::Brewery::select_by( $dbh, { brewery_id => 1 } );
is scalar(@{$breweries}), 1;
is $breweries->[0]->{name}, 'foo';

$breweries = Sake::Brewery::select_by( $dbh, { name => 'bar' } );
is scalar(@{$breweries}), 1;
is $breweries->[0]->{name}, 'bar';

$breweries = Sake::Brewery::select_by( $dbh, { kana => 'bar' } );
is scalar(@{$breweries}), 0;

$breweries = Sake::Brewery::select_by( $dbh, { name => 'bar', prefecture => 'fuga' } );
is scalar(@{$breweries}), 1;

$breweries = Sake::Brewery::select_by( $dbh, { name => 'bar', prefecture => 'hoge' } );
is scalar(@{$breweries}), 0;

$dbh->disconnect;

done_testing;
