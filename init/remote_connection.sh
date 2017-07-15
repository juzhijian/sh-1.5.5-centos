#!/bin/bash
#source /etc/profile
#dbrootpwd=`awk -F:  '/mysql/ {print $2}' /alidata/account.log`

read -p "Please enter the root user password: " dbrootpwd
dbrootpwd=$dbrootpwd
echo $dbrootpwd >>/dev/null

mysql -uroot -p$dbrootpwd &>/dev/null <<EOF 
exit
EOF

if [[ "$?" != "0" ]];then
	echo  "Password error!"
else
	mysql -uroot -p$dbrootpwd &>/dev/null <<EOF
        use mysql;
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$dbrootpwd';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$dbrootpwd';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY '$dbrootpwd';
        delete from user  where User = '' or Host in ('::1','iz235l80vedz');
        flush privileges;
        select User,Host,password from mysql.user;
EOF

	echo  "Remote connection for root user opens successfully!"
fi
