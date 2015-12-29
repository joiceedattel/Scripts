#!/bin/bash
#Modified On     :- 17-12-2014
#Author          :- Wipro INFRA Team
#Revised Edition :- V1.4
#Purpose         :- Purging binary logs on DBSA & DBSR
#Description     :- Script will purge binary logs prior to 8 days on DBSA & 14 days DR. 
#                   Keygen between DBSR - DBSA & DBSR is mandatory.

mkdir -p /home/coccc/scripts/logs
logpath=/home/coccc/scripts/logs
file_name="purge_status_`date +%Y%m%d%H%M%S`"
dbsa_days="15"
dbsr_days="15"
max_limit="5"
NV_HOME=/usr/netvault;
NV_UTIL=/usr/netvault/util;
NV_BIN=/usr/netvault/bin;
log_file="$logpath/$file_name.txt"
log_err="$logpath/$file_name.err"
mysql_user="remoteadmin"
mysql_passwd="admin123"
echo  1>> $log_file 2>> $log_err
echo "script starting at " `date` 1>> $log_file 2>> $log_err
echo  1>> $log_file 2>> $log_err
sumr="616031"


check_size ()
{	
	if [ $db_partition_size -gt 99 -o $binlog_partition_size -gt 99 ]
	then
		echo "	=================================================================" >> $log_err
		if [ $db_partition_size -gt 99 ]
		then 
		echo -e "\t\t\t /db partition is 100%" >> $log_err
		fi
		if [ $binlog_partition_size -gt 99 ]
		then
		echo -e "\t\t\t /binlog partition is 100%" >> $log_err
		fi
		echo "	=================================================================" >> $log_err
		exit
	fi
}



dbsa_dbsr ()
{

        if [ ! -z "$bin_log" ]
        then
		echo -e "\n Purging binary logs upto $2 \n " 1>> $log_file 2>> $log_err
                for i in $(echo $deleted_bin_log)
                do
                        if [ ! "$i" = "$bin_log" ]
                        then
                        	echo "Deleting binary logs $i " 1>> $log_file 2>> $log_err
                        fi
                done
			$mysql_connect_purge "purge binary logs to '$bin_log'" >> $log_file 2>> $log_err
                        if [ $? = 0 ]
                        then
				echo 1>> $log_file 2>> $log_err
                        	echo -e "                           script executed successfully on $1 " 1>> $log_file 2>> $log_err
	                        echo -e "\n Purging  binary logs Completed on $1 at `date`\n " 1>> $log_file 2>> $log_err
                        else
        	                echo -e "\n\t\t\tscript failed on $1 \n"     1>> $log_file 2>> $log_err                        echo 1>> $log_file 2>> $log_err
                        fi

        fi
}

dbsr_dbsr ()
{

        if [ ! -z "$bin_log" ]
        then
		echo -e "\n Purging binary logs upto $2 \n " 1>> $log_file 2>> $log_err
                for i in $(echo $deleted_bin_log)
                do
                        if [ ! "$i" = "$bin_log" ]
                        then
                        	echo "Deleting binary logs $i " 1>> $log_file 2>> $log_err
                        fi
                done
			mysql_connect_purge="mysql -h`hostname` -u$mysql_user -p$mysql_passwd -e"
			$mysql_connect_purge "purge binary logs to '$bin_log'" >> $log_file 2>> $log_err
                        if [ $? = 0 ]
                        then
				echo 1>> $log_file 2>> $log_err
                        	echo -e "                           script executed successfully on $1 " 1>> $log_file 2>> $log_err
	                        echo -e "\n Purging  binary logs Completed on $1 at `date`\n " 1>> $log_file 2>> $log_err
                        else
        	                echo -e "\n\t\t\tscript failed on $1 \n"     1>> $log_file 2>> $log_err                        echo 1>> $log_file 2>> $log_err
                        fi

        fi
}


replication_status()
{
	if [ $rep_status_dc != 2 ]
	then
		echo "	=====================================================================" >> $log_err
	        echo "          Replication between $FINAL_REPLICATION_HOST & $HOSTNAME not running" >> $log_err
        	echo "	=====================================================================" >> $log_err
	elif [ $rep_status_dr != 2 ]
	then
		echo "	=====================================================================" >> $log_err
	        echo "          Replication between $FINAL_REPLICATION_HOST & $DR_REPLICATION_HOST not running" >> $log_err
        	echo "	=====================================================================" >> $log_err
	fi
		echo  1>> $log_file 2>> $log_err
		echo "script ending at `date`" 1>> $log_file 2>> $log_err
		exit

}



check_keygen()
{
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@`hostname -i | sed 's/...$/162/'` /sbin/ifconfig 1> /dev/null 2> /dev/null
        if [ $? != 0 ]
        then
                echo "Keygen not working between DBSR to DBSA"  1>> $log_file 2>> $log_err
                exit
        fi

}


if [ "$NV_STATUS" = "SUCCEEDED" ]
then
	 		 ####################### Purging binarylogs logic started  ##############################
