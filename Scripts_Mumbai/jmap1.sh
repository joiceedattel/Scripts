#!/bin/bash

ip=$(echo $1 | cut -d "." -f4)
case $ip in 


   131|133)
   echo "time:"$(date +%H:%M)
   echo $2
   echo $1
   total=0 
   allocated=2560
   echo $allocated
   if [ $ip -eq 131 ]
   then
       gf=1
   else
       gf=2
   fi

   for i in $(ps uax | grep gf[1-8] | grep com.sun.aas  |awk '{print $2}')
   do
      echo "GF$gf"
      size=$(expr $(expr $(/usr/java/jdk1.6.0_20/bin/jmap -heap "$i" 2>/dev/null | grep ' used     = ' | head -n4 | cut -d "=" -f2 | cut -d "(" -f1  | sed 's/$/ + /g' ; echo 0)) / 1024 / 1024)
      echo $size
      free=$(expr $allocated - $size)
      echo $free
      gf=$(expr $gf + 2 )

  done

#     echo "Memory_Utilized:$total"

   ;;


esac








#   uptime | awk -F "load average:" '{print $2}'| awk '{print $1}' | sed -e 's/,//'
#   free -m | grep "Mem" | awk '{print $4."MB"}' 
#   ps -eo comm,rss | grep java | awk '{print $2}' | wc -l
#   echo "$(expr $(expr $(ps -eo comm,rss | grep java | awk '{print $2}' |sed -e 's/$/ + /g' | tr "\n" " " | sed 's/....$//')) / 1024)MB"

   

