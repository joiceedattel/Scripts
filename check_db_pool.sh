#!/bin/bash

# Print Usage and Exit

PROGNAME="$0"

print_usage () {

  echo "Usage: $PROGNAME -h <IP_Adress> -p <port_number> -w <Warning> -c <Critical>"

  exit 1

}



# Check for all the Inputs from User

if [[ $# -lt 8 ]];then

        print_usage



fi



# Set All the Variables as per the Input

while getopts h:p:w:c: option ; do

        case $option in

                h) IP_Adress=$OPTARG;;

                p) port_number=$OPTARG;;

                w) warn=$OPTARG;;

                c) crit=$OPTARG;;

        esac

done


# The command to issue to jmxterm to return a value...

JMXTERM_CMD="get -b datasource=DataSources,tenantscope=Master\ Tenant -d hybris NumPhysicalOpen"

# Invoking jmxterm non-interactively to get the value...


NumPhysicalOpen=$(echo $JMXTERM_CMD | \java -jar /home/joice/Downloads/jmxterm-1.0-alpha-4-uber.jar \    -l $IP_Adress:$port_number -v silent -n)

#Filtering Section

value=`echo $NumPhysicalOpen|awk '{print $3}'|cut -d ";"  -f1`

 if [ $value -lt $warn ];then

        echo "OK - Current jdbc connection pool is $value | NumPhysicalOpen_value=$val;$warn;$crit;0;50"

        exit 0

else if [ $value -lt $crit ] && [ $value -gt $warn ];then

        echo "Warning - Current jdbc connection pool is $value | NumPhysicalOpen_value=$val;$warn;$crit;0;50"
        exit 1

else

        echo "Critical - Current jdbc connection pool is $value | NumPhysicalOpen_value=$val;$warn;$crit;0;50"
        exit 2

        fi

fi

