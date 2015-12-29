#!/bin/bash
#. /tmp/infrascript/efeap_function 


#Error codes
#   err_101 ---> CMAN DEAD
#   err_102 ---> RGMANAGER DEAD
#   err_10  ---> Wrong Host
	


#Function declaration     
#checking cman status 
cman_check()
	{
	
	for i in DBSA DBSB
	do	
 	eval pass=$(echo "$"$i"P")
        eval i=$(echo "$"$i)	

        expect -c "                      
		spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" {
		sh /tmp/efeap_function cman_status
                }
		expect \"password:*\"
                send \"$pass\r\"
         	interact "

exit_status="$(expect -c "
                spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" { cat /tmp/error.txt 
                echo > /tmp/error.txt
 		}
                expect \"password:*\"
                send \"$pass\r\"
                interact " 
                )"

                [[ $(echo $exit_status | grep err_101) ]] && echo "Unable to proceed ...Cluster Manager not running in "$i" ..."  && exit  
	done
	}


#Checking rgman status
rgman_check()
	{

	for i in DBSA DBSB
	do
	eval pass=$(echo "$"$i"P")
        eval i=$(echo "$"$i)	
        expect -c "                      
		spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" {
		sh /tmp/efeap_function rgman_status
                }
		expect \"password:*\"
                send \"$pass\r\"
        	interact "
 
exit_status="$(expect -c "
                spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" { cat /tmp/error.txt 
                echo > /tmp/error.txt
		}
                expect \"password:*\"
                send \"$pass\r\"
                interact " 
                )"
		echo " the exit status is  $exit_status "

	                [[ $(echo $exit_status | grep err_102) ]] && echo "Unable to proceed ...Rgmanager Manager not running in active cluster node "$i" ..."  && exit  
	done
	}


active_cluster()
{

active_clust="$(expect -c "  
		spawn -noecho ssh -T -o StrictHostKeyChecking=no "$cluster_ip" { clustat 
		echo > /tmp/error.txt
		sh /tmp/efeap_function rgman_postdo
		cat /tmp/error.txt
		echo > /tmp/error.txt
		} 
		expect \"password:*\"
		send \"$DBSAP\r\"
		interact 
		expect \"password:*\"
		send \"$DBSBP\r\"
		interact "
                )"

		active_clust_node=$(echo "$active_clust" | grep "service:SRV1" | awk '{print $2}' | awk -F'-' '{print $3}')

        	echo "================================================"
		echo "The current active cluster node is $active_clust_node"
        	echo "================================================"
	
		echo "Confirming rgmanager Service resources in active cluster $active_clust_node"
		
		[[ $(echo $active_clust | grep err_105) ]] && echo "LVs/Mysql not running" && exit || echo "LVs and MYSQL are found ok in active cluster "$active_clust_node""




}
#Stopping rgmanager
        	        
stop_cluster()
	{
		if [ "$active_clust_node" == DBSA ]
                then
                 expect -c "                      
 				spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$DBSB" {
				sh /tmp/efeap_function rgman_stop
				sh /tmp/efeap_function rgman_postdo 
				 }
				expect \"password:*\"
	        	        send \"$DBSBP\r\"
	                	interact "

        	 expect -c "                      
 				spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$DBSA" {
				sh /tmp/efeap_function rgman_stop
				sh /tmp/efeap_function rgman_postdo 
                		}
				expect \"password:*\"
        		        send \"$DBSAP\r\"
                		interact "
                else
	        expect -c "                      
 				spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$DBSA" {
				sh /tmp/efeap_function rgman_stop 
				sh /tmp/efeap_function rgman_postdo 
                		}
				expect \"password:*\"
	        	        send \"$DBSAP\r\"
        	        	interact "
                expect -c "                      
 				spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$DBSB" {
				sh /tmp/efeap_function rgman_stop 
				sh /tmp/efeap_function rgman_postdo 
                		}
				expect \"password:*\"
        	       		send \"$DBSBP\r\"
                		interact "
                fi
		
		for i in DBSA DBSB
		do
				
		eval pass=$(echo "$"$i"P")
 	        eval i=$(echo "$"$i)	
                rgstop_stat=$(expect -c "                      
 					spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" {
					cat /tmp/error.txt
					echo > /tmp/error.txt
	                		}
					expect \"password:*\"
	        			send \"$pass\r\"
        	        		interact "
					)
		[[ $(echo $rgstop_stat | grep err_105) ]] && echo "RGMANAGER Stopped sucessfully in "$i" " || echo "RGMANAGER are  not properely stopped in "$i" " 

		done
		
               #Stopping Cluster
		for i in DBSA DBSB
	        do              
	        eval pass=$(echo "$"$i"P")
         	eval i=$(echo "$"$i)    
	        expect -c "                      
        	        spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" {
                	sh /tmp/efeap_function cman_stop 
                	}
              		expect \"password:*\"
	                send \"$pass\r\"
	                interact "
