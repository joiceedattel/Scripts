#!/bin/bash
while (true)
do
if [ $(date | cut -d ":" -f3 | cut -d " " -f1) -gt 58 ]
then
sshpass -pkosoarA#001 ssh -o StrictHostKeyChecking=no 10.65.58.141  "find /efeap/data/*/rec* -amin 1 | xargs -r ls -ltr|grep "$(date +%H:%M)"| wc -l;date;hostname" 
fi
done

