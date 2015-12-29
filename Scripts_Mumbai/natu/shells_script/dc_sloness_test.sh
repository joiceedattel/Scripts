#!/bin/bash





echo $(date +%H:%M) >> /tmp/dcreport.txt

while true
do
	for i in $(cat /db1/INFRA/Natarajan/shells_script/dc_ip_pass.txt)
	do
               ip=$(echo $i | cut -d "|" -f1)
               pass=$(echo $i | cut -d "|" -f2)
               echo "Report_of_$ip" >> /tmp/dcreport.txt 
	       sshpass -p$pass ssh "$ip" 'bash -s' < /db1/INFRA/Natarajan/shells_script/dc_check.sh $ip >>/tmp/dcreport.txt
	done
sleep 20
done


