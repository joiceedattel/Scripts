#!bin/bash

if [ "$(id -u)" -ne "0" ]
  then
	echo "Please login as Root User "
   exit
fi

#collecting hostname

lhost=$(hostname)
rhost_appb=$(echo "$lhost" | sed 's/APPA/APPB/')
rhost_weba=$(echo "$lhost" | sed 's/APPA/WEBA/')
rhost_webb=$(echo "$lhost" | sed 's/APPA/WEBB/')
rhost_bkpa=$(echo "$lhost" | sed 's/APPA/BKPA/')

echo " Please enter the Database SRV IP Address"
read dbip

#Setting VM BASE SRV IP
baseip="$(echo "$(hostname -i | cut -d "." -f1-3)")"
#appabase="$(echo $baseip.141)"
#appbbase="$(echo $baseip.143)"
webabase="$(echo $baseip.131)"
webbbase="$(echo $baseip.133)"

if [ -e /root/.ssh/id_rsa.pub ]
then
echo " SSH_KeyGen found "
else
echo "SSH_Keygen not found , So creating new Key_gen"
ssh-keygen
fi


for i in $lhost $rhost_weba $rhost_webb $rhost_appb  
  do 
#APPA
       echo " "
       if [ "$i" == "$lhost" ]
       then

     
		echo " "
		echo "============================"
                echo " Checking Feapadmin ID Details" 
		echo "============================="
               echo " "
	       echo "Checking Feapadmin User details in "$i" Server "
 	       APPA_UID=$(id feapadmin | cut -d '(' -f1 | cut -d '=' -f2) 
	       APPA_GID=$(id feapadmin | cut -d '(' -f2 | cut -d "=" -f2) 
                        
			if [ "$APPA_UID" == "501" ] && [ "$APPA_GID" == "501" ]
			then
				echo " APPA Feapadmin UID and GID is OK "
			else
				echo " Error : The APPA Feapadmin UID and GID is not 501"
			fi
sleep 3
		echo "========================"
		echo " Cheking Services status on $i "
	        echo "======================== "

                   for i in nfslock portmap ntpd rpcidmapd libvirtd haldaemon messagebus
                   do
                     l2=$(chkconfig --list nfs | awk '{print $4}' | cut -d ':' -f2)
                     l3=$(chkconfig --list nfs | awk '{print $5}' | cut -d ':' -f2)
                     l4=$(chkconfig --list nfs | awk '{print $6}' | cut -d ':' -f2)
                     l5=$(chkconfig --list nfs | awk '{print $7}' | cut -d ':' -f2)
                       
                     if [ "$l2" == 'on' ] && [ "$l3" == 'on' ] && [ "$l4" == 'on' ] && [ "$l5" == 'on' ]
	                      then
                              echo " The $i Service is ON Runlevel :2345"
			      echo " "	
                              else
                              echo " The $i Service is OFF in Runlevel :2345 "
                              echo " "
                     fi 
                          
                   done 
                echo "  "
                sleep 3
		echo "====================================== "  
	        echo " Checking ODBC.ini File in $i Server "
	        echo "====================================== " 
                echo " "
	        odbcuser=$(cat /etc/odbc.ini | grep  -FA9 '[efeap]' | egrep User |cut -d "=" -f2 | sed 's/ //')
	        odbcpass=$(cat /etc/odbc.ini | grep  -FA9 '[efeap]' | egrep Password |cut -d "=" -f2 | sed 's/ //')
	        odbcip=$(cat /etc/odbc.ini | grep  -FA9 '[efeap]' | egrep Server |cut -d "=" -f2 | sed 's/ //')
                	
 			if [ "$odbcuser" == 'feapadmin_db' ] && [ "$odbcpass" == 'feapadmin_db' ] && [ "$odbcip" == $dbip ]
                        then
                           echo " The User,Password,Server in ODBC.ini under [efeap] is OK "
                        else
                           echo " Please check the entries of User,Password,Server in ODBC.ini under [efeap] "
                        fi            

