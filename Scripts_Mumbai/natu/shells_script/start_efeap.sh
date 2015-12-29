#!/bin/bash


#Getting hostnames
weba=$(echo $(hostname | cut -d "-" -f1,2)-WEBA)
webb=$(echo $(hostname | cut -d "-" -f1,2)-WEBB)
appa=$(echo $(hostname | cut -d "-" -f1,2)-APPA)
appb=$(echo $(hostname | cut -d "-" -f1,2)-APPB)
dbsa=$(echo $(hostname | cut -d "-" -f1,2)-DBSA)
dbsb=$(echo $(hostname | cut -d "-" -f1,2)-DBSB)
bkpa=$(echo $(hostname | cut -d "-" -f1,2)-BKPA)
dbsr=$(echo $(hostname | cut -d "-" -f1,2)-DBSR)


rgman_stop()
{
        ssh -T -o StrictHostKeyChecking=no "$1" <<_EOF_

       /etc/init.d/rgmanager status   
       if [ $? -eq 0 ]
       then 
               echo "Stopping rgmanager in  "$1" "
               echo " /etc/init.d/rgmanager stop..."
		if [ $? -eq 0 ]
                then
                    echo " rgmanager stopped sucessfully"
                else
                    echo "rgmanager not getting stopped pls contact infra"
                fi   
       else 
               echo "rgmanager is not currenty running "
       fi
_EOF_
}


cman_stop()
{
        for i in $1 $2
        do
	ssh -T -o StrictHostKeyChecking=no "$i" <<_EOF_
        
        /etc/init.d/rgmanager status
        if [ $? -eq 0 ]
        then
          echo " /etc/init.d/rgmanager stop ..."
            echo "stopping rgmanager"
        else     	
            etc/init.d/cman status   
            if [ $? -eq 0 ]
	         then 
	                echo "stopping cman "
        	       echo "/etc/init.d/cman stop...."
                       if [ $? -eq 0 ]
                       then
                            echo "cman sucessfully stopped"
                       else
                            echo "unable to stop Cman contact infra"
                       fi
             fi
        fi
_EOF_

       done
}

cman_status()
{
	ssh -T -o StrictHostKeyChecking=no $1 <<_EOF_

        [[ "$(/etc/init.d/cman status | grep dead)" ]] && echo "cman is dead Please hardreboot the server "$1" " || echo "cman running"


_EOF_
}

rgman_start()
{
	ssh -T -o StrictHostKeyChecking=no $1 <<_EOF_
	/etc/init.d/rgmanager status | grep running

	if [ $? -eq 0 ]
	then
		 echo " Unable to start rgmanager its alreadys running"
        else
                 /etc/init.d/cman status
                 if [ $? -eq 0 ]
                 then  
                      [[ $(/etc/init.d/mysql status | grep "/var/lock/subsys/mysql") ]] && rm /var/lock/subsys/mysql    	       
                      [[ $(lvscan | grep  "ACTIVE") ]] && echo " found lvs are active in "$1" Please contact infra $(exit) "
	               echo "Starting rgmanager "
		      echo "/etc/init.d/rgmanager start ..."
                       sleep 15
                       [[ $(/etc/init.d/mysql status | grep running ) ]]  && echo "Mysql started " || echo "Mysql not started in "$1" "
                       [[ $(lvscan | grep  "inactive")  ]] && echo " found lvs are inactive while starting rgmanager in "$1" pls contact infra $(exit) "
                       /etc/init.d/rgmanager status
                       if [ $? -eq 0 ]
                       then
                            echo "rgmanager started sucessfully in "$1""
                       else
                            echo "rgmanager not getting start in "$1" pls contact infra "
                        fi

                else
                     echo "Please check the cman service in "$1""
                     exit 0

               fi   

       fi
_EOF_
}

cman_start()
{
        
        for i in $1 $2
        do
	ssh -T -o StrictHostKeyChecking=no $i <<_EOF_
        /etc/init.d/rgmanager status
        if [ $? -eq 0 ]
        then
            echo  "rgmanager not stopped "$1" pls contact infra"
        else    
	        /etc/init.d/cman status 
	        if [ $? -eq 0 ]
	        then
		             echo " cman is already running in "$1""
	        else
		             echo "Starting cman in "$1" "
                 	    echo "/etc/init.d/cman start..."
	                    if [ $? -eq 0 ]
	                    then
		                         echo "cman sucessfully started in "$1""
	                    else
		                        echo "cman not getting started in "$1" Please contact infra"  
	                   
		            fi   
                 fi
        fi              

_EOF_
      done

}


echo " Please choose "
echo " 1) Stop Cluster"
echo " 2) Start Cluster"



read input

case "$input"  in

	1 )	#Stopping cluster status
		cman_status "$dbsa"  
		cman_status "$dbsb"  

                #stopping rgmanager

		active_clust=$(ssh -T -o StrictHostKeyChecking=no "$dbsa" clustat | grep started | awk '{print $2}' | awk -F'-' '{print $3}')
                echo "$active_clust"

		if [ "$active_clust" == DBSA ]
		then
			cman_status "$dbsb"                
                        rgman_stop "$dbsb"
		else
                        cman_status "$dbsa"
 			rgman_stop "$dbsa"
		fi
  
                #stopping cman
	
                cman_stop "$dbsa" "$dbsb"

	   ;;

	2 )   #Starting cluster
               
               cman_start "$dbsa" "$dbsb"
               rgman_start "$dbsa"
               rgman_start "$dbsb"

              
           ;;

esac 





   
    










