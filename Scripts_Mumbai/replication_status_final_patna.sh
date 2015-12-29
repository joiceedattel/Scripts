d=`date +%d%m%y%H%M%S`
[ -d logs ] || mkdir logs

for ZO_LIST in `cat refer/dc_dr_*`
do
	for DC_LIST in `echo $ZO_LIST`
	do
		DC_IP=`echo "$DC_LIST" | cut -d'|' -f1,2,4`
		if [ `echo $DC_IP | cut -d"|" -f1` == "ZO" ]
		then
			ZO_NAME=`echo $DC_IP | cut -d"|" -f2`
			echo "                                    ====================================" | tee -a ./logs/$ZO_NAME'_'replication_status_$d.log
			echo "                                        ZO NAME :`echo $DC_IP | cut -d"|" -f2`" | tee -a ./logs/$ZO_NAME'_'replication_status_$d.log
                        echo "                                    ====================================" | tee -a ./logs/$ZO_NAME'_'replication_status_$d.log
		else
			echo "----------------------------------------------------------------------------------------------------------------------------------------------------" | tee -a ./logs/$ZO_NAME'_'replication_status_$d.log
			printf "%-65s\n" "`echo $DC_LIST | cut -d'|' -f4,1 | sed 's/|/--->/' | sed 's/$/ (DC)/' | sed 's/^/   /'`" " " > tmp1.log
			printf "%-65s\n" "                    DBSR Master Status" >> tmp1.log
			printf "%-65s\n" "                    ~~~~~~~~~~~~~~~~~~" >>tmp1.log
			dbsr_ip=`echo $DC_LIST | cut -d'|' -f1`
			if [ `ping -c1 $dbsr_ip | grep "1 packets transmitted, 0 received" | wc -l` -eq 1 ] 
			then
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" "                        Ping Failed" >> tmp1.log 
				printf "%-65s\n" " " >> tmp1.log
                                printf "%-65s\n" "                    DBSA - DBSR Sync Status" >> tmp1.log
                                printf "%-65s\n" "                    ~~~~~~~~~~~~~~~~~~~~~~~" >>tmp1.log
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" "                           Ping Failed" >> tmp1.log 
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" " " >> tmp1.log
				printf "%-65s\n" " " >> tmp1.log
                                printf "%-65s\n" " SUMMARY :-"  >> tmp1.log
				printf "%-65s\n" "   Sever not reachable" >> tmp1.log
			else
				dbsr_master=`mysql -h$dbsr_ip -uslave_user -plicindia -e"show master status\G" 2>> /dev/null` >> ./err/$ZO_NAME'_'replication_status_$d.err
				if [ $? = 1 ]
				then
					printf "%-65s\n" " " >> tmp1.log
	                                printf "%-65s\n" "                        Unable to connect MySQL" >> tmp1.log
        	                        printf "%-65s\n" " " >> tmp1.log
                	                printf "%-65s\n" "                    DBSA - DBSR Sync Status" >> tmp1.log
                        	        printf "%-65s\n" "                    ~~~~~~~~~~~~~~~~~~~~~~~" >>tmp1.log
                        	      	printf "%-65s\n" " " >> tmp1.log
		                	printf "%-65s\n" "                           Unable to connect MySQL" >> tmp1.log
                	                printf "%-65s\n" " " >> tmp1.log
	                                printf "%-65s\n" " " >> tmp1.log
        	                        printf "%-65s\n" " " >> tmp1.log
                	                printf "%-65s\n" " " >> tmp1.log
                        	        printf "%-65s\n" " " >> tmp1.log
	                                printf "%-65s\n" " " >> tmp1.log
        	                        printf "%-65s\n" " " >> tmp1.log
	                                printf "%-65s\n" " " >> tmp1.log
                	                printf "%-65s\n" " SUMMARY :-"  >> tmp1.log
                        	        printf "%-65s\n" "   MySQL is not working" >> tmp1.log
				else
					printf "%-65s\n" "`echo \"$dbsr_master\" | grep -w 'File'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_master\" | grep -w 'Position'`" >> tmp1.log
					printf "%-65s\n" " " >> tmp1.log
					printf "%-65s\n" "                    DBSA - DBSR Sync Status" >> tmp1.log
					printf "%-65s\n" "                    ~~~~~~~~~~~~~~~~~~~~~~~" >>tmp1.log
					dbsr_slave=`mysql -h$dbsr_ip -uslave_user -plicindia -e"show slave status\G" | egrep -i "Master_Log_File|Read_Master_Log_Pos|Relay_Log_File|Relay_Log_Pos|Relay_Master_Log_File|Slave_IO_Running|Slave_SQL_Running|Exec_Master_Log_Pos|Seconds_Behind_Master"`
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Master_Log_File'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Read_Master_Log_Pos'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Relay_Log_File'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Relay_Log_Pos'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Relay_Master_Log_File'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Slave_IO_Running'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Slave_SQL_Running'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Exec_Master_Log_Pos'`" >> tmp1.log
					printf "%-65s\n" "`echo \"$dbsr_slave\" | grep -w 'Seconds_Behind_Master'`" >> tmp1.log
					printf "%-65s\n" " " >> tmp1.log
					printf "%-65s\n" " SUMMARY :-"  >> tmp1.log
					rep_status_dc=`echo "$dbsr_slave" | egrep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "No" | wc -l`
					if [ $rep_status_dc = 0 ]
					then
					        behind_master=`echo "$dbsr_slave" | grep "Seconds_Behind_Master" | awk '{print $2}'`
			        		if [ "$behind_master" = "NULL" ]
					        then
					                printf "%-65s\n" "  Replication is not in sync/running in between DBSA & DBSR" >> tmp1.log
					        else
					                printf "%-65s\n" "  Replication between DBSA and DBSR is working '$behind_master' seconds behind"  >> tmp1.log
					        fi
					else
						printf "%-65s\n" "  Replication is not working" >> tmp1.log
						printf "%-65s\n" " " >> tmp1.log
					fi
				fi
			fi