#checking the odbcinst.ini file
                echo " "
                sleep 3 
		echo "======================================"
                echo " Checking odbcinst.ini File in $i Server " 
                echo "======================================" 
                echo " " 
                odbcinst_drv=$(cat /etc/odbcinst.ini | grep -FA5 '[MySQL]' | grep -F 'Driver' | grep -v "#" | cut -d '=' -f2 | sed s'/ //')
                odbcinst_desc=$(cat /etc/odbcinst.ini | grep -FA5 '[MySQL]' | grep 'Description' | cut -d '=' -f2 | sed s'/ //')
                odbcinst_setup=$(cat /etc/odbcinst.ini | grep -FA5 '[MySQL]' | grep 'Setup' | cut -d '=' -f2 | sed s'/ //')
                if [ "$odbcinst_drv" == "/usr/lib/libmyodbc5-5.1.7.so" ] && [ "$odbcinst_desc" == "ODBC for MySQL" ] && [ "$odbcinst_setup" == "/usr/lib/libmyodbc3S.so" ]
                then
                      echo " The Driver,Description,Setup entries under MySQL is CORRECT "
                else
                      echo " The Driver,Description,Setup entries under MySQL is WRONG " 
                fi


##checking the ODBC Softlinks
                echo "  "
                sleep 3
		echo "==============================="
                echo " checking ODBC file link Status "
                echo "==============================="
                odbc_lnc=$(ls -ltr /usr/lib/libmy* | wc -l)
                lnsource=$(ls -ltr /usr/lib/libmy* | grep ^l | awk '{print $9 }')
           	lndest=$(ls -ltr /usr/lib/libmy* | grep ^l | awk '{print $11 }')
	        if [ "$odbc_lnc" == 4 ] && [ "$lnsource" == '/usr/lib/libmyodbc5.so' ] && [ "$lndest" == '/usr/lib/libmyodbc5-5.1.7.so' ]
                then
                     echo " ODBC file Links and Counts ar CORRECT "
                else
                     echo "ODBC file Links and Counts are INCORRECT "
                fi

#Checking the /etc/profile file

		echo "==============================="
                echo " checking the /etc/pofile  file"
                echo "==============================="
                pro_entry=$(cat /etc/profile | grep -F 'ulimit -S -c 0 > /dev/null 2>&1')
                pro_entry1=$(cat /etc/profile | grep -F 'export HOSTNAMEAL')
                if [ "$pro_entry" == 'ulimit -S -c 0 > /dev/null 2>&1' ] 
####!!!!!!!#####   && [ "$pro_entry1" == 'export HOSTNAMEALS=`hostname | cut -d'-' -f2`' ]
                then 
                     echo "The Entries in /etc/pofile is CORRECT "
                else
                     echo "The Entries in /etc/pofile is INCORRECT "   
                fi 

#Checking /etc/sysctl.conf file


               kern_sem=$(cat /etc/sysctl.conf | grep -F 'kernel.sem' | grep -v "#")
               sysctl_p=$(cat /etc/rc.local | grep -F 'sysctl -p /etc/sysctl.conf')
            
		echo "==================================================="
		echo " Checking the kernel.sem Entries in /etc/sysctl.conf"
		echo "==================================================="

               if [ "$kern_sem" == 'kernel.sem = 7010 841280 7010 384' ] 
               then
		     echo  " The Kernel.sem entry in /etc/sysctl.conf is CORRECT "
               else
                    echo " The Kernel.sem value in /etc/sysctl.conf is WRONG  "
                    echo "Current value for Kernel.sem is "$kern_sem" "
               fi 
  
		echo  "=============================================="
                echo  "Checking the sysctl entry in /etc/rc.local"
		echo  "=============================================="

		 		 

               if [ "$sysctl_p" == 'sysctl -p /etc/sysctl.conf' ]
               then 
  		     echo " The Entry in /etc/rc.local is CORRECT "
               else
                    echo " The Entry in /etc/rc.local for sysctl.conf is WRONG"     
               fi 

#Checking Java version

               echo "============================="
               echo " Please verify the Java Vesrion"
               java -version 	       
               echo "============================="
		
#checking Root Partation size
                 echo "  "
                 root_siz=$(df -Ph | grep -v Filesystem | grep /$ | awk '{print $5}' | cut -d '%' -f1)
                 if [ "$root_siz" -le 50 ]
                 then
                      echo " The Root Partation size is NORMAL"
		      echo " " 
                 else 
                      echo " The Root Paration size need to be REDUCED"
                      echo " "  
                 fi


#Checking libevent file
	       echo "====================================="
                echo "Checking libevent rpm "
               echo "====================================="
		lib_rpm=$(rpm -qa | grep -i libevent)
                if [ "$lib_rpm" == 'libevent-1.4.13-1' ]
                then
		      echo " The libevent RPM  is PROPER "
                      echo " " 
 		else
                      echo " The libevent RPM  is NOT PROPER "
		      echo " " 
                fi 


