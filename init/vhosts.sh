#!/bin/bash
#Description:Management Vhosts
#

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/alidata/server/mysql/bin:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin:/root/bin
run_user=www

nginx_install_dir=/alidata/server/nginx
apache_install_dir=/alidata/server/httpd
mysql_install_dir=/alidata/server/mysql
php_install_dir=/alidata/server/php

nginx_log_dir=/alidata/log/nginx
apache_log_dir=/alidata/log/apache
mysql_log_dir=/alidata/log/mysql
php_log_dir=/alidata/log/php

mysql_data_dir=/alidata/server/mysql/data
wwwroot_dir=/alidata/www
wwwlogs_dir=/alidata/log


##########----------function----------##########
Usage (){
printf "	   
Usage: $0 [ add|del ]
add      -->add virtual hosts
del      -->del virtual hosts
"
}

Add_domain() {
#while  [ 1 ]
# do
#	echo 'Please,Select the type of vhost:(default: " 1. DOMAIN ")'
#	cat <<EOF
#	1. DOMAIN
#	2. PORT
#	3. IP
#EOF
#read -p "Please,Enter your option:" type
#[ -z "$type" ] && type=1
#        if [[ ! $type =~ ^[1-3]$ ]];then
#            echo "input error! Please only input number 1,2,3"
#        else
#            break
#        fi
#done

#	echo $type

if [  -e "$nginx_install_dir/sbin/nginx" -o -e "$apache_install_dir/bin/apachectl" ];then
 while true
  do
    read -p "Please input domain(example: www.jiagouyun.com): " domain
    if [ -z "`echo $domain | grep '.*\..*'`" ]; then
        echo "input formt error!"
    else
        break;
    fi
 done
fi

# if [ -e "$nginx_install_dir/conf/vhosts/${domain}.conf" -o -e "/alidata/vhosts/${domain}.conf" ]; then
   # [ -e "$nginx_install_dir/conf/vhosts/${domain}.conf" ] && echo -e "$domain in the Nginx already exist! \nYou can delete $nginx_install_dir/conf/vhosts/${domain}.conf and re-create"
   # [ -e "/alidata/vhosts/$domain.conf" ] && echo -e "$domain in the Apache already exist! \nYou can delete /alidata/vhosts/${domain}.conf and re-create"
    # exit 2;
# else
    # echo "domain=$domain"
# fi

# while true
# do
        # read -p "Please enter the configuration file name(example: test ) : " conf
		# if [  -z "$conf" ]; then
			# echo "configuration file name can't be NULL! "
		# else
			# conf=$conf
			# break;
		# fi
# done


if [ -e "$nginx_install_dir/conf/vhosts/${domain}:${PORT}.conf" -o -e "/alidata/vhosts/${domain}:${PORT}.conf" ]; then
   [ -e "$nginx_install_dir/conf/vhosts/${domain}:${PORT}.conf" ] && echo -e "$conf in the Nginx already exist! \nYou can delete $nginx_install_dir/conf/vhosts/${domain}:${PORT}.conf and re-create"
   [ -e "/alidata/vhosts/${domain}:${PORT}.conf" ] && echo -e "$conf in the Apache already exist! \nYou can delete /alidata/vhosts/${domain}:${PORT}.conf and re-create"
    exit 2;
else
    echo "domain=$domain:$PORT"
fi


# while [ 1 ]
# do
    # read -p "Do you want to add alias? [y/n]: " moredomainame_yn
    # if [[ ! "$moredomainame_yn"  =~ ^[y,n]$ ]];then
        # echo "input error! Please only input 'y' or 'n'"
    # else
        # break;
    # fi
# done

# if [ "$moredomainame_yn" == 'y' ]; then
    # while :; do echo
        # read -p "Type domain alias:(example: www.jiagouyun.com ): " moredomain
        # if [ -z "`echo $moredomain | grep '.*\..*'`" ]; then
            # echo "input error! "
        # else
            # [ "$moredomain" == "$domain" ] && echo "Domain name already exists!" && continue
            # echo domain list="$moredomain"
            # moredomainame=" $moredomain"
            # break
        # fi
    # done
# fi
    # Apache_Domain_alias=ServerAlias${moredomainame}

# while  [ 1 ]
# do
    # read -p "Do you want to add vhostis base on ip? [y/n]: " base_on_ip_yn
    # if [[ ! $base_on_ip_yn =~ ^[y,n]$ ]];then
        # echo "input error! Please only input 'y' or 'n'"
    # else
        # break;
    # fi
# done

# if [ "$base_on_ip_yn" == 'y' ]; then
    # while :; do echo
        # read -p "Type of vhosts base on IP(example: 100.74.254.11): " IP
        # if [ -z "`echo "$IP" |grep --color -E [1-9]+\.[1-9]+\.[0-9]+\.[0-9]+`" ]; then
            # echo "input error! "
        # else
            # break
        # fi
    # done
# fi
# echo IP=$IP

while [ 1 ]
do
    read -p "Do you want to add port based virtual hosts?? [y/n]: " base_on_port_yn
    if [[ ! $base_on_port_yn =~ ^[y,n]$ ]];then
        echo "input error! Please only input 'y' or 'n'"
    else
        break;
    fi
done
if [ $base_on_port_yn = "y" ];then 
   read -p "Please enter a virtual host port(example: 8080 default:80):" PORT
   [ -z "$PORT" ] && PORT=80
   echo PORT=$PORT
  else
PORT=80
    echo PORT=80
fi

while :; do echo
    echo "Please input the directory for the domain:${domain}:${PORT} :"
    read -p "(Default directory: $wwwroot_dir/${domain}:${PORT}): " vhostdir
    if [ -n "$vhostdir" -a -z "`echo $vhostdir | grep '^/'`" ];then
        echo "input error! Press Enter to continue..."
    else
        if [ -z "$vhostdir" ]; then
            vhostdir="$wwwroot_dir/${domain}:${PORT}"
            echo "Virtual Host Directory=$vhostdir"
        fi
        echo
        echo "Create Virtul Host directory......"
        mkdir -p $vhostdir
        echo "set permissions of Virtual Host directory......"
        chown -R ${run_user}.$run_user $vhostdir
        break
    fi
done
}

