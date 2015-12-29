#!/bin/bash

n=1
for i in $(cat iplist.txt)
do
ip="$(echo $i | cut -d "." -f1-3).$n"
echo $ip
n=`expr $n + 1`
done