#Checking NFS Packages
		echo "=============================="
		 echo "Checking the NFS Packages "                
		echo "=============================="
                nfs_rpm1=$(rpm -qa | grep -i nfs-utils | head -1)
                nfs_rpm2=$(rpm -qa | grep -i nfs-utils | tail -1)
                if [ "$nfs_rpm1" == 'nfs-utils-lib-1.0.8-7.6.el5' ] && [ "$nfs_rpm2" == 'nfs-utils-1.0.9-54.el5' ]
                    then
                       echo " The NFS Packages are installed PROPERELY"
                        rpm -qa | grep -i nfs-utils
                    else
                       echo " The NFS Packages are installed are NOT PROPER Please check versions " 
                     fi


##checking Demidecode BIOS  Revision
               dmic=$(dmidecode --type 0 | grep Revision | cut -d ":" -f2 | sed s'/ //')
                if [ "$dmic" == '8.15' ]
                  then
                       echo "BIOS Revision is CORRECT "
                  else
                       echo " BIOS Revision is INCORRECT "
               fi
  

#Mysql uid
		mysqluid=$(id mysql | cut -d '(' -f1 | cut -d '=' -f2)
#Mysql Gid
                mysqlgid=$(id mysql | cut -d '(' -f2 | cut -d "=" -f2)
                if [ "$mysqluid" == '27' ] && [ "$mysqlgid" == '27' ]
                   then
		       echo " The Mysql UID and GID is CORRECT " 
                   else
                       echo " The Mysql UID and GID is INCORRECT "
                fi




       elif [ "$i" == "$rhost_appb" ] 
       then  
           echo " Checking APPB Server "  

#####################################  APPB SERVER   ##################################


           ssh -T -o PasswordAuthentication=no "$i" echo "   "
           if [ "$?" -ne '0' ]
           then
                 ssh-copy-id -i /root/.ssh/id_rsa.pub "$i" 
           else

                echo " Logging and Checking  $i Server  ..............."

                ssh -T -o StrictHostKeyChecking=no "$i"  # <<_EOF_

                echo " "
                echo "============================"
                echo " Checking Feapadmin ID Details" 
                echo "============================="
                   echo " "
                  echo "Checking Feapadmin User details in "$i" Server "
                  export APPB_UID=$(id feapadmin | cut -d '(' -f1 | cut -d '=' -f2)
                  export APPB_GID=$(id feapadmin | cut -d '(' -f2 | cut -d "=" -f2)

                        if [ "\$APPA_UID" == "501" ] && [ "\$APPA_GID" == "501" ]
                        then
                                echo " APPA Feapadmin UID and GID is OK "
                        else
                                echo " Error : The APPA Feapadmin UID and GID is not 501"
                        fi
sleep 3
                echo "========================"
                echo " Cheking Services status on $i "
                echo "======================== "

                   for i in nfslock portmap ntpd rpcidmapd libvirtd haldaemon messagebus
                   do
                    export l2=$(chkconfig --list nfs | awk '{print $4}' | cut -d ':' -f2)
                    export l3=$(chkconfig --list nfs | awk '{print $5}' | cut -d ':' -f2)
                    export l4=$(chkconfig --list nfs | awk '{print $6}' | cut -d ':' -f2)
                    export l5=$(chkconfig --list nfs | awk '{print $7}' | cut -d ':' -f2)

                     if [ "\$l2" == 'on' ] && [ "\$l3" == 'on' ] && [ "\$l4" == 'on' ] && [ "\$l5" == 'on' ]
                              then
                              echo " The $i Service is ON Runlevel :2345"
                              echo " "  
                              else
                              echo " The $i Service is OFF in Runlevel :2345 "
                              echo " "
                     fi

                   done
                echo "  "
                sleep 3

               echo "====================================== "  
                echo " Checking ODBC.ini File in $i Server "
               echo "====================================== " 
                echo " "
                 export odbcuser=$(cat /etc/odbc.ini | grep  -FA9 '[efeap]' | egrep User |cut -d "=" -f2 | sed 's/ //')
                 export odbcpass=$(cat /etc/odbc.ini | grep  -FA9 '[efeap]' | egrep Password |cut -d "=" -f2 | sed 's/ //')
                 export odbcip=$(cat /etc/odbc.ini | grep  -FA9 '[efeap]' | egrep Server |cut -d "=" -f2 | sed 's/ //')

                        if [ "\$odbcuser" == 'feapadmin_db' ] && [ "\$odbcpass" == 'feapadmin_db' ] && [ "\$odbcip" == $dbip ]
                        then
                           echo " The User,Password,Server in ODBC.ini under [efeap] is OK "
                        else
                           echo " Please check the entries of User,Password,Server in ODBC.ini under [efeap] "
                        fi

