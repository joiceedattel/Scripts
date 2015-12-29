#!/bin/bash
for i in $(cat password.txt)
do
	ip_list=$(grep $(echo $i | cut -d'|' -f1) dc_list_final.txt)
	DC_CODE=$(echo $ip_list | cut -d'|' -f3)
	echo $DC_CODE	
	test_ip=$(echo $ip_list | cut -d'|' -f5)	
	dc_test=$(expect -c"
		spawn ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=5 coccc@$test_ip hostname
		expect \"password:*\"
		send \"coccc\r\"
		interact
		")
	echo "$dc_test"
sleep 300
done
