# beginning
mkdir -p /usr/netvault/scripts/logs
logpath=/usr/netvault/scripts/logs
echo "script starting at " `date` >> $logpath/nvbuscript.out
file_name="purge_status_`date +%Y%m%d%H%M%S`"
dbsa_days="7 days"
dbsr_days="7 days"
#!/bin/bash

#Modified On      :- 25-06-2012
#Author          :- Wipro INFRA Team
#Revised Edition :- V1.3
#Purpose         :- Purging binary logs on DBSA & DBSR
#Description     :- Script will purge binary logs prior to 4 days on DBSA & DR. 
#                   Keygen between DBSR - DBSA & DBSR - DR is mandatory.
NV_HOME=/usr/netvault;
NV_UTIL=/usr/netvault/util;
NV_BIN=/usr/netvault/bin;
NV_STATUS=SUCCEEDED
#Checking For Backup Status.

dbsa_binlog()
{
if [ ! -z "$bin_log" ]
        then
                echo "==================================================================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "*****************Purging DBSA binary logs started on `date`*****************" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                for i in $(echo $deleted_bin_log)
                do
                        if [ ! $i = $bin_log ]
                          then
                        echo "Deleting binary logs $i " 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                        fi
                done
        #       mysql -h$hname -uremoteadmin -padmin123 -e "purge binary logs to '$bin_log'" >> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "************Purging DBSA binary logs completed on `date` *******************" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "==================================================================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err

        else
                echo "=====================================================================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "No binary logs present prior to '$purge_date'" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "                   OR" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "Replication between DBSA & DBSR not in sync or not running" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "=====================================================================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
        fi
}

dbsr_binlog()
{
 if [ ! -z "$bin_log" ]
          then
                echo 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "==================================================================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "*****************Purging DBSR binary logs started on `date`*****************" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                for i in $( echo $deleted_bin_log)
                do
                        if [ ! $i = $bin_log ]
                        then
                        echo "Deleting binary logs $i "  1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                        fi
                done
               # mysql -e "purge binary logs to '$bin_log'" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "*****************Purging DBSR binary logs Completed on `date`****************" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                echo "===================================================================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err   
        else       
               echo   
               echo "=============================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
               echo "No binary logs present prior to '$purge_date'" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
               echo "                   OR" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
               echo "Replication between DBSR & DR not in sync or not running" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
               echo "=============================================================" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
           fi
}


if [ "$NV_STATUS" = "SUCCEEDED" ]
then
	check_keygen()
        {
        ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@`hostname | sed 's/....$/DBSA/g'` ifconfig 1> /dev/null 2> /dev/null
                if [ $? = 1 ]
                then
                       echo "Keygen not working between DBSR to DBSA" 1>> $logpath/$file_name.txt 2>> $logpath/$file_name.err
                exit
                fi
	}	
	

	check_keygen 

			#######i################ Pruging binarylogs on DBSA ##############################
 hname=`hostname -i | sed 's/...$/162/'`
 rep_status=`mysql -e "show slave status\G" | grep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "No" | wc -l`
 if [ $rep_status = 0 ]
 then
 	master_status=`mysql -e "show slave status\G" | grep "Master_Log_File:" | awk '{print $2}' |head -n1`
        bin_date=`ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hname 'ls -ltr /binlog' |grep "$master_status" |awk '{print $6, $7}'`
	purge_date=`date -d "$(echo $bin_date) $dbsa_days ago" '+%b %e'`
        bin_log=`ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hname 'ls -ltr /binlog' |grep "$purge_date" |awk '{print $9}' |head -n1`

	deleted_bin_log=`ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hname ls -ltr /binlog |grep -B 1000 $bin_log | grep "mysql-bin." | awk '{print $9}'`


		if [ -z "$bin_log" ]
		then
		count=1
		while [ -z "$bin_log" ]
		do
		echo "No binlog found for $purge_date, taking binlogs to purge $count days ago"
		purge_date=`date -d "$(echo $purge_date) $count days ago" '+%b %e'`
		bin_log=`ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hname 'ls -ltr /binlog' |grep "$purge_date" |awk '{print $9}' |head -n1`
		deleted_bin_log=`ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$hname ls -ltr /binlog |grep -B 1000 $bin_log | grep "mysql-bin." | awk '{print $9}'`
		deleted_bin_count=`echo $deleted_bin_log |wc -l`	
			if [ $deleted_bin_count = 1 ]
			then
			bin_log=`mysql -h$hname -uremoteadmin -padmin123 -e "show binary logs" |grep -A1 $bin_log  |awk '{print $1}' |tail -n1`
			dbsa_binlog
			else	

			dbsa_binlog		
				if [ ! -z "$binlog" ]
				then
				break
				fi
		count=`expr $count + 1`
		fi
		done
		else
    	dbsa_binlog

		fi 
fi


			####################### Pruging binarylogs on DR ##############################

 hname_DR=`grep '\-V' /etc/hosts | awk '{print $1}'`
 rep_status=`mysql -h $hname_DR -uremoteadmin -padmin123 -e "show slave status\G" | egrep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "No" | wc -l`
 if [ $rep_status = 0 ]
 then
	master_status=`mysql -h $hname_DR -uremoteadmin -padmin123  -e "show slave status\G" |grep "Master_Log_File:" |awk '{print $2}'|head -n1`
	bin_name=`ls -ltr /binlog |grep "$master_status" |awk '{print $6, $7}'`
	purge_date=`date -d "$(echo $bin_date) $dbsr_days ago" '+%b %e'`
	bin_log=`ls -ltr /binlog |grep "$purge_date" |awk '{print $9}' |grep "mysql-bin." |tail -n1`
	deleted_bin_log=`ls -ltr /binlog |grep -B 1000 $bin_log |grep "mysql-bin." |awk '{print $9}'`

		if [ -z "$bin_log" ]
                then
                count=1
                while [ -z "$bin_log" ]
                do
                purge_date=`date -d "$(echo $purge_date) $dbsr_days ago" '+%b %e'`
                bin_log=`ls -ltr /binlog |grep "$purge_date" |awk '{print $9}' |grep "mysql-bin." |tail -n1`
                deleted_bin_log=`ls -ltr /binlog |grep -B 1000 $bin_log |grep "mysql-bin." |awk '{print $9}'`
		deleted_bin_count=`echo $deleted_bin_log |wc -l`
                        if [ $deleted_bin_count = 1 ]
                        then
                        bin_log=`mysql -e "show binary logs" |grep -A1 $bin_log  |awk '{print $1}' |tail -n1`
                        dbsr_binlog
                        else
			dbsr_binlog
                                if [ ! -z "$binlog" ]
                                then
                                break
                                fi
                count=`expr $count + 1`
                fi
                done
                else
        dbsr_binlog

                fi
	
fi




else

        echo "The Backup has failed. The Purging of binary logs will not happen."
        echo $NV_STATUS >> $logpath/bin_pur.log
        exit 0
fi
echo "script ending at `date`" >> $logpath/nvbuscript.out

			############################################################################################
