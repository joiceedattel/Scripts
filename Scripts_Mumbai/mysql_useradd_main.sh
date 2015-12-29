#!/bin/bash

file=$1

echo "efeap_read user add activity for $file" >> /db1/INFRA/joice/scripts_nd_excel/mysql_useradd_log.txt	
echo $(date) >> /db1/INFRA/joice/scripts_nd_excel/mysql_useradd_log.txt

for i in $(cat $file)
do
	ip="$(echo "$i" | cut -d "|" -f1)"
	pass="$(echo "$i" | cut -d "|" -f2)"
	dr_name="$(echo "$i" | cut -d "|" -f3)"
	
	echo $ip >> /db1/INFRA/joice/scripts_nd_excel/mysql_useradd_log.txt
	echo $dr_name >> /db1/INFRA/joice/scripts_nd_excel/mysql_useradd_log.txt
	
  sshpass -p"$pass" ssh -o StrictHostKeyChecking=no "$ip" 'bash -s' < /db1/INFRA/joice/scripts_nd_excel/mysql_user_add.sh >> /db1/INFRA/joice/scripts_nd_excel/mysql_useradd_log.txt
	echo "==========================================================================" >> /db1/INFRA/joice/scripts_nd_excel/mysql_useradd_log.txt

sleep 3
done	





