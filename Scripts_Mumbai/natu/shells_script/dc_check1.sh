#!/bin/bash

ip=$(echo $1 | cut -d "." -f4)
case $ip in 

   131|133)
   if [ $ip -eq 131 ]
   then
   echo "time:"$(date +%H:%M) 
   fi
   echo $1
   for i in 38080 38090 38070 38060 cmd
   do if [ $i == "cmd" ]
   then
   uptime | awk -F "load average:" '{print $2}'| awk '{print $1}' | sed -e 's/,//'
   free -m | grep "Mem" | awk '{print $4."MB"}' 
   else
   echo 
   netstat -plant | grep $i | grep -v "grep " | wc -l
   fi
   done

   ;;

   141|143|145)
   echo $1
   ps aux | grep rts | grep -v "grep" |wc -l
   echo "put_value"
   uptime | awk -F "load average:" '{print $2}'| awk '{print $1}' | sed -e 's/,//'
   free -m | grep "Mem" | awk '{print $4."MB"}' 
   ;;


   162)
   
   echo $1
   mysql -e "show processlist" |wc -l
   uptime | awk -F "load average:" '{print $2}'| awk '{print $1}' | sed -e 's/,//'
   free -m | grep "Mem" | awk '{print $4."MB"}' 
    ;;
   

esac
