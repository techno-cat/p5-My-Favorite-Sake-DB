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

done_testing;