Nginx_log () {
while :; do echo
    read -p "Allow Nginx access_log? [y/n]: " access_yn
    if [[ ! $access_yn =~ ^[y,n]$ ]];then
        echo "input error! Please only input 'y' or 'n'"
    else
        break
    fi
done
if [ "$access_yn" == 'n' ]; then
    N_log="access_log off;"
else
    N_log="access_log $wwwlogs_dir/${domain}_nginx.log combined;"
    echo "You access log file=$wwwlogs_dir/${domain}_nginx.log"
fi
}

Apache_log() {
while :; do echo
    read -p "Allow Apache access_log? [y/n]: " access_yn
    if [[ ! "$access_yn" =~ ^[y,n]$ ]];then
        echo "input error! Please only input 'y' or 'n'"
    else
        break
    fi
done

if [ "$access_yn" == 'n' ]; then
    A_log='CustomLog "/dev/null" common'
else
    A_log="CustomLog \"$wwwlogs_dir/${domain}:${PORT}_apache.log\" common"
    echo "You access log file=$wwwlogs_dir/${domain}:${PORT}_apache.log"
fi
}

Create_apache_conf() {
[ ! -d /alidata/vhosts ] && mkdir -p /alidata/vhosts
cat > /alidata/vhosts/${domain}:${PORT}.conf << EOF
Listen $PORT
<VirtualHost *:$PORT>
    DocumentRoot "$vhostdir"
    ServerName $domain 
    ErrorLog "$wwwlogs_dir/${domain}:${PORT}_error_apache.log"
    $A_log
<Directory "$vhostdir">
    SetOutputFilter DEFLATE
    Options FollowSymLinks ExecCGI
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

grep -o --color "Listen $PORT$" &>/dev/null /alidata/server/httpd/conf/httpd.conf
if [ $? -ne 0 ];then 
	sed -i "/Listen 80$/a  Listen $PORT" /alidata/server/httpd/conf/httpd.conf
fi
echo
$apache_install_dir/bin/apachectl -t
if [ $? == 0 ];then
    echo "Restart Apache......"
    /etc/init.d/httpd restart
else
    rm -rf /alidata/vhosts/${domain}:${PORT}.conf
    echo "Create virtualhost ... [FAILED]"
    exit 1;
fi

echo Domain: ${domain}:${PORT}
echo Virtualhost conf: /alidata/vhosts/${domain}:${PORT}.conf
echo Web Directory: $vhostdir 
}

Create_nginx_conf() {
[ ! -d $nginx_install_dir/conf/vhosts ] && mkdir -p $nginx_install_dir/conf/vhosts
cat > $nginx_install_dir/conf/vhosts/$domain.conf << EOF
server {
listen $PORT;
server_name $domain $IP $moredomainame;
$N_log
index index.html index.htm index.php;
root $vhostdir;
location / {
        index  index.html index.htm;
    }

location ~ .*\.(php|php5)?$
        {
                fastcgi_pass  127.0.0.1:9000;
                fastcgi_index index.php;
                include fastcgi.conf;
        }

location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
        {
                expires 30d;
        }

location ~ .*\.(js|css)?$
        {
                expires 1h;
        }
}
EOF

echo
$nginx_install_dir/sbin/nginx -t
if [ $? == 0 ];then
    echo "Reload Nginx......"
    $nginx_install_dir/sbin/nginx -s reload
else
    rm -rf $nginx_install_dir/conf/vhosts/$domain.conf
    echo "Create virtualhost ... [FAILED]"
fi
 
echo Your domain:$domain
echo Nginx Virtualhost conf:$nginx_install_dir/conf/vhosts/${domain}.conf
}


