# NAME

Sake::DB - 来年も飲みたい日本酒データベース

# SYNOPSIS
    use Sake::DB;

    # Create empty DB file.
    my $db_file = 'sake.db';
    Sake::DB::init( $db_file );

    $inserted_brewery_id = Sake::Brewery::insert( $dbh, {
        name => '...',
        kana => '...',
        prefecture => '...'
    } );

    $inserted_brand_id = Sake::Brand::insert( $dbh, {
        brewery_id => ..., # integer
        name => '...',
        kana => '...',
        url => '...'
    } );

    $inserted_product_id = Sake::Product::insert( $dbh, {
        brand_id => ..., # integer
        name => '...',
        comment => '...',
        memo => '...',
        updated_date => '...' # ex.) '2021/10/02'
    } );

    $inserted_tag_id = Sake::Product::insert( $dbh, '...' );

    Sake::ProductsTag::insert( $dbh, {
        product_id => ..., # integer
        tag_id => ... # integer
    } );
# DESCRIPTION

    酒蔵・銘柄・商品名とそのメモをSQLiteに格納するPerlモジュール

# TABLE DESCRIPTION

## 酒蔵: t_breweries
- brewery_id: INTEGER PRIMARY KEY AUTOINCREMENT
- name: 酒蔵（ex. 猫の酒造）
- kana: 酒蔵（ex. ねこのしゅぞう）
- prefecture: 都道府県（ex. 北海道）

## 銘柄: t_brands
- brand_id: INTEGER PRIMARY KEY AUTOINCREMENT
- brewery_id: 酒蔵ID
- name: 銘柄（ex. 猫のお酒）
- kana: 銘柄（ex. ねこのおさけ）
- url: URL（ex. http://neko-no-osake.jp/）

## 商品: t_products
- product_id: INTEGER PRIMARY KEY AUTOINCREMENT
- brand_id: 銘柄ID
- name: 純米酒
- comment: 感想
- memo: メモ
- updated_date: 更新日

## タグ: t_tags
- tag_id: INTEGER PRIMARY KEY AUTOINCREMENT
- tag: タグ（ex. 純米酒, 山廃）

## 商品に関連付けられたタグ: t_products_tags
- product_id: 商品ID
- tag_id: タグID

# LICENSE

Copyright (C) neko.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

neko <techno.cat.miau@gmail.com>