#               sleep 3
#               send -- "d"
        done
	
 

        }

        
#Starting cluster
cluster_start()
	{
                echo "Starting Cluster"

	for i in DBSA DBSB
	do		
	eval pass=$(echo "$"$i"P")
        eval i=$(echo "$"$i)	
       	expect -c "                      
		spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" {
     		sh /tmp/efeap_function cman_start 
                }
     		expect \"password:*\"
                send \"$pass\r\"
		interact 
		"
	done
        echo "cman starting in background in DBSA & DBSB Servers"
	sleep 15
	
	
        for i in DBSA DBSB
	do	
	eval pass=$(echo "$"$i"P")
        eval i=$(echo "$"$i)	
     	rg_error=$(expect -c "                      
      		spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" {
		sh /tmp/efeap_function rgman_predo
                cat /tmp/error.txt
		echo >/tmp/error.txt
		}
     		expect \"password:*\"
     	        send \"$pass\r\"
        	interact "
		)
		
		[[ $(echo "$rg_error" | grep err_104) ]] && echo "Unable to proceed ...Found LVs are in active state " && exit
         
        done
                        #Starting rgmanager

	for i in DBSA DBSB
        do
        eval pass=$(echo "$"$i"P")
        eval i=$(echo "$"$i)

	     	expect -c "                      
      			spawn -noecho ssh -T -o  StrictHostKeyChecking=no root@"$i" {
	     		sh /tmp/efeap_function rgman_start
			sleep 15
               		 }
	     		expect \"password:*\"
        	        send \"$pass\r\"
        	       	interact "

	done

	}


#Stopping SOA

stop_soa()
	{
	for i in APPA APPB
	do
	eval pass=$(echo "$"$i"FP")
        eval i=$(echo "$"$i)	
        expect -c "                      
                spawn -noecho ssh -T -o  StrictHostKeyChecking=no feapadmin@"$i" {
                sh /tmp/efeap_function soa_stop
		sleep 3
		sh /tmp/efeap_function soa_check
                }
                expect \"password:*\"
                send \"$pass\r\"
                interact "
		
soa_stat=$(expect -c "                      
                        spawn -noecho ssh -T -o  StrictHostKeyChecking=no feapadmin@"$i" {
                        cat /tmp/error.txt
                        echo >/tmp/error.txt
                        }
                        expect \"password:*\"
                        send \"$pass\r\"
                        interact "
                        )

	[[ $(echo $soa_stat | grep cassi_err_106) ]] && echo "cassi stopped sucessfully "$i" " || echo "ERROR : Stopping cassi is failed in  "$i" "  
	[[ $(echo $soa_stat | grep mfds_err_106) ]] && echo "MFDS stopped sucessfully "$i" " || echo "ERROR : Stopping mfds is failed in "$i" " 
	[[ $(echo $soa_stat | grep eslm_err_106) ]] && echo "ESLM stopped sucessfully "$i" " || echo "ERROR : Stopping ESLM is failed in "$i" "  
	
        done

	}

