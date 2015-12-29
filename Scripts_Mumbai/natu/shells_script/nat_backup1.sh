#!/bin/bash

#MddyyHHmmss

for i in $(cat /root/Desktop/SnapShots.csv | grep -v "#")
do
  time_stamp=$(echo $i | cut -d";" -f4)
  M=$(echo $time_stamp | sed 's/"//' |cut -c1,2)
  Y=$(echo $time_stamp | sed 's/"//' |cut -c5,6)
  D=$(echo $time_stamp | sed 's/"//' |cut -c3,4)
  h=$(echo $time_stamp | sed 's/"//' |cut -c7,8)
  m=$(echo $time_stamp | sed 's/"//' |cut -c7,8)
  s=$(echo $time_stamp | sed 's/"//' |cut -c7,8)

#total_hours=$(echo $(( ( $(date  -d "$(date +%Y-%m-%d" "%H:%M:%S)" +'%s') - $(date -d "$(echo $Y-$M-$D $h:$m:$s)" +%s))/60/60 )))

[[ $(echo $(( ( $(date  -d "$(date +%Y-%m-%d" "%H:%M:%S)" +'%s') - $(date -d "$(echo $Y-$M-$D $h:$m:$s)" +%s))/60/60 ))) -le 12 ]] && echo "  Succeeded => "$i" " >> /tmp/newout.txt || echo "  Failed => "$i" " >> /tmp/newout.txt

done


