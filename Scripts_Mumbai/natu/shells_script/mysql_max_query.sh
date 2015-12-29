#!/bin/bash

dat=$(date +%y%m%d)

grep " $dat "  /db/$(hostname)-slow.log -A50 >> /tmp/slow_query"$dat".txt

cat /tmp/slow_query"$dat".txt | grep Query_time|gawk '{print $3}'|sort -n |gawk 'BEGIN{ count="1" }{print $1;total+=$1;count++;}END{print "average=" total/count;}' | tail -n10 >/tmp/top5query.txt

avg=$(cat /tmp/top5query.txt | grep ave >> /tmp/max5query_out"$dat".txt | cut -d "=" -f2)
echo "The Avg mysql query time is : "$avg"" >> /tmp/max5query_out"$dat".txt


for i in $(cat /tmp/top5query.txt | grep -v ave)
do

out=$(grep "$i" -A100 /tmp/slow_query"$dat".txt | tr "\n" " " |sed 's/# Query_time:/|/g'  | cut -d "|" -f2)

echo "Total query time is : `expr ($i /60 /60 )`  " >> /tmp/max5query_out"$dat".txt
echo " "

mq=$(echo $out | cut -d '#' -f1 | cut -d ";" -f2) 
echo -e The Mysql Query is : "\n" "$mq"  >> /tmp/max5query_out"$dat".txt

echo " " >> /tmp/max5query_out"$dat".txt
qs=$(echo $out |cut -d "#" -f2) 
echo -e Query Start at : "\n" "$qs"  >> /tmp/max5query_out"$dat".txt

echo " " >> /tmp/max5query_out"$dat".txt

hq=$(echo $out | cut -d '#' -f3 | cut -d "@" -f3)
echo -e Host Queried : "\n" "$hq"   >> /tmp/max5query_out"$dat".txt
echo " " >> /tmp/max5query_out"$dat".txt

echo "=============================================================================================" >> /tmp/max5query_out"$dat".txt
echo " "
done