Add_Vhost() {
    if [ -e "$nginx_install_dir/sbin/nginx" -a ! -e "$apache_install_dir/conf/httpd.conf" ];then
        Add_domain
        Nginx_log
        Create_nginx_conf
    elif [ ! -e "$nginx_install_dir/sbin/nginx" -a -e "$apache_install_dir/conf/httpd.conf" ];then
        Add_domain
        Apache_log
        Create_apache_conf
    fi
}

Del_Nginx_Vhost() {
    if [ -e "$nginx_install_dir/sbin/nginx" ];then
        [ -d "$nginx_install_dir/conf/vhosts" ] && Domain_List=`ls $nginx_install_dir/conf/vhosts`
        if [ -n "$Domain_List" ];then
            echo
            echo "Virtualhost list:"
        echo $Domain_List
            while :; do echo
                read -p "Please input a domain you want to delete: " domain
                if [ -z "`echo $domain | grep '.*\..*'`" ]; then
                    echo "input error!"
                else
                    if [ -e "$nginx_install_dir/conf/vhosts/${domain}.conf" ];then
                        Directory=`grep ^root $nginx_install_dir/conf/vhosts/${domain}.conf | awk -F'[ ;]' '{print $2}'`
                        rm -rf $nginx_install_dir/conf/vhosts/${domain}.conf
                        $nginx_install_dir/sbin/nginx -s reload
                        while :; do echo
                            read -p "Do you want to delete Virtul Host directory? [y/n]: " Del_Vhost_wwwroot_yn
                            if [[ ! $Del_Vhost_wwwroot_yn =~ ^[y,n]$ ]];then
                                echo "input error! Please only input 'y' or 'n'"
                            else
                                break
                            fi
                        done
                        if [ "$Del_Vhost_wwwroot_yn" == 'y' ];then
                            echo "Press any key to continue..."
                            rm -rf $Directory
                        fi
                        echo "Domain: ${domain} has been deleted."
                    else
                        echo "Virtualhost: $domain was not exist! "
                    fi
                    break
                fi
            done

        else
            echo "Virtualhost was not exist! "
        fi
    fi
}

Del_Apache_Vhost() {
    if [ -e "$apache_install_dir/conf/httpd.conf" ];then
        if [ -e "$nginx_install_dir/sbin/nginx" ];then
            rm -rf $apache_install_dir/conf/vhosts/${conf}.conf
            /etc/init.d/httpd restart
        else
            Domain_List=`ls /alidata/vhosts/`
            if [ -n "$Domain_List" ];then
                echo
                echo "Virtualhost list:"
                echo $Domain_List
                while :; do echo
                    read -p "Please input a domain you want to delete: " domain
                    if [ -z "`echo $domain | grep '.*\..*'`" ]; then
                        echo "input error! "
                    else
                        if [ -e "/alidata/vhosts/${conf}.conf" ];then
                            Directory=`grep '^<Directory' /alidata/vhosts/${conf}.conf | awk -F'"' '{print $2}'`
                            rm -rf /alidata/vhosts/${conf}.conf
                            /etc/init.d/httpd restart
                            while :; do echo
                                read -p "Do you want to delete Virtul Host directory? [y/n]: " Del_Vhost_wwwroot_yn
                                if [[ ! $Del_Vhost_wwwroot_yn =~ ^[y,n]$ ]];then
                                    echo "input error! Please only input 'y' or 'n'"
                                else
                                    break
                                fi
                            done

                            if [ "$Del_Vhost_wwwroot_yn" == 'y' ];then
                                echo " Press any key to continue..."
                                rm -rf $Directory
                            fi
                            echo "Domain: $domain has been deleted."
                        else
                            echo "Virtualhost: $domain was not exist! "
                        fi
                        break
                    fi
                done

            else
                echo "Virtualhost was not exist! "
            fi
        fi
    fi
}

#check if user is root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

if [ $# -eq 0 ];then
    Add_Vhost
elif [ $# -eq 1 ];then
    case $1 in
    add)
        Add_Vhost
        ;;
    del)
        Del_Nginx_Vhost
        Del_Apache_Vhost
        ;;
    *)
        Usage
        ;;
    esac
else
    Usage
fi

