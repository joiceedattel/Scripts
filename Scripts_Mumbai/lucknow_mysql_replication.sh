#!/bin/bash
                     #Checking Master status

date|awk '{print $2,$3,$4}'
mysql -h10.34.58.162 -uslave_user -plicindia -e "show master status;"|sed -n '2p'|awk '{print $1,$2}'
 



                     #Checking DBSR status
mysql -h10.34.58.139 -uslave_user -plicindia -e "show slave status \G;"|egrep "Relay_Master_Log_File|Exec_Master_Log_Pos:"|tr '\n' '\t'|awk '{print $2,$4}'

mysql -h10.34.58.139 -uslave_user -plicindia -e "show slave status \G;"|grep Seconds_Behind_Master:|awk '{print $2}'

status1=$(mysql -h10.34.58.139 -uslave_user -plicindia -e "show slave status \G;"|egrep "Slave_IO_Running|Slave_SQL_Running"|tr '\n' '\t'|awk '{print $2.$4}')

if [ "$status1"=="YesYes" ]; then echo "Running";echo "Replication is in sync"; else echo "Not Running"; fi



                     #checking DR status

mysql -h10.47.1.192 -uslave_user -plicindia -e "show slave status \G;"|egrep "Relay_Master_Log_File|Exec_Master_Log_Pos:"|tr '\n' '\t'|awk '{print $2,$4}'

mysql -h10.47.1.192 -uslave_user -plicindia -e "show slave status \G;"|grep Seconds_Behind_Master:|awk '{print $2}'

status2=$(mysql -h10.47.1.192 -uslave_user -plicindia -e "show slave status \G;"|egrep "Slave_IO_Running|Slave_SQL_Running"|tr '\n' '\t'|awk '{print $2.$4}')
if [ "$status2"=="YesYes" ]; then echo "Running";echo "Replication is in sync";else echo "Not Running"; fi

