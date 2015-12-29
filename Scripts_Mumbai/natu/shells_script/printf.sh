#!/bin/bash
s="\h \v " 
n="\n"
echo " Please Enter Value "
read i
echo " Please Enter your Name"
read name


 j=''

while [ "$i" -gt 1 ]
do 

printf " \h \v   $name \h \v  " 


i=`expr "$i" - 1`
done







