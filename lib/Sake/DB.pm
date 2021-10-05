package Sake::DB;
use v5.10;
use strict;
use warnings;

our $VERSION = "0.01";

use Sake::Brewery;
use Sake::Brand;
use Sake::Product;
use Sake::Tag;
use Sake::ProductsTag;

use DBI;
use DBD::SQLite;

my $create_breweries = <<SQL;
CREATE TABLE t_breweries (
    brewery_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    kana TEXT,
    prefecture TEXT);
SQL
my $create_brands = <<SQL;
CREATE TABLE t_brands (
    brand_id INTEGER PRIMARY KEY AUTOINCREMENT,
    brewery_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    kana TEXT,
    url TEXT);
SQL
my $create_products = <<SQL;
CREATE TABLE t_products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    comment TEXT,
    memo TEXT,
    updated_date TEXT NOT NULL);
SQL
my $create_tags = <<SQL;
CREATE TABLE t_tags (
    tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tag TEXT UNIQUE NOT NULL);
SQL
my $create_products_tags = <<SQL;
CREATE TABLE t_products_tags (
    product_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL);
SQL

my @create_sql_list = (
    $create_breweries,
    $create_brands,
    $create_products,
    $create_tags,
    $create_products_tags
);

sub init {
    my $db_file = shift;

    unlink $db_file if (-e $db_file);

    my @create_sql_sections = qw(
        create_breweries_table
        create_brands_table
        create_products_table
        create_tags_table
        create_products_tags_table
    );

    my $dbh = DBI->connect("dbi:SQLite:dbname=${db_file}");

    foreach my $sql ( @create_sql_list ) {
        $dbh->do($sql) or die(DBI::errstr);
    }

    $dbh->disconnect;
}

1;

__END__

=encoding utf-8
=head1 NAME
Sake::DB - Sake Database
=head1 SYNOPSIS
    use Sake::DB;

    # Create empty DB file.
    my $db_file = 'sake.db';
    Sake::DB::init( $db_file );

    $inserted_brewery_id = Sake::Brewery::insert( $dbh, {
        name => '...',
        kana => '...',
        prefecture => '...'
    } );

    $breweries = Sake::Brewery::select_all( $dbh );
    $breweries = Sake::Brewery::select_by( $dbh, {
        name => '...',
        prefecture => '...'
    } );

    foreach my $b ( @{$breweries} ) {
        my @tmp = map { $b->{$_}; } qw/brewery_id name kana prefecture/;
        say join('|', @tmp);
    }
=head1 DESCRIPTION
    Table description

    酒蔵: t_breweries
        brewery_id: INTEGER PRIMARY KEY AUTOINCREMENT
        name: 酒蔵（ex. 猫の酒造）
        kana: 酒蔵（ex. ねこのしゅぞう）
        prefecture: 都道府県（ex. 北海道）

    銘柄: t_brands
        brand_id: INTEGER PRIMARY KEY AUTOINCREMENT
        brewery_id: 酒蔵ID
        name: 銘柄（ex. 猫のお酒）
        kana: 銘柄（ex. ねこのおさけ）
        url: URL（ex. http://neko-no-osake.jp/）

    商品: t_products
        product_id: INTEGER PRIMARY KEY AUTOINCREMENT
        brand_id: 銘柄ID
        name: 純米酒
        comment: 感想
        memo: メモ
        updated_date: 更新日

    タグ: t_tags
        tag_id: INTEGER PRIMARY KEY AUTOINCREMENT
        tag: タグ（ex. 純米酒, 山廃）

    商品に関連付けられたタグ: t_products_tags
        product_id: 商品ID
        tag_id: タグID
=head1 LICENSE
Copyright (C) neko.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
=head1 AUTHOR
neko E<lt>techno.cat.miau@gmail.comE<gt>
=cut
