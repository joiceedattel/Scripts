#!/bin/bash

mkdir -p /tmp/logs
log_path="/tmp/logs"
log_file="unwanted-user-ip_`date`"
log="$log_path/$log_file.txt"
db_host="10.113.186.162"
db_user="feapadmin_db"
db_password="feapadmin_db"
authorised_user="nfsnobody|feapadmin|efeap_read|coccc"

############## to check unwanted OS level users ########################
list=`cat /etc/passwd |cut -d ":" -f3 | grep "[5-9][0-9][0-9]" |tr "\n" "|"`
user=`egrep $list /etc/passwd |cut -d ":" -f1 |egrep -v "$authorised_user"`

#list=`cat /etc/passwd |cut -d ":" -f3 | grep "[5-9][0-9][0-9]"`
	echo "##########################################" >>$log
	echo "------------------------------" >>$log
	echo "	unauthorized users" >> $log
	echo "------------------------------" >>$log
#for i in $list
#do
#	user=`grep $i /etc/passwd |cut -d ":" -f1 |egrep -v "$authorised_user"`
	echo " $user" >>$log
#done
if [ -z '$user' ]
then
	echo  "	  no unauthorized user found" >>$log
fi
	echo "" >>$log
	echo "##########################################" >>$log




############## for identifying any unauthorized IP accessing to DC #####################


allowed_ip=`grep EXCEPT /etc/hosts.deny |awk '{print $3}' | tr ',' '|'` >>$log

failed_ip=`grep 'Failed' /var/log/secure |egrep -v '$allowed_ip' |grep -v 'coccc'|awk '{print $11}'`

echo "" >>$log
echo "" >>$log
echo "################################## Unauthorized ip ###############################" >>$log

failed_ip=`grep Failed /var/log/secure |egrep -v '$allowed_ip' |grep -v coccc | awk '{print $1, $2, $3, $11}'` >>$log
echo "----------------------------------------------------------------------------" >>$log
echo  "	list of unauthorized ip failed to take login DC" >>$log
echo "----------------------------------------------------------------------------" >>$log
echo "	$failed_ip" >>$log
echo "" >>$log

accepted_ip=`grep Failed /var/log/secure |egrep -v '$allowed_ip' |grep -v coccc | awk '{print $1, $2, $3, $11}'` >>$log
echo "" >>$log
echo "---------------------------------------------------------------------" >>$log
echo  "	list of unauthorized ip, logged in DC " >>$log
echo "---------------------------------------------------------------------" >>$log
echo "	$accepted_ip" >>$log
echo "" >>$log

if [ -z "$failed_ip" -a "$accepted_ip" ]
then
	echo "	----------------------------" >>$log
	echo  "	  no unauthorized ip found" >>$log
	echo "	----------------------------" >>$log
fi
echo "##################################################################################" >>$log



echo "" >>$log
echo "" >>$log
echo "############################### For database user #############################" >>$log

mysql_test=`mysql -h$db_host -u$db_user -p$db_password`
if [ -z "$mysql_test" ]
then
	echo "	-----------------------------" >>$log
	echo "	  error in mysql connection" >>$log
	echo "	-----------------------------" >>$log
else	
	mysql -t -h$db_host -u$db_user -p$db_password -e "select user,host from mysql.user" |egrep -v "remoteadmin|feapadmin_db|efeap_read|slave_user" >>$log
fi
echo "###############################################################################" >>$log

w_user=`w |egrep "pts|tty" |grep -v nfsnobody,feapadmin,efeap_read,coccc|awk '{print $1}`

