#/bin/bash
hname=`hostname`
code=`echo $hname | cut -d'-' -f1,2`
dccode=`echo $code"-"`
logpath="/efeap/data/patch/logs"
patchfile=$1
Warbkup=$2
tdate=`date +%Y%b%d-%H%M%S`
todaydir=$3
count=0

restart_glassfish()
{
##Stopping Node-Agent in WEBB
#echo "Stopping WEBB Node Agent"
#hostnameWEBB=`hostname | sed 's/WEBA/WEBB/g'`
#ssh feapadmin@${hostnameWEBB} /opt/SUNWappserver/bin/asadmin stop-node-agent > /dev/null
#sleep 5
#pkill -9 java > /dev/null
#ssh feapadmin@${hostnameWEBB} ls -lrtd /opt/SUNWappserver/nodeagents/${hostnameWEBB}.lic.in/*/applications/j2ee-modules
#if [ $? = 0 ]
#then
#ssh feapadmin@${hostnameWEBB} rm -rf /opt/SUNWappserver/nodeagents/${hostnameWEBB}.lic.in/*/applications/j2ee-modules
#ssh feapadmin@${hostnameWEBB} rm -rf /tmp/*.data
#ssh feapadmin@${hostnameWEBB} rm -rf /tmp/*.tmp
#fi
#echo "WEBB Node Agent Stopped Successfully"

##Stopping Node-Agent in WEBA
echo "Stopping WEBA Node Agent"
/opt/SUNWappserver/bin/asadmin stop-node-agent > /dev/null
sleep 5
ls -lrtd /opt/SUNWappserver/nodeagents/*/*/applications/j2ee-modules
if [ $? = 0 ]
then
rm -rf /opt/SUNWappserver/nodeagents/*/*/applications/j2ee-modules
fi
echo "WEBA Node Agent Stopped Successfully"

echo "Stopping Domain"
##Stopping Domain in WEBA
/opt/SUNWappserver/bin/asadmin stop-domain > /dev/null
sleep 5
pkill -9 java > /dev/null
ls -lrtd /opt/SUNWappserver/domains/domain1/applications/j2ee-modules/
if [ $? = 0 ]
then
rm -rf /opt/SUNWappserver/domains/domain1/applications/j2ee-modules/
rm -rf /tmp/*.data
rm -rf /tmp/*.tmp
fi
echo "Domain Stopped Successfully"

echo "Starting Domain"
##Starting Domain in WEBA
/opt/SUNWappserver/bin/asadmin start-domain -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password > /dev/null
echo "Domain Started Successfully"

##Starting Node-Agent in WEBA
echo "Starting WEBA Node Agent"
/opt/SUNWappserver/bin/asadmin start-node-agent --syncinstances=true -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password > /dev/null
echo "WEBA Node Agent Started Successfully"

##Starting Node-Agent in WEBB
#echo "Starting WEBB Node Agent"
#ssh feapadmin@${hostnameWEBB} /opt/SUNWappserver/bin/asadmin start-node-agent --syncinstances=true -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password > /dev/null
#echo "WEBB Node Agent Started Successfully"

/opt/SUNWappserver/bin/asadmin list-instances -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password 
/opt/SUNWappserver/bin/asadmin list-instances -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password | grep "not running"
if [ $? = 0 ]
then
count=`expr $count + 2`
	if [ $count = 1 ]
        	then
        	exit
        	else
                echo "All the instances are not started properly"
                echo "Restarting Glassfish again"
		sh /efeap/Script/restart_glassfish.sh
	fi
fi
}

restart_cluster()
{
i=0
while [ $i != 3 ]
do
i=`/opt/SUNWappserver/bin/asadmin stop-cluster -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password lic-cluster | grep "was already stopped." | wc -l`
done
echo "GlassFish Cluster Stopped Successfully."
sleep 10
i=0
while [ $i != 6 ]
do
i=`/opt/SUNWappserver/bin/asadmin start-cluster -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password lic-cluster | grep "is running, does not require restart" | wc -l`
done
/opt/SUNWappserver/bin/asadmin list-instances -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password
/opt/SUNWappserver/bin/asadmin list-instances -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password | grep "not running"
if [ $? = 0 ]
then
count=`expr $count + 1`
        if [ $count = 2 ]
                then
		echo "GlassFish Cluster is not started properly. Please restart Glassfish  manually."
                else
                echo "All the instances are not started properly"
                echo "Restarting Glassfish Cluster again"
                sh /efeap/Script/restart_glassfish.sh
/opt/SUNWappserver/bin/asadmin list-instances -u feapadmin --passwordfile /opt/SUNWappserver/bin/.password
        fi
echo "GlassFish Cluster Started Successfully."
fi
}


deploy()
{
echo " ============================ "
echo " Restarting GlassFish "
echo " ============================ "
echo " "
echo " "
restart_glassfish
echo " "
echo " "
echo " ========================== "
echo " Deploying the New WAR File "
echo " ========================== "
echo " "
echo " "
/opt/SUNWappserver/bin/asadmin deploy --user feapadmin --passwordfile /opt/SUNWappserver/bin/.password --contextroot eFeap --target lic-cluster /efeap/war/eFeap.war
if [ $? = 0 ]
then
	echo "War deployed Successfully"
else
	echo "Issue in War deployment"
	exit 1
fi
sleep 10
echo " "
echo " "
echo " ========================== "
echo " New WAR File Deployed      "
echo " ========================== "
echo " "
echo " ============================ "
echo " Restarting GlassFish Cluster "
echo " ============================ "
restart_cluster
echo " "
echo " ======================================"
echo " Restarting GlassFish Cluster Completed"
echo " ======================================"
echo " "
echo " "
echo " ========================= "
echo " Java Deployment Completed "
echo " ========================= "
echo " "
echo " "
}
echo " "
echo " "

echo " ================================================================ "
echo "  UnDeploying the Existing WAR File in WEBA Server "
echo " ================================================================ "
echo " "
##Undeploying java WAR file in WEBA Server
flag=`/opt/SUNWappserver/bin/asadmin undeploy --user feapadmin --passwordfile /opt/SUNWappserver/bin/.password --target lic-cluster eFeap 2> $logpath/$dccode"WEBA"_"$todaydir"_err.txt`
if [ $? != 0 ]
then
    flag="Warning No:301 : WEBA-FAILURE : efeap war file already undeployed"`cat $logpath/$dccode"WEBA"_"$todaydir"_err.txt`    echo $flag
else
        echo " "
        echo " ====================================================== "
        echo "  UnDeployed Existing WAR File in WEBA Server "
        echo " ====================================================== "
        echo " "
fi
echo " "
echo " "
echo " "

mkdir -p /efeap/data/backup/softwarebkp/$Warbkup
cp /efeap/war/eFeap.war /efeap/data/backup/softwarebkp/$Warbkup

echo " "
echo " "
echo "                     "
echo " Extracting TAR File "
echo " =================== "
echo " "
echo " "
sleep 5
cd /
tar -zxvf efeap/data/patch/$patchfile efeap/war efeap/wsdl

cd /efeap/war/
if [ -e eFEAP_Patch_War.tgz ]
	then
	mkdir temp
	echo " "
	echo " "
	echo " Full WAR Deployment Please Ignore The Below Error Message"
	echo " "
	echo " "
	mv eFEAP_Patch_War.tgz /efeap/war/temp/
	cd /efeap/war/temp/
	tar -zxvf eFEAP_Patch_War.tgz

	cd /efeap/war/
	echo " "
	echo " "
	echo " ================ "
	echo " Merging WAR File "
	echo " ================ "
	echo " "
	echo " "
	jar uvf eFeap.war -C temp .
	rm -rf /efeap/war/temp
	deploy
	else
	deploy
fi
sleep 5 
echo " "
echo " "

