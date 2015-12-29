#!/bin/bash

#[[ $(date +%d/%m/%y | cut -d "/" -f3) -ge "14" ]] && [[ $(date +%d/%m/%y | cut -d "/" -f2 | sed 's/0//') -gt 8 ]] && echo "SCRIPT EXPIRED 1 " &&  exit || if [ $(date +%d/%m/%y | cut -d "/" -f1) -gt 10 ] 
#	then
#	echo "SCRIPT EXPIRED 2 "
#	exit
#fi

if [ $(date +%d/%m/%y | cut -d "/" -f3) -le "14" ]
then
	 if [ $(date +%d/%m/%y | cut -d "/" -f2 | sed 's/0//') -lt 9 ]
	   then
         	if [ $(date +%d/%m/%y | cut -d "/" -f2 | sed 's/0//') -eq 8 ] 
                 then 
                  [[ $(date +%d/%m/%y | cut -d "/" -f1) -gt 10 ]] && echo "SCRIPT EXPIRED" && exit
                 fi 
          
	echo "script running "
	echo $(date) >> /tmp/mysql_sleep_killed.txt
	count=0
	###_______Displaying Status_______###
	echo "Status before running the script" >> /tmp/mysql_sleep_killed.txt
	echo "================================" >> /tmp/mysql_sleep_killed.txt
	echo "Total mysql threads : " $(mysql -e "show processlist" | wc -l) >> /tmp/mysql_sleep_killed.txt
	echo "Total WEB Threads :" $(mysql -e "select * from information_schema.processlist where command='sleep' and host like '%web%' " | wc -l) >> /tmp/mysql_sleep_killed.txt
	echo "---------------------------------------------------------------" >> /tmp/mysql_sleep_killed.txt
	echo "Killed Process IDs " >> /tmp/mysql_sleep_killed.txt


#	for i in $(mysql -e " select * from information_schema.processlist where command='sleep' and host like '%web%' and time > 10800 ;" | awk '{print $1}'  | grep -v "ID")
#	do
#		mysql -e "kill $i"
#		echo $i >> /tmp/mysql_sleep_killed.txt
#		count=`(expr $count + 1)`
#	done


	###_______Displaying Status_______###
	echo "Status after running the script" >> /tmp/mysql_sleep_killed.txt
	echo "===============================" >> /tmp/mysql_sleep_killed.txt
	echo "No of threads killed (ran more than 3 hours (10800sec)" : "$count" >> /tmp/mysql_sleep_killed.txt
	echo "Total mysql threads : " $(mysql -e "show processlist" | wc -l) >> /tmp/mysql_sleep_killed.txt      
	echo "Total WEB Threads :" $(mysql -e "select * from information_schema.processlist where command='sleep' and host like '%web%' " | wc -l) >> /tmp/mysql_sleep_killed.txt
	echo "---------------------------------------------------------------" >> /tmp/mysql_sleep_killed.txt

        fi

else
        exit
fi
