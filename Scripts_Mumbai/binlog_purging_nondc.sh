#!/bin/bash

if [ "$1" = "-V" ]
then
echo "	Author          :- Wipro INFRA Team
	Edition 	:- V1.0
	Purpose         :- Purging binary logs on NCZ NONDC
	Description     :- Script will purge binary logs prior to 8 days on NONDC. "
elif [ -z "$1" ]
then
mkdir -p /home/coccc/scripts/logs
logpath=/home/coccc/scripts/logs
file_name="purge_status_`date +%Y%m%d%H%M%S`"
days="7"
max_limit="5"
log_file="$logpath/$file_name.txt"
log_err="$logpath/$file_name.err"
mysql_user="remoteadmin"
mysql_passwd="admin123"
echo  1>> $log_file 2>> $log_err
echo "script starting at " `date` 1>> $log_file 2>> $log_err
echo  1>> $log_file 2>> $log_err
	


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



non_dc ()
{

        if [ ! -z "$bin_log" ]
        then
                echo "=====================================================================================================" 1>> $log_file 2>> $log_err
		echo -e "\n ******** Purging  binary logs started on $1 at `date`*********\n " 1>> $log_file 2>> $log_err
		echo -e "\n ************* Purging binary logs upto $2 *********\n " 1>> $log_file 2>> $log_err
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
	                        echo -e "\n *******Purging  binary logs Completed on $1 at `date`**********\n " 1>> $log_file 2>> $log_err
                        else
        	                echo -e "\n\t\t\tscript failed on $1 \n"     1>> $log_file 2>> $log_err                        echo 1>> $log_file 2>> $log_err
                        fi
                echo "=====================================================================================================" 1>> $log_file 2>> $log_err

        fi
}



replication_status()
{
			echo "	=====================================================================" >> $log_err
                        echo "          Replication between $FINAL_REPLICATION_HOST & $HOSTNAME not running" >> $log_err
                        echo "	=====================================================================" >> $log_err
			echo  1>> $log_file 2>> $log_err
			echo "script ending at `date`" 1>> $log_file 2>> $log_err
			exit

}



			 ####################### Purging binarylogs logic started  ##############################
	hdrname=`grep NONDC /etc/hosts | awk '{print $1}'`
	hname=`hostname -i`
	hdrname_count=`grep NONDC /etc/hosts | awk '{print $1}' |wc -l `

	if [ -z "$hdrname" -o "$hdrname_count" -ne 1 ] 
	then 
		echo "		============================================================================================" >> $log_err
        	echo -e "\t\t\t Please check IP configration entry for DR in /etc/hosts file\n" >> $log_err
		echo -e "\t\t\t Either None or Multiple DR entry is present " >> $log_err
		echo "		============================================================================================" >> $log_err
        	echo "script ending at `date`" 1>> $log_file 2>> $log_err
		exit 
	fi 


		
	hostname=$(echo $HOSTNAME)
	db_partition_size=$(df -Ph | grep -w "/db" | awk '{print $5}'  | tr -d '%')	
	binlog_partition_size=$(df -Ph | grep -w "/binlog" | awk '{print $5}'  | tr -d '%')

	check_size



			######################## Checking Replication Status#############################
				mysql_connect="mysql -h$hdrname -u$mysql_user -p$mysql_passwd -e"
				mysql_connect_purge="mysql -h$hname -u$mysql_user -p$mysql_passwd -e"
				rep_status=`$mysql_connect "show slave status\G" | egrep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "Yes" | wc -l`
				CHECK_HOST_NAME=$(echo $HOSTNAME)
				FINAL_REPLICATION_HOST=$(grep NONDC /etc/hosts | awk '{print $3}')-$(echo "(DR)")
				echo 1>> $log_file 2>> $log_err 
				echo "======================================================================" 1>> $log_file 2>> $log_err
				echo "	    Purging BinaryLogs on $CHECK_HOST_NAME" 1>> $log_file 2>> $log_err
				echo "======================================================================" 1>> $log_file 2>> $log_err

		if [ "$rep_status" = 2 ]
	    	then
			master_status=`$mysql_connect "show slave status\G" | grep "Relay_Master_Log_File" | awk '{print $2}'`
			###################################Replication Logic Finished ###############################







 		     	#################################### Setting up bin_date variable with master status########	
			unset bin_log
			count=1
			while [ -z "$bin_log" ]
			do
					 bin_date=`ls -ltr /binlog |grep "$master_status" |awk '{print $6, $7}'`	
					 day_limit="$days"
					 day_before=`expr $day_limit + $count`;
					 purge_date=`date -d "$(echo $bin_date) $day_before days ago" '+%b %e'`
					 cd /binlog
					 deleted_bin_log=`ls -ltr mysql-bin.?????? | grep -w "mysql-bin.[0-9]\{6\}" |grep -B1000 -A1 "$purge_date" |awk '{print $9}'`
					  cd -
			################################ FINISHED bin_date variables ################
					





			################################# Purging Logic and setting up requierd parameters here#################### 
				bin_log=$(echo $deleted_bin_log | tr ' ' '\n' | tail -n1)
				if [ ! -z "$bin_log" ]
                                then
                                        non_dc "$CHECK_HOST_NAME" "$purge_date"
                                else
                                        echo -e "\nNo binlog found for '$purge_date', taking binlogs 1 days ago from '$purge_date' \n" 1>> $log_file 2>> $log_err
                                fi

				if [ "$count" = "$max_limit" ]
				then
					echo 1>> $log_file 2>> $log_err
					echo -e "\n No binary logs found prior to '$purge_date' \n Maximum limit of going backward is $(expr $day_limit + $max_limit) days ago from $bin_date  \n"  1>> $log_file 2>> $log_err
					bin_log="exit";
					echo "=====================================================================" 1>> $log_file 2>> $log_err
				fi

					count=`expr $count + 1`

			done
				
			################################### Purging LOGIC finished#############################	
		else
			replication_status
	    	fi

echo  1>> $log_file 2>> $log_err
echo "script ending at `date`" 1>> $log_file 2>> $log_err
fi