#Starting SOA
start_soa()
	{
	for i in APPA APPB
	do
	eval pass=$(echo "$"$i"FP")
        eval i=$(echo "$"$i)	
	
soa_stat=$(expect -c "                      
                       spawn -noecho ssh -T -o  StrictHostKeyChecking=no feapadmin@"$i" {
			echo > /tmp/error.txt
			sh /tmp/efeap_function soa_check
                        cat /tmp/error.txt
                        echo > /tmp/error.txt
                        }
                        expect \"password:*\"
                        send \"$pass\r\"
                        interact "
                        )

#        [[ $(echo $soa_stat | grep mfds_err_106) ]] && echo "Found MFDS stopped in "$i" " || echo "ERROR : Found MFDS already running in "$i" " 
#        [[ $(echo $soa_stat | grep eslm_err_106) ]] && echo "Found ESLM stopped in "$i" " || echo "ERROR : Found ESLM already running in "$i" "               
#        [[ $(echo $soa_stat | grep cassi_err_106) ]] && echo "Found cassi stopped in "$i" " || echo "ERROR : Found cassi already running in "$i" " 

	expect -c "                      
                spawn -noecho ssh -T -o  StrictHostKeyChecking=no feapadmin@"$i" {
                sh -x /tmp/efeap_function soa_start
                }
                expect \"password:*\"
                send \"$pass\r\"
                interact "
echo "................Checking the SOA Stauts.............................."


soa_stat=$(expect -c "                      
                        spawn -noecho ssh -T -o  StrictHostKeyChecking=no feapadmin@"$i" {
                        echo >/tmp/error.txt
                        sh /tmp/efeap_function soa_check
                        cat /tmp/error.txt
                        echo >/tmp/error.txt
                        }
                        expect \"password:*\"
                        send \"$pass\r\"
                        interact "
                        )

	[[ $(echo $soa_stat | grep cassi_err_106) ]] && echo "SOA Services not started sucessfully "$i" " && exit 
	[[ $(echo $soa_stat | grep cassi_err_106) ]] && echo "SOA Services not started sucessfully "$i" " && exit 
	[[ $(echo $soa_stat | grep mfds_err_106) ]] && echo "SOA Services not started sucessfully "$i" " && exit 
	
	done


	}






#---  Main Script ---- #


#----Collecting Password & Assigning Hostnames


APPAFP=feapadmin
APPBFP=feapadmin

for i in APPA APPB WEBA WEBB DBSA DBSB DBSR BKPA 
#
do
        eval $(echo $(hostname) | sed "s/....$/$i/"|cut -d'-' -f3)=$(echo $(hostname) | sed "s/....$/$i/")
#        echo -n "Please enter the Password for "$i" :"
#        read -s $(echo "$i"P)
#	eval pass=$(echo "$"$i"P")
#        eval i=$(echo "$"$i)	
#
#a=$(expect  -c"
#       spawn -noecho  ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1  root@$i hostname
#               expect \"password:*\"
#                send \"$pass\r\"
#                interact "
#               )
#	echo "$a" | grep -i "$i"
#	if [ $? -ne 0 ]
#	then
#	echo " Password wrong Plese enter the correct password for $i"
#	fi
#  
done

cluster_ip=MYSQL$(hostname | cut -d"-" -f2)
#NOTE:-
#password will be $APPAP $APPBP $WEBAP ... 

APPAP="sdc@appa"
APPBP="sdc@appb"
WEBAP="sdc@weba"
WEBBP="sdc@webb"
DBSAP="sdc@dbsa"
DBSBP="sdc@dbsb"
DBSRP="sdc@dbsr"
BKPAP="sdc@bkpa"







echo " EFEAP SCRIPT "
echo " 1 - Start all Services"
echo " 2 - Stop all Services"
echo " 3 - Stop Cluster"
echo " 4 - Start Cluster"
echo " 5 - Stop & Start DB Cluster"
echo " 6 - Start SOA"
echo " 7 - Stop SOA"
echo " 8 - Stop & Start SOA"

echo -n " Please Enter the no of your choice : "
read input

case "$input"  in

	1) #Starting all services
		echo "Script under construction"
	;;

	2) #Stopping all services
		echo "script under constrction"
	
	;;

	3) #Stopping Cluster
  		cman_check 
	       	active_cluster	 
	        stop_cluster "$DBSA" "$DBSB"
        ;; 
   	
	4) #Starting Cluster
        	cluster_start 
		active_cluster
       	;;

	5) #Stop & Start Cluster
		cman_check 
	 	rgman_check
        	stop_cluster "$DBSA" "$DBSB"
		cluster_start "$DBSA" "$DBSB"
        ;; 
	
	6) #Starting SOA
		start_soa
	;;		
	
	7) #Stopping SOA
		stop_soa
	;;			
		
	8) #Stop & Start SOA 
		stop_soa
		start_soa
		
	;;	

esac
