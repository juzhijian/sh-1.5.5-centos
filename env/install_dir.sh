#!/bin/bash
userdel www
groupadd www

useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null

mkdir -p /alidata
mkdir -p /alidata/server
mkdir -p /alidata/vhosts
mkdir -p /alidata/www
mkdir -p /alidata/init
mkdir -p /alidata/log
mkdir -p /alidata/log/php

mkdir -p /alidata/log/mysql
mkdir -p /alidata/log/httpd
mkdir -p /alidata/log/httpd/access
chown -R www:www /alidata/log

mkdir -p /alidata/server/mysql5.6
ln -s /alidata/server/mysql5.6 /alidata/server/mysql

mkdir -p /alidata/server/httpd


mkdir -p /alidata/www/default

mkdir -p /alidata/server/php