#checking the odbcinst.ini file
                echo " "
                sleep 3
                echo "======================================"
                echo " Checking odbcinst.ini File in $i Server " 
                echo "======================================" 
                echo " " 
                export odbcinst_drv=$(cat /etc/odbcinst.ini | grep -FA5 '[MySQL]' | grep -F 'Driver' | grep -v "#" | cut -d '=' -f2 | sed s'/ //')
                export odbcinst_desc=$(cat /etc/odbcinst.ini | grep -FA5 '[MySQL]' | grep 'Description' | cut -d '=' -f2 | sed s'/ //')
                export odbcinst_setup=$(cat /etc/odbcinst.ini | grep -FA5 '[MySQL]' | grep 'Setup' | cut -d '=' -f2 | sed s'/ //')
                if [ "\$odbcinst_drv" == "/usr/lib/libmyodbc5-5.1.7.so" ] && [ "\$odbcinst_desc" == "ODBC for MySQL" ] && [ "\$odbcinst_setup" == "/usr/lib/libmyodbc3S.so" ]
                then
                      echo " The Driver,Description,Setup entries under MySQL is CORRECT "
                else
                      echo " The Driver,Description,Setup entries under MySQL is WRONG " 
                fi


##checking the ODBC Softlinks
                echo "  "
                sleep 3
                echo "==============================="
                echo " checking ODBC file link Status "
                echo "==============================="
                export odbc_lnc=$(ls -ltr /usr/lib/libmy* | wc -l)
                export lnsource=$(ls -ltr /usr/lib/libmy* | grep ^l | awk '{print $9 }')
                export lndest=$(ls -ltr /usr/lib/libmy* | grep ^l | awk '{print $11 }')
                if [ "\$odbc_lnc" == 4 ] && [ "\$lnsource" == '/usr/lib/libmyodbc5.so' ] && [ "\$lndest" == '/usr/lib/libmyodbc5-5.1.7.so' ]
                then
                     echo " ODBC file Links and Counts ar CORRECT "
                else
                     echo "ODBC file Links and Counts are INCORRECT "
                fi

                #Checking the /etc/profile file

                echo "==============================="
                echo " checking the /etc/pofile  file"
                echo "==============================="
                export pro_entry=$(cat /etc/profile | grep -F 'ulimit -S -c 0 > /dev/null 2>&1')
                export pro_entry1=$(cat /etc/profile | grep -F 'export HOSTNAMEAL')
                if [ "\$pro_entry" == 'ulimit -S -c 0 > /dev/null 2>&1' ]
####!!!!!!!#####   && [ "$pro_entry1" == 'export HOSTNAMEALS=`hostname | cut -d'-' -f2`' ]
                then
                     echo "The Entries in /etc/pofile is CORRECT "
                else
                     echo "The Entries in /etc/pofile is INCORRECT "   
                fi

#Checking /etc/sysctl.conf file


               export kern_sem=$(cat /etc/sysctl.conf | grep -F 'kernel.sem' | grep -v "#")
               export sysctl_p=$(cat /etc/rc.local | grep -F 'sysctl -p /etc/sysctl.conf')

                echo "==================================================="
                echo " Checking the kernel.sem Entries in /etc/sysctl.conf"
                echo "==================================================="

               if [ "\$kern_sem" == 'kernel.sem = 7010 841280 7010 384' ]
               then
                     echo  " The Kernel.sem entry in /etc/sysctl.conf is CORRECT "
               else
                    echo " The Kernel.sem value in /etc/sysctl.conf is WRONG  "
                    echo "Current value for Kernel.sem is "\$kern_sem" "
               fi

                echo  "=============================================="
                echo  "Checking the sysctl entry in /etc/rc.local"
                echo  "=============================================="



               if [ "\$sysctl_p" == 'sysctl -p /etc/sysctl.conf' ]
               then
                     echo " The Entry in /etc/rc.local is CORRECT "
               else
                    echo " The Entry in /etc/rc.local for sysctl.conf is WRONG"     
               fi

               #Checking Java version

               echo "============================="
               echo " Please verify the Java Vesrion"
               java -version
               echo "============================="

#checking Root Partation size
                 echo "  "
                 export root_siz=$(df -Ph | grep -v Filesystem | grep /$ | awk '{print $5}' | cut -d '%' -f1)
                 if [ "\$root_siz" -le 50 ]
                 then
                      echo " The Root Partation size is NORMAL"
                      echo " " 
                 else
                      echo " The Root Paration size need to be REDUCED"
                      echo " "  
                 fi


