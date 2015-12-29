#!/bin/bash

appa="$1"
appb=$(echo "$1" | cut -d "." -f1-3).143
weba=$(echo "$1" | cut -d "." -f1-3).131
webb=$(echo "$1" | cut -d "." -f1-3).133
bkpa=$(echo "$1" | cut -d "." -f1-3).145
dbsa=$(echo "$1" | cut -d "." -f1-3).135
echo $(date +%H:%M) >> /tmp/dcreport.txt

while true
do
	for i in $appa $appb $weba $webb $bkpa $dbsa
	do
                echo "Report_of_$i" >> /tmp/dcreport.txt 
	        echo $(ssh $i 'bash -s' < /db1/INFRA/Natarajan/shells_script/dc_check.sh $i >>/tmp/dcreport.txt) 
	done
sleep 20
done