if [ -e /usr/netvault/scripts/DR_list.txt ]
then
	sum=`sum -r /usr/netvault/scripts/DR_list.txt |sed 's/ //g'`
	if [ $sum = $sumr ]
	then
		openssl des3 -d -salt -in /usr/netvault/scripts/DR_list.txt -out /usr/netvault/scripts/DR_list.txt_bkp -pass pass:lic123
		code=`hostname |cut -d '-' -f2`
		dr_avl="$(grep $code /usr/netvault/scripts/DR_list.txt_bkp |awk '{print $2}')"
		if [ "$dr_avl" = N ]
		then
			hdrname="N"
			hdrname_count="N"
			hdcname=`hostname -i | sed 's/...$/162/'`
		        hprefix=`hostname | sed "s+X+V+;s+-D.*++"`
		fi
	else
		echo  "===================================================================">> $log_err
	        echo  "Input File is Corruped, Plz contact CO for Rectification........" >> $log_err
		echo  "===================================================================">> $log_err
		exit
	fi
	rm -rf DR_list.txt_bkp
else
	        hprefix=`hostname | sed "s+X+V+;s+-D.*++"`
		hdrname=`grep "$hprefix-....\.lic\.in" /etc/hosts | awk '{print $1}'`
		hdrname_count=`grep "$hprefix-....\.lic\.in" /etc/hosts | awk '{print $1}' |wc -l `
		hdcname=`hostname -i | sed 's/...$/162/'`
		dr_avl="Y"	
fi
	
	


	        if [ -z "$hdcname" ]
        	then
			echo "	======================================================================" >> $log_err
	        	echo -e  "\t\t\t Please check IP configration entry for DBSR in /etc/hosts file" >> $log_err
			echo "	======================================================================" >> $log_err
        		exit
		else
			ip="$(echo $hdcname |cut -d'.' -f4)"
			if [ -z "$ip" ] 
			then
        			echo -e  "\n ERROR :: While Setting up IP Variable " 1>> $log_file 2>> $log_err
				exit 
			else 
				if [ "$ip" != 162 ]
				then
        				echo -e  "\n ERROR :: While Setting up IP Variable Please check output hostname -i it must show proper DC IP " 1>> $log_file 2>> $log_err
					exit
				fi 
			fi
		fi
		
	
		if [ "$hdrname" = "N" -o "$hdrname_count" = "N" ]
        	then
			 echo ""

		elif [ -z "$hdrname" -o "$hdrname_count" -ne 1 ] 
		then 
			echo "		============================================================================================" >> $log_err
        		echo -e "\t\t\t Please check IP configration entry for DR in /etc/hosts file of DBSR server\n" >> $log_err
			echo -e "\t\t\t Either None or Multiple DR entry is present " >> $log_err
			echo "		============================================================================================" >> $log_err
        		echo "script ending at `date`" 1>> $log_file 2>> $log_err
			exit 
		fi 

		check_keygen		

		
		hostname=$(echo $HOSTNAME)
		db_partition_size=$(df -Ph | grep -w "/db" | awk '{print $5}'  | tr -d '%')	
		binlog_partition_size=$(df -Ph | grep -w "/binlog" | awk '{print $5}'  | tr -d '%')

		check_size


			CHECK_HOST_NAME=`ssh  -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hdcname 'echo $HOSTNAME' `
			FINAL_REPLICATION_HOST=`echo $CHECK_HOST_NAME`
			DR_REPLICATION_HOST=`grep $hdrname /etc/hosts |awk '{print $3}'`

		######################## Checking Replication Status#############################
		for i in "$hdcname" "$hdrname"
		do

			hname=$i

			hip="$(echo $hname |cut -d'.' -f4)"
			if [ "$hip" = 162 ]
			then
				mysql_connect="mysql -h$(hostname -i) -u$mysql_user -p$mysql_passwd -e"
				mysql_connect_purge="mysql -h$hname -u$mysql_user -p$mysql_passwd -e"
				rep_status_dc=`$mysql_connect "show slave status\G" | egrep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "Yes" | wc -l`
				master_status_dc=`$mysql_connect "show slave status\G" | grep "Relay_Master_Log_File" | awk '{print $2}'`
			else
				if [ "$hdrname" = "N" -o "$hdrname_count" = "N" ]
        			then
					echo ""
				else
					mysql_connect="mysql -h$hname -u$mysql_user -p$mysql_passwd -e"
					mysql_connect_purge="mysql -h$hdcname -u$mysql_user -p$mysql_passwd -e"
					rep_status_dr=`$mysql_connect "show slave status\G" | egrep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "Yes" | wc -l`
					master_status_dr=`$mysql_connect "show slave status\G" | grep "Relay_Master_Log_File" | awk '{print $2}'`
				fi
			fi

			done
		
		################################### finalizing master_status #############################	
			
			if [ $dr_avl = N ]
			then
				master_status=$master_status_dc
				echo "============================================================================================" >> $log_err
                     		echo -e "\t\t\t      DR is not available for $HOSTNAME " >> $log_err
	                        echo "============================================================================================" >> $log_err
			else
				if [ "$rep_status_dc" = 2 -a "$rep_status_dr" = 2 ]
			    	then
		
					if [ $(echo $master_status_dr| cut -d'.' -f2) -lt $(echo $master_status_dc| cut -d'.' -f2) ]
					then
						master_status=$master_status_dr
					else
						master_status=$master_status_dc
					fi
				else
					replication_status
				fi
			fi

	
	 		
	     	################################### Setting up bin_date variable with master status########	
                		echo "=====================================================================================================" 1>> $log_file 2>> $log_err
				echo -e "	------------------------------------------------------------------------------" 1>> $log_file 2>> $log_err
				echo -e "	 Purging binary logs started on $FINAL_REPLICATION_HOST at `date`" 1>> $log_file 2>> $log_err
				echo -e "	------------------------------------------------------------------------------" 1>> $log_file 2>> $log_err