#Checking libevent file
               echo "====================================="
                echo "Checking libevent rpm "
               echo "====================================="
               export lib_rpm=$(rpm -qa | grep -i libevent)
                if [ "\$lib_rpm" == 'libevent-1.4.13-1' ]
                then
                      echo " The libevent RPM  is PROPER "
                      echo " " 
                else
                      echo " The libevent RPM  is NOT PROPER "
                      echo " " 
                fi


#Checking NFS Packages
                echo "=============================="
                 echo "Checking the NFS Packages "                
                echo "=============================="
                export nfs_rpm1=$(rpm -qa | grep -i nfs-utils | head -1)
                export nfs_rpm2=$(rpm -qa | grep -i nfs-utils | tail -1)
                if [ "\$nfs_rpm1" == 'nfs-utils-lib-1.0.8-7.6.el5' ] && [ "\$nfs_rpm2" == 'nfs-utils-1.0.9-54.el5' ]
                    then
                       echo " The NFS Packages are installed PROPERELY"
                        rpm -qa | grep -i nfs-utils
                    else
                       echo " The NFS Packages are installed are NOT PROPER Please check versions " 
                     fi

##checking Demidecode BIOS  Revision
              export dmic=$(dmidecode --type 0 | grep Revision | cut -d ":" -f2 | sed s'/ //')
                if [ "\$dmic" == '8.15' ]
                  then
                       echo "BIOS Revision is CORRECT "
                  else
                       echo " BIOS Revision is INCORRECT "
               fi


#Mysql uid
                export mysqluid=$(id mysql | cut -d '(' -f1 | cut -d '=' -f2)
#Mysql Gid
               export  mysqlgid=$(id mysql | cut -d '(' -f2 | cut -d "=" -f2)
                if [ "\$mysqluid" == '27' ] && [ "\$mysqlgid" == '27' ]
                   then
                       echo " The Mysql UID and GID is CORRECT " 
                   else
                       echo " The Mysql UID and GID is INCORRECT "
                fi


_EOF_

          fi 

fi

done





#            
#                echo "The output for the "$i" server is "
#                echo " "
#                echo "$out" 
#		echo java_version is $(echo $$out |grep `
##          
#                fi
##         else                  
###WEBA / WEBB
##                 echo " Logging and Checking  $i Server  ..............."
##                 echo "$i "
##                 ssh -T -o PasswordAuthentication=no "$i" echo "   "
##                 if [ "$?" -ne '0' ]
##                 then
##                 ssh-copy-id -i /root/.ssh/id_rsa.pub "$i"
##                 else
##
##		 out="$(ssh -T -o StrictHostKeyChecking=no "$i" <<_EOF_
##
##			echo "The Feapadmin User ID of "$i" "
##			id feapadmin | cut -d '(' -f1 | cut -d '=' -f2	
##			echo "The Feapadmin Group ID of "$i" " 
##			id feapadmin | cut -d '(' -f2 | cut -d "=" -f2
##
##sleep 2
##			echo " Cheking necessery Services status "
##		        echo " "
##			chkconfig --list | grep nfslock
##			chkconfig --list | grep portmap
##			chkconfig --list | grep ntpd
##			chkconfig --list | grep rpcidmapd
##		        echo " "  
##
##
##
##
##
##
##
##
##_EOF_
##)"
##
##
##			echo "The output for the "$i" server is "
##			echo " "
##			echo "$out" 
##
##                 fi 
#            fi  
#done
#
#
##for i in $appabase $appbbase 
##
##do
##
##                 ssh -T -o PasswordAuthentication=no "$i" echo "   "
##                 if [ "$?" -ne '0' ]
##                 then
##                 echo " Copying SSH_Key"
##                 ssh-copy-id -i /root/.ssh/id_rsa.pub "$i"
##                 else
##  
##                 lvmout="$(ssh -T -o StrictHostKeyChecking=no "$i" <<_EOF_
##                 echo "Checking /etc/lvm/lvm.conf file in "$i"Server "
##   
##                 grep -F 'filter = [ "a/.*/" ]' /etc/lvm/lvm.conf | grep -v "#"
##		 echo $?
##                	if [ "$?" -eq '0' ]
##			then
##   		       	        echo " Entry of "filter = [ "a/.*/" ]" is present in /etc/lvm/lvm.conf of "$i" "
##	       		else	
## 		                 echo "Please check  "filter = [ "a/.*/" ]" line is commented # or make an entry  in /etc/lvm/lvm.conf of "$i" "
##                	fi 
##_EOF_
##)"
##                 fi	      
##                 echo "$lvmout" "$i"
##
##                
## done
##
##
##
