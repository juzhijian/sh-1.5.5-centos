#!/bin/bash
#Description：Interactive User Management
#

A=echo
#for cmd in echo /bin/echo; do
#        $cmd >/dev/null 2>&1 || continue
#        if ! $cmd -e "" | grep -qE '^-e'; then
#                echo=$cmd
#                break
#        fi
#done

HEAD=$($A -e "\033[")
END="${HEAD}0m"
RED="${HEAD}1;31m"
GREEN="${HEAD}1;32m"
YELLOW="${HEAD}1;33m"
BLUE="${HEAD}1;34m"
MA="${HEAD}1;35m"
CY="${HEAD}1;36m"

www_dir=/alidata/www/
ftp_install_dir=/etc

function ADD () {
while true
do
        read -p "${MA}Please,Input a Username:${END}" user
 if [ -z "$user" ]; then
        echo "${RED}username can't be NULL!${END}"
    else
	echo "$user" >> /etc/allowed_users
	user=$user
        break
 fi
done
}
function USER () {
while true
do
cat /etc/passwd|grep -o $user &>/dev/null
	if [ $? -eq 0 ];then
		user=$user
		break
	else
		echo "${RED}[$user] don't existed!${END}"
		read -p "${MA}Please,Input a Username:${END}" user
	fi
done
}
function PASS () {
while [ 1 ]
do
	read -p "${RED}Please input the password:${END} " password
  	[ -n "`echo $password | grep '[+|&]'`" ] && { echo "Input error,not contain a plus sign (+) and &"; continue; }
    if (( ${#password} >= 6 )) ;then
	passwod=$password       
 	break

    else
        echo "${RED}ftp password least 6 characters!${END} "
    fi
done
}

function DIR () {
while true
do
    read -p "${RED}Please input the directory(Default directory:${END} ${MA}$www_dir${END}):" directory
    if [ -z "`echo $directory | grep '^/'`" ]; then
        echo "input formt error!"
	DIR;
	#read -p "${RED}Please input the directory(Default directory:${END} ${MA}$www_dir${END}):" directory
    #else
    #   break;
    fi

    if [ -z "$directory" ]; then
       directory="$www_dir"
    fi
    if [ ! -d "$directory" ];then	
	mkdir -p $directory
        directory="$directory"	
        #echo "${YELLOW}The directory does not exist${END}"
	break
    else
        break
    fi
done
}


[ $(id -u) != "0" ] && { echo "${RED}Note:This operation requires root privileges${END}"; exit 1; }

[ ! -d $ftp_install_dir ] && { echo "${RED}Pleas,check ftp server${END} " exit2; }

while :
do 
	cat<<EOF

$GREEN 1.Add User$END
$RED 2.Delete User$END
$YELLOW 3.Change Directory$END
$BLUE 4.Change Password$END
$MSG 5.Quit$END 
EOF


	read -p "${RED}Enter your option:${END}" choice

	case "$choice" in
	
	1)
		DIR;
		ADD;
while true
do
		cat /etc/passwd|grep $user &>/dev/null
		if [ $? -ne 0 ]; then
			useradd -s /usr/bin/nologin -d $directory -m $user >/dev/null 2>&1
                        chown -R $user:$user $directory
			break
		else
			echo "${BLUE}[$user] is already existed,please input again!${END}"
			read -p "${MA}Please,Input a Username:${END}" user		
		fi
done
		PASS;
			#echo $password|passwd --stdin $user
			echo $user:$password |/usr/sbin/chpasswd
			echo "#####################################"
                	echo
                	echo "${GREEN}[$user] create successful!${END} "
                 	echo
                 	echo "Your user name is : ${YELLOW}$user${END}"
                	 echo "Your Password is : ${YELLOW} $password${END}"
                 	echo "Your directory is : ${YELLOW}$directory${END}"
                 	echo
	;;
	
	2)
		ADD
		cat /etc/passwd|grep -o $user &>/dev/null
		if [ $? -eq 0 ];then
			userdel  $user
			echo "${GREEN}Delete [$user] finished${END}" 
		else
			echo "${RED}[$user] don't existed!${END}"
		fi
	;;

	3)
		ADD;
		USER;
		DIR;
		#cat /etc/passwd|grep -o $user &>/dev/null
		#if [ $? != 0 ];then
		#	echo "${RED}[$user] don't existed!${END}"
		#else
			chown -R $user:$user $directory
			usermod  -d $directory $user
			echo "#####################################"
                 	echo
                 	echo "${GREEN}[$user] modify successful!${END} "
                 	echo
                 	echo "Your user name is : ${GREEN}$user${END}"
                 	echo "Your new directory is : ${GREEN}$directory${END}"
                 	echo
		#fi
		;;

	4)
		ADD;
		USER;
		PASS;
		cat /etc/passwd|grep -o $user &>/dev/null
		if [ $? -eq 0 ];then
			#echo "$password" |passwd --stdin $user
			echo $user:$password |/usr/sbin/chpasswd
			echo "#####################################"
            		echo
            		echo "${GREEN}[$user] Password changed successfully!${END} "
            		echo
            		echo "You user name is : ${CY}$user${END}"
            		echo "You new password is : ${CY}$password${END}"
            		echo	
		else
			echo "${RED}[$user] don't existed!${END}"
		fi
	;;

	5)
		exit 0
	;;
	
	*)
		continue;
	;;
esac
done
