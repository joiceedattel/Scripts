#!/bin/bash
#Author Joice Joseph
# Print Usage and Exit
host="10.50.68.96"
pass="Pkf.b74hfv93dF"
user="vorwerk"
warn="10"
crit="20"
PROGNAME="$0"
utilization=`sshpass -p "$pass" ssh "$user"@"$host" ps aux|grep -i logstash|grep -v grep|awk '{print $3}'`
if [ $utilization -lt $warn ] ; then
  echo "OK - Current CPU usage for logstah-agent is $utilization | logstash-agent_CPU-utilization=$utilization;$warn;$crit;0;50"
  exit 0;

else if [ $utilization -lt $crit ] ; then
  echo "WARNING - Current CPU usage for logstah-agent is $utilization | logstash-agent_CPU-utilization=$utilization;$warn;$crit;0;50"
  exit 1;

else
echo "CRTICAL - Current CPU usage for logstah-agent is $utilization | logstash-agent_CPU-utilization=$utilization;$warn;$crit;0;50"
  exit 2;
fi

