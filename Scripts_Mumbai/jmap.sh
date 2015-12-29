#!/bin/bash
#NameVirtualHost *:80

#echo "Please give arguments in the given below format"
#read -p "Enter the DC Name :-" dcname
#read -p "Enter the Path of txt file containg IPAddress|Password :- " file_path
#echo "Output file will be saved in /db1/dc_slowness_reports" 

#dcname=$1
file_path=$1

count=0
fname=$(echo -e $(date +%F)_"$dcname")

#while true
#do

	for i in $(cat "$file_path")
	do
               DC="$(echo "$i" | cut -d "|" -f1)"
	       ip="$(echo "$i" | cut -d "|" -f2)"
               pass="$(echo "$i" | cut -d "|" -f3)"
               
		sshpass -p"$pass" ssh -o StrictHostKeyChecking=no "$ip" 'bash -s' < /db1/jmap1.sh $ip $DC |xargs -I {} echo {} | sed -e '/^$/d' |tr "\n" "|" | sed -e 's/time/\ntime/g' >> /db1/jmap_reports/"$(date +%F)"_jmap_report.xls
 
        done


#done


