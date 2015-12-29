#/bin/bash

dc="$1"
dc_name="$(echo "$dc" | tr '-' '_')"
echo "$dc_name"
DATE=`date +%d%m%y-%H%M%S`
dc_code=$(echo $dc | cut -d "-" -f2)
dbsr_ip=$(grep -i "$dc" /etc/hosts | grep -v "^#" | awk '{print $1}')

mkdir -p /Rsync/rsync_out/rsync_out_"$dc_name"

[ $(echo "dbsr_ip" | wc -l) -gt 1 ] && echo "Multiple entries in host file" && exit 1

efeap_data=$(ssh -T -o PasswordAuthentication=yes "$dbsr_ip" df -hP | grep "/efeap/data" |awk '{print $5}'|sed 's/%//')
usr3=$(ssh -T -o PasswordAuthentication=yes "$dbsr_ip" df -hP | grep "/usr3" |awk '{print $5}'|sed 's/%//')

ps aux | grep "$dbsr_ip" | grep -v "grep"

if [ $? = 0 ]
        then
        echo "Previous Rsync is running............." >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.err
        exit

elif [ "$efeap_data" -lt "10" ] && [ "$usr3" -lt "5" ] 
        then 
        echo "Partitions are not mounted ............">> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.err
        exit
         
else    

	ssh -T -o PasswordAuthentication=yes "$dbsr_ip" hostname >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$date.err

#rsync -avz --progress --delete $dbsr_ip:/efeap/data/ /"$dc_code"/efeap/data/. >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$date.err
#rsync -avz --progress --delete $dbsr_ip:/usr3/ /"$dc_code"/usr3/. >> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.out 2>> /Rsync/rsync_out/rsync_out_"$dc_name"/rsync_$DATE.err
    
fi


