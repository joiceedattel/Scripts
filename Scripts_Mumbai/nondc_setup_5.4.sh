#!/bin/bash
mkdir /opt/Packages
echo " "
echo "==================================================================================="
echo -e "Whether all the Packages from DVD have been copied in /opt/Packages directory [Y/N]: \c "
read input
if [ $input = N ]
then
	echo " "
	echo "========================================================"
	echo " Kindly copy the DVD contents to /opt/Packages and then execute the script again"
	echo "========================================================"
	echo " "
	exit
fi
if [ $input = Y ]
then
echo -e " Starting the NON-DC production setup"

if [ $(cat /etc/redhat-release |awk '{print $7}') != 5.4 ]
then
	echo " "
	echo "============================================="
	echo " Kindly install rhel 5.4 and execute script"
	echo "============================================="
	echo " "
	exit
fi


####### creating user feapadmin ##########
tar -zxvf Production-Config.tgz -C /
id feapadmin
if [ $? != 0 ]
then
	useradd -u 501 -g feapadmin
	if [ $? = 0 ]
	then
		echo " "
		echo "======================="
		echo " user feapadmin created"
		echo "======================="
		echo " "
	fi
else
	echo " "
	echo "=============================="
	echo " user feapadmin already exist"
	echo "=============================="
	echo " "
fi
##########################################



######### installing java ##############
mkdir /usr/java
tar -zxvf /opt/Packages/jdk1.6.0_20.tgz -C /usr/java
cd /usr/bin
mv java java_old
mv javac javac_old
mv javah javah_old
mv javap javap_old
mv jar jar_old

## Create links for Java Executables ##
ln -s /usr/java/jdk1.6.0_20/bin/java .
ln -s /usr/java/jdk1.6.0_20/bin/javac .
ln -s /usr/java/jdk1.6.0_20/bin/javacdoc .
ln -s /usr/java/jdk1.6.0_20/bin/javah .
ln -s /usr/java/jdk1.6.0_20/bin/javap .
ln -s /usr/java/jdk1.6.0_20/bin/jar .

java -version
########################################

############ installing mysql ##########
rpm -qa | grep -i mysql > mysql.txt
for i in $(cat mysql.txt)
do
	rpm -e $i --nodeps
done
cd /opt/Packages/rpm
echo ""
echo "==================================="
echo " Installing Mysql-5.5.18........."
echo "==================================="
echo ""
mkdir /db
cp /opt/Packages/my.cnf /etc/
for i in MySQL-server-advanced-5.5.18-1.rhel5.x86_64.rpm MySQL-client-advanced-5.5.18-1.rhel5.x86_64.rpm
do
	rpm -ivh $i
done
	if [ $? !=0 ]
	then
		echo " "
		echo "================================="
		echo " Error in Mysql installation...."
		echo "================================="
		echo " "
	else
		echo " "
		echo "============================="
		echo " Mysql Installation completed"
		echo "============================="
		echo " "
	fi

cp -aRv /opt/Packages/mysql /db
chown -R mysql.mysql /db
/etc/init.d/mysql start
status=`/etc/init.d/mysql status`
if [ $(echo $status |awk '{print $2}') = "running" ]
then
	echo " "
	echo "========================="
	echo " Mysql started properly"
	echo "========================="
	echo " "
else
	echo " "
	echo "====================================="
	echo " ERROR: Kindly start Mysql manually"
	echo "====================================="
	echo " "
fi
######################################################



## Installing UnixODBC and Mysql connectors ##
cp -aRv /opt/Packages/odbcpack /opt
cd /opt/odbcpack/odbc-5.1.7/
sh odbcinstall.sh


mysql -e"create database efeap"
mysql -e"create user remoteadmin identified by 'admin123'"
mysql -e"create user feapadmin_db identified by 'feapadmin_db';"
mysql -e "grant all privileges on *.* to 'remoteadmin'@'%' identified by 'admin123' with grant option;"
mysql -e "grant all privileges on *.* to 'remoteadmin'@'localhost' identified by 'admin123' with grant option;"
mysql -e "grant all privileges on *.* to 'feapadmin_db'@'%' identified by 'feapadmin_db' with grant option;"
mysql -e "flush privileges"
echo 'quit' |isql -v efeap remoteadmin admin123
if [ $? = 0 ]
then
	echo " "
	echo "==============================="
	echo " odbc installed successfully"
	echo "==============================="
	echo " "
else
	echo " "
	echo "==============================================="
	echo " ERROR: Kindly check the configuration manually"
	echo "==============================================="
	echo " "
fi
##############################################


########### Installing glassfish #############
echo " "
echo "===================================="
echo "  Installing glassfish..........."
echo "===================================="
echo " "
tar -zxvf /opt/Packages/SUNWappserver.tgz -C /
##############################################

######### Installing firefox and jre #########
tar zxvf /opt/Packages/jre1.6.0_22.tgz -C /usr/java/
mv /usr/lib/firefox* /tmp
mv /usr/bin/firefox /tmp
tar -zxvf /opt/Packages/firefox-2.0.0.20.tar.gz -C /usr/lib
cd /usr/lib/firefox/plugins
ln -s /usr/java/jre1.6.0_22/plugin/i386/ns7/libjavaplugin_oji.so .
###############################################

########### Installing Microfocus ##############
mkdir -p /opt/microfocus/cobol
cp /opt/Packages/sx51_wp4_redhat_x86_64_dev.tar /opt/microfocus/cobol/
cd /opt/microfocus/cobol/
tar -xvif /opt/microfocus/cobol/sx51_wp4_redhat_x86_64_dev.tar
echo " "
echo "======================================================"
echo " Installing SOA, Kindly provide INPUT accordingly..."
echo "======================================================"
echo " "
./install
cp /etc/profile /etc/profile_org
cat /opt/Packages/profile >> /etc/profile
source /etc/profile
cd /opt/microfocus/mflmf/
echo "=================================================================================================================="
echo " Installing lisence, provide password as "redhat" and lisence file has been kept under /opt/Packages/.lisence.txt"
echo "=================================================================================================================="
./mflm_cmd
cobrun -F
if [ $? = 0 ]
then
	echo " "
	echo "============================"
	echo " SOA installed successfully"
	echo "============================"
	echo " "
 
else
	echo " "
	echo "======================================"
	echo " ERROR: kindly check SOA installation"
	echo "======================================"
	echo " "
fi
cp /opt/Packages/ESODBCXA.so /opt/microfocus/cobol/lib/
chown -R feapadmin.feapadmin /opt/SUNWappserver /logs /opt/microfocus/ /var/mfcobol/ /var/aslmfsem /var/mfaslmf/ /efeap/*
####################################################

mkdir -p /efeap/data/efeapdocs/hdocs
mkdir -p /efeap/data/app
chown -R feapadmin:feapadmin /efeap/data/efeapdocs/hdocs /efeap/data/app

echo " "
echo "======================================================================================================================"
echo "1) Change the SOA listener port as per document
      2) Install the tolic package
      3) Do Full-build patch deployment as per NON_DC-fullbuildpatch.pdf document and Insert mysql test dump sequentially from 1 to 6 provided by LIC with command
		mysql efeap < 1_dump.sql"
echo "======================================================================================================================"
echo " "
fi
