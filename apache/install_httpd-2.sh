#!/bin/bash
rm -rf httpd-2.4.23 apr-1.5.0 apr-util-1.5.3
if [ ! -f httpd-2.4.23.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/apache/httpd-2.4.23.tar.gz
fi
tar zxvf httpd-2.4.23.tar.gz

if [ ! -f apr-1.5.0.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/apache/apr-1.5.0.tar.gz
fi
tar -zxvf apr-1.5.0.tar.gz
cp -rf apr-1.5.0 httpd-2.4.23/srclib/apr

if [ ! -f apr-util-1.5.3.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/apache/apr-util-1.5.3.tar.gz
fi
tar -zxvf apr-util-1.5.3.tar.gz
cp -rf apr-util-1.5.3 httpd-2.4.23/srclib/apr-util

cd httpd-2.4.23
./configure --prefix=/alidata/server/httpd \
--with-mpm=prefork \
--enable-so \
--enable-rewrite \
--enable-mods-shared=all \
--enable-nonportable-atomics=yes \
--disable-dav \
--enable-deflate \
--enable-cache \
--enable-disk-cache \
--enable-mem-cache \
--enable-file-cache \
--enable-ssl \
--with-included-apr \
--enable-modules=all  \
--enable-mods-shared=all
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cp support/apachectl /etc/init.d/httpd
chmod u+x /etc/init.d/httpd
cd ..

cp /alidata/server/httpd/conf/httpd.conf /alidata/server/httpd/conf/httpd.conf.bak

sed -i "s#LoadModule rewrite_module modules/mod_rewrite.so#LoadModule rewrite_module modules/mod_rewrite.so\nLoadModule php5_module modules/libphp5.so#" /alidata/server/httpd/conf/httpd.conf
sed -i "s#User daemon#User www#" /alidata/server/httpd/conf/httpd.conf
sed -i "s#Group daemon#Group www#" /alidata/server/httpd/conf/httpd.conf
sed -i "s;#ServerName www.example.com:80;ServerName www.example.com:80;" /alidata/server/httpd/conf/httpd.conf
sed -i "s#/alidata/server/httpd/htdocs#/alidata/www#" /alidata/server/httpd/conf/httpd.conf
sed -i "s#<Directory />#<Directory \"/alidata/www\">#" /alidata/server/httpd/conf/httpd.conf
sed -i "s#AllowOverride None#AllowOverride all#" /alidata/server/httpd/conf/httpd.conf
sed -i "s#DirectoryIndex index.html#DirectoryIndex index.html index.htm index.php#" /alidata/server/httpd/conf/httpd.conf
sed -i "s;#Include conf/extra/httpd-mpm.conf;Include conf/extra/httpd-mpm.conf;" /alidata/server/httpd/conf/httpd.conf
sed -i "s;#Include conf/extra/httpd-vhosts.conf;Include conf/extra/httpd-vhosts.conf;" /alidata/server/httpd/conf/httpd.conf

echo "HostnameLookups off" >> /alidata/server/httpd/conf/httpd.conf
echo "AddType application/x-httpd-php .php" >> /alidata/server/httpd/conf/httpd.conf

#echo "NameVirtualHost *:80" > /alidata/server/httpd/conf/extra/httpd-vhosts.conf
echo "Include /alidata/vhosts/*.conf" >> /alidata/server/httpd/conf/extra/httpd-vhosts.conf




#adjust httpd-mpm.conf
sed -i 's/StartServers          5/StartServers         10/g' /alidata/server/httpd/conf/extra/httpd-mpm.conf
sed -i 's/MinSpareServers       5/MinSpareServers      10/g' /alidata/server/httpd/conf/extra/httpd-mpm.conf
sed -i 's/MaxSpareServers      10/MaxSpareServers      30/g' /alidata/server/httpd/conf/extra/httpd-mpm.conf
sed -i 's/MaxClients          150/MaxClients          255/g' /alidata/server/httpd/conf/extra/httpd-mpm.conf

#/etc/init.d/httpd-3 start

cat > /alidata/vhosts/default.conf << END
<DirectoryMatch "/alidata/www/default/(attachment|html|data)">
<Files ~ ".php">
Order allow,deny
Deny from all
</Files>
</DirectoryMatch>

<VirtualHost *:80>
	DocumentRoot /alidata/www/default
	ServerName localhost
	ServerAlias localhost
	<Directory "/alidata/www/default">
	    Options Indexes FollowSymLinks
	    AllowOverride all
	    Order allow,deny
	    Allow from all
	</Directory>
	ErrorLog "/alidata/log/httpd/phpwind-error.log"
	CustomLog "/alidata/log/httpd/phpwind.log" common
</VirtualHost>
END



