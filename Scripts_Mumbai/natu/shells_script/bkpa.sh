#!/bin/bash
while true
do
date >> /tmp/nfs_meminfo.out
cat /proc/meminfo | egrep "(Dirty|Writeback|NFS_Unstable):" >> /tmp/nfs_meminfo.out
sleep 5
done
