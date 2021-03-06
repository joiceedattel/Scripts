#!/bin/bash
echo " "
echo " "
echo " ======================== "
echo " Patch Deployment Started "
echo " ======================== "
echo " "
echo " "
/usr3/tibco/tibco/prog/lic_mw_stop_adapters
sleep 3
killall rvd
sleep 2
killall rvd
echo " "
echo " ======================== "
echo " Cobol Deployment Started "
echo " ======================== "
echo " "
echo " "
sleep 5
echo " "
echo " "
echo " ============================ "
echo " Taking existing eFeap Backup "
echo " ============================ "
echo " "
echo " "
sleep 2
todaydir=`date +%Y%b%d%H%M`
cd /backup/softwarebkp/
mkdir -p $todaydir
cd $todaydir
#tar -zcvf eFEAP_bkp.tgz --exclude=/efeap/data /efeap
cd /
echo " "
echo " "
echo "                     "
echo " Extracting TAR File "
echo " =================== "
echo " "
echo " "
sleep 2
tar -zxvf /patch/eFEAP_Exec.tgz
dos2unix /efeap/deploy/script/*.sh
echo " "
echo " "
/efeap/deploy/script/eFEAP_WebService_UnDeploy.sh
echo " "
echo " "
sleep 2
/efeap/deploy/script/eFEAP_WebService_Deploy.sh
echo " "
echo " "
echo "                            "
echo " COBOL Deployment Completed "
echo " ========================== "
echo " "
echo " "
sleep 5
echo " "
echo " "
#echo "                         "
#echo " DB Deployment Started "
#echo " ======================= "
echo " "
echo " "
#sleep 5
/efeap/deploy/script/eFEAP_DB_Deploy.sh
#sleep 5 
echo " "
echo " "
#echo "                           "
#echo " DB Deployment Completed "
#echo " ========================= "
echo " "
echo " "
#sleep 5
echo " "
echo " "
echo "                       "
echo " Java Deployment Started "
echo " ===================== "
echo " "
echo " "
sleep 10
/efeap/deploy/script/eFEAP_Java_Deploy.sh
echo " "
echo " "
echo "                            "
echo " Stopping Glassfish Server  "
echo " ========================== "
echo " "
echo " "
sleep 5
/opt/SUNWappserverNewJUNE10/bin/asadmin stop-domain
sleep 5
echo " "
echo " "
echo "                           "
echo " Java Deployment Completed "
echo " =========================="
echo " "
echo " "
sleep 3
echo " "
echo " "
echo "                           "
echo " Stopping SOA Server       "
echo " =========================="
echo " "
echo " "
casstop /f
sleep 3
casstop /f
sleep 2
mv /patch/eFEAP_Exec.tgz /efeap/data/backup/softwarebkp/$todaydir
sleep 2
echo " "
echo " "
echo " *****************  eFEAP DEPLOYMENT SUCCESSFULLY COMPLETED ************************ "
echo " "
echo " "
sleep 2