echo  1>> $log_file 2>> $log_err
					unset bin_log
					count=1
					while [ -z "$bin_log" ]
					do
							bin_date=`ssh  -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hdcname 'ls -ltr /binlog' |grep "$master_status" |awk '{print $6, $7}'`
							day_limit="$dbsa_days"
							day_before=`expr $day_limit + $count`;
							purge_date=`date -d "$(echo $bin_date) $day_before days ago" '+%b %e'`
							deleted_bin_log=`ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hdcname 'cd /binlog; ls -ltr mysql-bin.??????' | grep -w "mysql-bin.[0-9]\{6\}" |grep -B1000 -A1 "$purge_date" |awk '{print $9}'`
					
		################################ FINISHED bin_date variables ################
					
		################################# Purging Logic and setting up requierd parameters here#################### 
						bin_log=$(echo $deleted_bin_log | tr ' ' '\n' | tail -n1)
						if [ ! -z "$bin_log" ]
                        		        then
                                		        dbsa_dbsr "$CHECK_HOST_NAME" "$purge_date"
		                                else
        		                                echo -e "No binlog found for '$purge_date', taking binlogs 1 days ago from '$purge_date'" 1>> $log_file 2>> $log_err
                		                fi
	
						if [ "$count" = "$max_limit" ]
						then
							echo  1>> $log_file 2>> $log_err
							echo -e "\n No binary logs found prior to '$purge_date' \n Maximum limit of going backward is $(expr $day_limit + $max_limit) days ago from $bin_date  \n"  1>> $log_file 2>> $log_err
							bin_log="exit";
						fi

							count=`expr $count + 1`

					done
                		echo "=====================================================================================================" 1>> $log_file 2>> $log_err
                		echo "" 1>> $log_file 2>> $log_err
                		echo "" 1>> $log_file 2>> $log_err
                		echo "=====================================================================================================" 1>> $log_file 2>> $log_err
				echo -e "	------------------------------------------------------------------------------" 1>> $log_file 2>> $log_err
				echo -e "	 Purging binary logs started on $FINAL_REPLICATION_HOST at `date`" 1>> $log_file 2>> $log_err
				echo -e "	------------------------------------------------------------------------------" 1>> $log_file 2>> $log_err
					unset bin_log
					count=1
					while [ -z "$bin_log" ]
					do
							bin_date=`ls -ltr /binlog |tail -n1 |grep "$master_status" |awk '{print $6, $7}'`
							day_limit="$dbsr_days"
							day_before=`expr $day_limit + $count`;
							purge_date=`date -d "$(echo $bin_date) $day_before days ago" '+%b %e'`
							deleted_bin_log=`cd /binlog; ls -ltr mysql-bin.?????? | grep -w "mysql-bin.[0-9]\{6\}" |grep -B1000 -A1 "$purge_date" |awk '{print $9}'`
					
		################################ FINISHED bin_date variables ################
					
		################################# Purging Logic and setting up requierd parameters here#################### 
						bin_log=$(echo $deleted_bin_log | tr ' ' '\n' | tail -n1)
						if [ ! -z "$bin_log" ]
                        		        then
                                		        dbsr_dbsr "`hostname`" "$purge_date"
		                                else
        		                                echo -e "No binlog found for '$purge_date', taking binlogs 1 days ago from '$purge_date'" 1>> $log_file 2>> $log_err
                		                fi
	
						if [ "$count" = "$max_limit" ]
						then
							echo  1>> $log_file 2>> $log_err
							echo -e "\n No binary logs found prior to '$purge_date' \n Maximum limit of going backward is $(expr $day_limit + $max_limit) days ago from $bin_date  \n"  1>> $log_file 2>> $log_err
							bin_log="exit";
						fi

							count=`expr $count + 1`
					done
                		echo "=====================================================================================================" 1>> $log_file 2>> $log_err
				
		################################### Purging LOGIC finished#############################	
else
	echo  "===================================================================">> $log_err
        echo "The Backup has failed, The Purging of binary logs will not happen." >> $log_err
	echo  "===================================================================">> $log_err
        echo $NV_STATUS >> $log_err
        echo "script ending at `date`" 1>> $log_file 2>> $log_err
        echo $NV_STATUS >> $log_err
	exit 0
fi
echo  1>> $log_file 2>> $log_err
echo "script ending at `date`" 1>> $log_file 2>> $log_err
echo  1>> $log_file 2>> $log_err
