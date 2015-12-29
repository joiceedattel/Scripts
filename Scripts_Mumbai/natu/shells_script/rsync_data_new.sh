#!/bin/bash
##############################################################################################
#Purpose          :- Syncing of flat files from all divisions for particular DR              #
#Author           :- Wipro INFRA Team                                                        #
#Revised Version  :- V2.1                                                                    #
#Date             :- 08/10/2014                                                              #
#Dependencies     :- "/etc/hosts" file should contain division IP address of DBSR and        #
#                    Division code.                                                          #
#                    Below is the example of hosts file entry:-                              #
#                      10.X.X.X	Z00-X000-DBSR                                                #
##############################################################################################


[ -z $1 ] && echo "Pass a argument(Divison Code) to script" && exit 1

dc="$1"
dc_name="$(echo "$dc" | tr '-' '_')"
echo "$dc_name"
DATE=`date +%d%m%y-%H%M%S`
dc_code=$(echo $dc | cut -d "-" -f2)
dbsr_ip=$(grep -i "$dc" /etc/hosts | grep -v "[ ]*#[ ]*" | awk '{print $1}')

mkdir -p /Rsync/rsync_out/rsync_out_"$dc_name"

### Checking Host file ###

[ $(echo "$dbsr_ip" | wc -l) -gt 1 ] && echo "Multiple entries in host file" >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.err && exit 1

#Checking LVM in DBSR ###

[ $(ssh -T -o PasswordAuthentication=yes $dbsr_ip lvscan | egrep "lvefeap|lvusr3" | grep " ACTIVE " |wc -l) != 2 ] && echo " LVs are   not ACTIVE on DBSR..." >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".err  && exit 1

### Checking mounted partition in DBSR ###

[ $(ssh -T -o PasswordAuthentication=yes $dbsr_ip mount | egrep "/efeap/data|/usr3" | grep -v "/Nfs-Shared/" |wc -l) != 2 ] && echo " Partitions are not mounted on DBSR..." >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".err  && exit 1


### Checking LV are active ###
[ $(lvscan 2>/dev/null | egrep "lvusr3-$dc_code|lvefeapdata-$dc_code" | grep " ACTIVE " | wc -l) != 2 ] && echo " Found Local LVs are not Active  "  >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".err  && exit 1


### Checking Local Mounted Partition  ###

[ $(mount | egrep "/$dc_code/efeap/data|/$dc_code/usr3" | grep -v "/Nfs-Shared/" |wc -l ) != 2 ] && echo "Local partitions are not mounted..." >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".err && exit 1 

###Checking Previous rsync process ###


[ $(ps aux | grep "$dbsr_ip" | grep -v "$$" | grep -v "grep" | wc -l) != 0 ] && echo "Previous Rsync is running............."  >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_"$DATE".err && exit 1
ps_wc=$(ps aux | grep "$dbsr_ip" | grep -v "$$" | grep -v "grep" | wc -l)
echo $ps_wc

### Starting Rsync ###

	rsync -avzS --progress --delete $dbsr_ip:/efeap/data/ /"$dc_code"/efeap/data/. >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.err

	rsync -avzS --progress --delete $dbsr_ip:/usr3/ /"$dc_code"/usr3/. >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.err
        
       gzip /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.err



