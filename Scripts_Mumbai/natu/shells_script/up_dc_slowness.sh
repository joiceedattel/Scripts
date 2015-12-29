#!/bin/bash

#echo "Please give arguments in the given below format"
#read -p "Enter the DC Name :-" dcname
#read -p "Enter the Path of txt file containg IPAddress|Password :- " file_path
#echo "Output file will be saved in /db1/dc_slowness_reports" 

dcname=$1
file_path=$2

[[ -e /db1/dc_slowness_reports/"$dcname"_report.xls ]] && mv /db1/dc_slowness_reports/"$dcname"_report.xls /db1/dc_slowness_reports/"$dcname"_report_old.xls && cp /db1/dc_slowness_reports/base.xls /db1/dc_slowness_reports/"$dcname"_report.xls || cp /db1/dc_slowness_reports/base.xls /db1/dc_slowness_reports/"$dcname"_report.xls




	for i in $(cat "$file_path")
	do
               ip="$(echo "$i" | cut -d "|" -f1)"
               pass="$(echo "$i" | cut -d "|" -f2)"


              if [ $(echo "$ip" | cut -d "." -f4) -eq 162 ]
              then 
               
    			if [[ $(sshpass -p$pass ssh "$ip" df -h) ]]
			then
			
		sshpass -p"$pass" ssh -o StrictHostKeyChecking=no "$ip" 'bash -s' < /db1/INFRA/Natarajan/shells_script/dc_check.sh $ip |xargs -I {} echo {} | sed -e '/^$/d' |tr "\n" "|" | sed -e 's/time/\ntime/g' >> /db1/dc_slowness_reports/"$dcname"_report.xls
#               return
               		else
		
         		pass=$(echo $i | cut -d "|" -f3)
		sshpass -p"$pass" ssh -o StrictHostKeyChecking=no "$ip" 'bash -s' < /db1/INFRA/Natarajan/shells_script/dc_check.sh $ip |xargs -I {} echo {} | sed -e '/^$/d' |tr "\n" "|" | sed -e 's/time/\ntime/g' >> /db1/dc_slowness_reports/"$dcname"_report.xls
#		return

                      fi

             else      

		sshpass -p"$pass" ssh -o StrictHostKeyChecking=no "$ip" 'bash -s' < /db1/INFRA/Natarajan/shells_script/dc_check.sh $ip |xargs -I {} echo {} | sed -e '/^$/d' |tr "\n" "|" | sed -e 's/time/\ntime/g' >> /db1/dc_slowness_reports/"$dcname"_report.xls
	      fi
 
        done


