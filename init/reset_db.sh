#!/bin/bash
#

#dbrootpwd=`awk -F:  '/mysql/ {print $2}' /alidata/account.log`
Mysql_dir=/alidata/server/mysql


Reset_db_root_password()
{

[ ! -d "$Mysql_dir" ] && { echo "The Database is not installed on your system! "; exit 1; }
one_dbrootpwd=0
two_dbrootpwd=1
	echo "Changing password for user root." 
flag=1	
while [ "$flag" -ne 0 ]
do
   	read -p "Please enter the old password:" oldpwd
	mysql -uroot -p$oldpwd  &>/dev/null << EOF 
	exit
EOF
	flag=$?
	if [ $flag -ne 0 ];then
	echo "Password error! "
	fi
done

while [ $one_dbrootpwd != $two_dbrootpwd ] 
do
    oldpwd=$oldpwd
    read -p "New password: " one_dbrootpwd
    read -p "Retype new password: " two_dbrootpwd
    #[ -n "`echo $two_dbrootpwd | grep '[+|&]'`" ] && { echo "input error,not contain a plus sign (+) and &"; continue; }
    #[ ${#two_dbrootpwd} -ge 6 ] && break || echo "database root password least 6 characters! "
	dbrootpwd=$oldpwd
    if [ $one_dbrootpwd = $two_dbrootpwd ];then

        $Mysql_dir/bin/mysqladmin -uroot -p"$oldpwd" password "$two_dbrootpwd" -h localhost &>/dev/null
        status_Localhost=`echo $?`
        $Mysql_dir/bin/mysqladmin -uroot -p"$oldpwd" password "$two_dbrootpwd" -h 127.0.0.1 &>/dev/null
        status_127=`echo $?`
else
        echo "Two password entered is not consistent, please re-enter! "
       # break;
fi
done

if [ $status_Localhost -eq 0 -o $status_127 -eq 0 ]; then
    sed -i s/'^mysql_password.*'/mysql_password:"${two_dbrootpwd}"/g /alidata/account.log
    echo
    echo "Password reset succesfully! "
    echo "The new database password: ${two_dbrootpwd}"
    echo
else
        echo "Reset Database root password failed! "
fi
}
Reset_db_root_password
