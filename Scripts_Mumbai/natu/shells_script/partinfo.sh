#!/bin/bash
echo "File System Analysis  "
echo " "
count=`df -h |grep -v "Mounted" | wc -l`
echo " "
echo "You have $count Partitions"

while [ $count -gt 0 ]

do

total=100

used=`df -h | grep -v "Mounted" |awk '{print $5}' | head -$count | tail -n1 |tr '%' ' '`

fs=`df -h | grep -v "Mounted" |awk '{print $1}' | head -$count | tail -n1`

mnt=`df -h | grep -v "Mounted" |awk '{print $6}' | head -$count | tail -n1`

tsize=`df -h | grep -v "Mounted" |awk '{print $2}' | head -$count | tail -n1`


#df -h | grep -v "Mounted" |awk '{print $5 $6}' | head -$count | tail -n1

#echo "The filesystem $fs mounted on $mnt is almost used $used"

if [ $used -ge 90 ]

then

echo -e "\033[41m ! ! ! CRITICAL ! ! !\033[0m "  "The filesystem $fs mounted on $mnt is almost used $used% "

free=`expr $total - $used`

echo  " you are having free space $free%"

echo " "

elif [ $used -ge 75 ]; then

echo -e "\033[43m ! ! ! WARNING ! ! !\033[0m" "The filesystem $fs mounted on $mnt is used $used% Please remove unused data "

free=`expr $total - $used`

echo  " you are having free space $free%"

echo " "

elif [ $used -le 75 ];then

echo -e "\033[42m ! ! ! NORMAL ! ! !\033[0m"  "The filesystem $fs mounted on $mnt is used $used% "

free=`expr $total - $used`

echo  " you are having free space $free%"
echo " "

fi

count=`expr $count - 1`

done 







