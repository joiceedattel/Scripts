#!/bin/bash

#MddyyHHmmss
#080214031113

#date --date="yesterday"



for i in $(cat /root/Desktop/SnapShots.csv | grep -v "#")
do
  CY=$(date +%y)
  CM=$(date +%m)
  CD=$(date +%d)
  CH=$(date +%H)
  time_stamp=$(echo $i | cut -d";" -f4)
  M=$(echo $time_stamp | sed 's/"//' |cut -c1,2)
  Y=$(echo $time_stamp | sed 's/"//' |cut -c5,6)
  D=$(echo $time_stamp | sed 's/"//' | cut -c3,4)
  H=$(echo $time_stamp | sed 's/"//' |cut -c7,8)

echo $date  

#current year and current month
	if [ "$Y" -eq "$CY" ] && [ "$M" -eq "$CM" ]
	then
		if [ "$D" == "$CD" ] #current day
		then	
			totalhr=$(expr $CH - $H)
			if [ "$totalhr" -le "12" ]						
			then 
				echo "sucesses => $i"  >> /tmp/backup.out
			else
				echo "failed => $i " >> /tmp/backup.out
			fi
		elif [ "$D" -eq $(expr $CD - 1) ] 
		then
			hrs_prevday=$(expr 24 - "$H")
			total_hrs=$(expr "$hrs_prevday" + $CH)
			if [ "$total_hrs" -le 12 ]
			then
				echo "sucesses => $i"  >> /tmp/backup.out
			else
				echo "failed => $i "  >> /tmp/backup.out
			fi
		fi

	elif [ "$Y" == "$CY" ] && [ "$M" == $(expr "$CM" - 1) ]
	then
		if [ "$CD" -eq "01" ]
		then
			hrs_prevday=$(expr "$H" - "24")
                        tot_hrs=$(expr "$hrs_prevday" + "$CH")
			if [ "$total_hrs" -le "12" ]
                        then
                                echo " sucesses => $i" >> /tmp/backup.out
                        else
                                echo " failed => $i " >> /tmp/backup.out
                        fi

		else
			echo "failed => $i" >> /tmp/backup.out
		fi
		
	else

		echo "failed => $i" >> /tmp/backup.out


	fi
done
