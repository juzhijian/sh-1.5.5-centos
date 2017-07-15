#!/bin/bash  
wwwdir=/alidata/www
count=1 

fdisk -l 2>/dev/null|grep "^Disk /dev/xvd[b-z]"

if [[ "$?" != "0" ]];then
	echo  "Please mount the common cloud disk!"
else
for C in `mount|grep "/dev/xvd[b-z]"|awk '{print $1}'`;do
	fuser -km $C
	umount $C
	echo umount $C finished.
done

dd if=/dev/zero of=/dev/$C bs=512 count=1 2>/dev/null 
disk=`fdisk -l 2>/dev/null|grep "^Disk /dev/xvd[b-z]"|awk -F: '{print $1}'|awk '{print $2}'`
for A in $disk
do 
fdisk $A &>/dev/null<< EOF
n
p
1


w	 
EOF
sleep 5
partprobe  
mkfs.ext4 ${A}1 
mkdir -p /data${count}  
#tempuuid=`blkid |grep  ${A}1 | awk -F'\"' '{print $2}'`  
tempuuid=`blkid ${A}1 | awk -F'\"' '{print $2}'`  
echo "UUID=${tempuuid} /data${count} ext4 defaults,noatime 0 0" >> /etc/fstab 
mount ${A}1 /data${count} 
let "count = $count + 1" 
done
echo "$A mounted complete"
/etc/init.d/httpd  stop
sleep 3
\cp -a $wwwdir /alidata/Document.bak
\mv  $wwwdir /data1
for B in /alidata/vhosts/*.conf
do
	sed -i -e 's#/alidata/www#/data1/www#' $B
done
/etc/init.d/httpd start
fi