########### tmp 2

			echo "$DC_LIST" | cut -d'|' -f4,3 | sed 's/|/--->/g' | sed 's/$/ (DR)/'|sed "s/^/  /"> tmp2.log
			echo  -e "\n\n\n\n\n" >> tmp2.log
			printf "%40s\n" "DBSR - DR Sync Status" >> tmp2.log
			printf "%40s\n" "~~~~~~~~~~~~~~~~~~~~~" >>tmp2.log
			dr_ip=`echo $DC_LIST | cut -d'|' -f3`
			if [ `ping -c1 $dr_ip | grep "1 packets transmitted, 0 received" | wc -l` -eq 1 ]
                        then
				echo " " >> tmp2.log
                                printf "%43s\n" "Ping Failed" >> tmp2.log
				echo " " >> tmp2.log
				echo " " >> tmp2.log
				echo " " >> tmp2.log
				echo " " >> tmp2.log
				echo " " >> tmp2.log
				echo " " >> tmp2.log
				echo " " >> tmp2.log
				echo " " >> tmp2.log
                                echo " SUMMARY:-" >> tmp2.log
				echo "    Sever not reachable" >> tmp2.log
			else
				dr_slave=`mysql -h$dr_ip -uslave_user -plicindia -e"show slave status\G" 2>> /dev/null | egrep -i "Master_Log_File|Read_Master_Log_Pos|Relay_Log_File|Relay_Log_Pos|Relay_Master_Log_File|Slave_IO_Running|Slave_SQL_Running|Exec_Master_Log_Pos|Seconds_Behind_Master" `
				if [ $? = 1 ]
                	        then
					echo " " >> tmp2.log
	                                printf "%42s\n" "Unable to connect MySQL" >> tmp2.log
        	                        echo " " >> tmp2.log
                	                echo " " >> tmp2.log
                        	        echo " " >> tmp2.log
                                	echo " " >> tmp2.log
	                                echo " " >> tmp2.log
        	                        echo " " >> tmp2.log
                	                echo " " >> tmp2.log
                        	        echo " " >> tmp2.log
	                                echo " SUMMARY:-" >> tmp2.log
        	                        echo "    MySQL is not working" >> tmp2.log
				else
					#	break
					echo "$dr_slave" >> tmp2.log
					echo " " >> tmp2.log
					echo " SUMMARY:-" >> tmp2.log
					rep_status_dr=`echo "$dr_slave" | egrep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "No" | wc -l`
                        		if [ $rep_status_dr = 0 ]
	                        	then
        	                        	behind_master=`echo "$dr_slave" | grep "Seconds_Behind_Master" | awk '{print $2}'`
	                	                if [ "$behind_master" = "NULL" ]
        	                	        then
                	                  	      echo "  Replication is not in sync/running in between DC & DR" >> tmp2.log
	                	                else
        	                	              echo "  Replication between DC & DR is working '$behind_master' seconds behind"  >> tmp2.log 
                        	        	fi
					else
        		                        echo "  Replication is not working" >> tmp2.log
                		        fi
				fi
			fi
			paste tmp1.log tmp2.log > tmp3.log
			sed -e "s/\t/\t|/g" tmp3.log  | tee -a ./logs/$ZO_NAME'_'replication_status_$d.log
			echo "----------------------------------------------------------------------------------------------------------------------------------------------------" | tee -a ./logs/$ZO_NAME'_'replication_status_$d.log
			
			echo " "
		fi
	
	done
done


rm -f tmp1.log tmp2.log tmp3.log
