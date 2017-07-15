#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/alidata/server/mysql/bin:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin:/root/bin

dbrootpwd=`awk -F:  '/mysql/ {print $2}' /alidata/account.log`
CPU=`grep -o "cpu cores" /proc/cpuinfo |wc -l`
Swap=`free -m | awk '/Swap:/{print $2}'`
Mem=`free -m | awk '/Mem:/{print $2}'`
Mysql_dir=/alidata/server/mysql
Nginx_dir=/alidata/server/nginx
PHP_dir=/alidata/server/php
Apache_dir=/alidata/server/httpd

if [ $Mem -le 640 ];then
    Mem_level=512M
    Memory_limit=64
elif [ $Mem -gt 640 -a $Mem -le 1280 ];then
    Mem_level=1G
    Memory_limit=128
elif [ $Mem -gt 1280 -a $Mem -le 2500 ];then
    Mem_level=2G
    Memory_limit=192
elif [ $Mem -gt 2500 -a $Mem -le 3500 ];then
    Mem_level=3G
    Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
    Mem_level=4G
    Memory_limit=320
elif [ $Mem -gt 4500 -a $Mem -le 8000 ];then
    Mem_level=6G
    Memory_limit=384
elif [ $Mem -gt 8000 ];then
    Mem_level=8G
    Memory_limit=448
fi

swapfile() {
    dd if=/dev/zero of=/swapfile count=$COUNT bs=1M
    mkswap /swapfile
    swapon /swapfile
    chmod 600 /swapfile
    [ -z "`grep swapfile /etc/fstab`" ] && cat >> /etc/fstab << EOF
/swapfile    swap    swap    defaults    0 0
EOF
}

# add swapfile
if [ "$Swap" == '0' ] ;then
    if [ $Mem -le 1024 ];then
        COUNT=1024
        swapfile
    elif [ $Mem -gt 1024 -a $Mem -le 2048 ];then
        COUNT=2048
        swapfile
    fi
fi

# Check if user is root
[ $(id -u) != "0" ] && { echo "This operation requires root privileges"; exit 1; }

#####-------Nginx---------######
if [ -d "$Nginx_dir" ];then
	service nginx stop &>/dev/null
	sed -i "s@^\(worker_processes\).*@\1  $CPU;"@g /etc/nginx/conf/nginx.conf
	service nginx start
fi



#####-------MySQL---------######
if [ -d "$Mysql_dir/support-files" ];then	
	/etc/init.d/mysqld stop &>/dev/null
        cd /alidata/server/mysql/scripts
	./mysql_install_db  --user=mysql --basedir=/alidata/server/mysql &>/dev/null
	retval=`echo $?`
	if [ "$retval" == '0' ];then
		echo "Database initialization successful"
	else
		echo "Database initialization fails, re-execute the script"
		break
	fi
        \mv /etc/my.cnf /etc/my.cnf.bak
        \cp -a /alidata/init/my.cnf.ori /etc/my.cnf
 
    sed -i "s@max_connections.*@max_connections = $(($Mem/2))@" /etc/my.cnf
    if [ $Mem -le 1500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 8@' /etc/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 8M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 8M@' /etc/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 8M@' /etc/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 64M@' /etc/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 16M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 128@' /etc/my.cnf
    elif [ $Mem -gt 1500 -a $Mem -le 2500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 16M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
    elif [ $Mem -gt 2500 -a $Mem -le 3500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 32M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
    elif [ $Mem -gt 3500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 64M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/my.cnf
    fi
    service mysqld restart > /alidata/log/optimization.log
fi

#####-------PHP---------######
if [ -e "/etc/php/php.ini" ];then
    sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@g" /alidata/server/php-{5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php.ini
    sed -i "s@^opcache.memory_consumption.*@opcache.memory_consumption=$Memory_limit@g" /alidata/server/php-{5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php.ini
fi
if [ -e "/alidata/server/etc/php-fpm.conf" ];then
    if [ $Mem -le 3000 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/3/20))@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/3/30))@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/3/40))@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/3/20))@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
    elif [ $Mem -gt 3000 -a $Mem -le 4500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 50@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 30@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 20@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 50@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
    elif [ $Mem -gt 4500 -a $Mem -le 6500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 60@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 40@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
    elif [ $Mem -gt 6500 -a $Mem -le 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 70@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 50@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 70@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
    elif [ $Mem -gt 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 80@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 60@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@g" /alidata/server/php-{,5.2.17,5.3.29,5.4.23,5.5.7,5.6.8}/etc/php-fpm.conf
    fi
    [ -e "$Apache_dir" ] && service httpd restart || service php-fpm restart
fi

#echo  "Optimization of the operation is complete"

Reset_db_root_password()
{
#sed -i s/'^mysql_password.*'/mysql_password:""/g /alidata/account.log

[ ! -d "$Mysql_dir" ] && { echo "The Database is not installed on your system! "; exit 1; }
while :
do
    echo
    read -p "Please enter a new database password for the root user: " New_dbrootpwd
    [ -n "`echo $New_dbrootpwd | grep '[+|&]'`" ] && { echo "input error,not contain a plus sign (+) and &"; continue; }
    [ ${#New_dbrootpwd} -ge 6 ] && break || echo "database root password least 6 characters! "
done
New_dbrootpwd=$New_dbrootpwd
$Mysql_dir/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h localhost &>/dev/null 
status_Localhost=`echo $?`
$Mysql_dir/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h 127.0.0.1 > /dev/null 2>&1
status_127=`echo $?`

sed -i s/'^mysql_password.*'/mysql_password:""/g /alidata/account.log
if [ $status_Localhost -eq 0 -a $status_127 -eq 0 ]; then
    sed -i s/'^mysql_password.*'/mysql_password:"${New_dbrootpwd}"/g /alidata/account.log
    echo
    echo "Password reset succesfully! "
    echo "The new database password: ${New_dbrootpwd}"
    echo
else
        echo "Reset Database root password failed! "
fi
}
Reset_db_root_password

echo  "Optimization complete! "
