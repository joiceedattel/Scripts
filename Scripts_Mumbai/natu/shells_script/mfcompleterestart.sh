#!/bin/bash
source /etc/profile
today=`date +%d-%m-%Y-%T`
mkdir /tmp/SOA-restart_$today
dir=/tmp/SOA-restart_$today

id |grep "uid=501(feapadmin)" 1> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today 
if [ "$?" = 1 ]
then

echo "======================================================================" 
echo "               Execute script through feapadmin user only                   " 
echo "======================================================================"
exit
else
echo -n "Executing.."

echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today 
echo "                       Stopping SOA                                        " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today  
echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

echo -n ".."

casstop /f 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo -n ".."
sleep 10 

pkill -9 cassi > /dev/null
pkill -9 cassi > /dev/null
echo -n ".."

casstop /f 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo -n ".."
sleep 10

echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     Stopped successfully                                  " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

cd /home/feapadmin/scripts/mfmem 

echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     Purging shared memory                                 " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

echo -n ".."
mfmempurge feapadmin 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

cd /var/mfcobol/es 
rm -rvf ESDEMO 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

echo -n ".."
cd /home/feapadmin/scripts/mfmem 

echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     Shared memorey trashed                                " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today


mfmemtrash ESDEMO 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo -n ".."
sleep 3

mfmemtrash ESDEMO 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo -n ".."
sleep 3

ipcs -sm | grep "feapadmin" | wc 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
sleep 3


sudo /usr/bin/pkill -9 mfds

echo -n ".."
echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     MFDS Stopped................              " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

sleep 2

echo ".."
sudo /opt/microfocus/cobol/bin/eslmfgetpv k

echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     ESLM Stopped................              " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

sleep 2 

cd /home/feapadmin/scripts/MFSharedMemoryReset/

sudo /bin/chown -R feapadmin.feapadmin /opt/microfocus/ /var/mfcobol/ /var/aslmfsem /var/mfaslmf 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

./MFSharedMemoryReset.sh 2>> $dir/SOA-restart_err_$today | tee -a $dir/SOA-restart_log_$today
sleep 3
./MFSharedMemoryReset.sh 2>> $dir/SOA-restart_err_$today | tee -a $dir/SOA-restart_log_$today
sleep 3
./MFSharedMemoryReset.sh 2>> $dir/SOA-restart_err_$today | tee -a $dir/SOA-restart_log_$today
sleep 3
./SharedMemoryDelete.sh 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
sleep 2
./SharedMemoryDelete.sh 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
sleep 2

sudo -i /opt/microfocus/cobol/bin/eslm

echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     ESLM Started Successfully................              " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

sleep 2

sudo -i /opt/microfocus/cobol/bin/mfds &

echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     MFDS started Successfully................              " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

sleep 2

if [ "$?" = 1 ]
then
echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                     Unable to start MFDS services......              " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "============================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
exit

else
source /etc/profile
unset IDMLOG
unset IDMLOGDIR
idtmake32 /LX

echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                        MF starting..............                          " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

/opt/microfocus/cobol/bin/casstart 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

grep "XA" /var/mfcobol/es/ESDEMO/console.log
if [ "$?" = 1 ]
then

echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                        MF starting failed.......                          " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

else

echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "                        MF started successfully                            " 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today
echo "===========================================================================" 1>> $dir/SOA-restart_log_$today 2>> $dir/SOA-restart_err_$today

fi
fi
fi
