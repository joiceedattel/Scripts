#!/bin/bash

user=feapadmin

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
fi

echo " "
echo " "
echo " ================================= "
echo " UnDeploying the Existing WAR File "
echo " ================================= "
echo " "
echo " "

sleep 5

#/opt/SUNWappserverNewJUNE10/bin/asadmin  undeploy  --user admin --passwordfile /efeap/deploy/script/passwd   eFeap

sleep 5 

echo " "
echo " "
echo " =========================== "
echo " Restarting GlassFish Server "
echo " =========================== "
echo " "
echo " "

/opt/SUNWappserverNewJUNE10/bin/asadmin stop-domain

sleep 10

/opt/SUNWappserverNewJUNE10/bin/asadmin start-domain

sleep 5

echo " "
echo " "
echo " ========================== "
echo " Deploying the New WAR File "
echo " ========================== "
echo " "
echo " "


/opt/SUNWappserverNewJUNE10/bin/asadmin deploy --user admin --passwordfile /efeap/deploy/script/passwd  --contextroot eFeap  /efeap/war/eFeap.war


sleep 2
