#!/bin/bash
rpcdebug -m nfs -s all; rpcdebug -m rpc -s all
while [ true ]
do
	if [ $( cat /proc/loadavg |awk '{print $1}' |cut -d '.' -f1) -gt '100' ]
	then
		echo $date >> /tmp/nfsiostat.out
		nfsiostat 5 15 >> /tmp/nfsiostat.out
		echo  $date >> /tmp/rpcinfo.out
		rpcinfo -p  >> /tmp/rpcinfo.out
		echo $date >> /tmp/iostat.out
		iostat -x 2 15 >> /tmp/iostat.out
		echo $date >> /tmp/nfs_meminfo.out
		cat /proc/meminfo | egrep "(Dirty|Writeback|NFS_Unstable):" >> /tmp/nfs_meminfo.out 
		tcpdump -s0 -i bond0 -w /tmp/tcpdump.pcap host `hostname -i |tr '145' '139'`
	fi

sleep 900
done
rpcdebug -m nfs -c all; rpcdebug -m rpc -c all
