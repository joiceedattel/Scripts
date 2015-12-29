#!/bin/bash
#test script
if [ "$1" == "" ]
then
echo " Give value"
fi
fun()
{
hostname
date
uptime
}
fun2()
{
echo "fun2"
}

case $1 in

fun1)
	echo "exectiyng fun1"
	fun
   ;;
fun2)

echo " executing fun2"
	fun2
   ;;

esac	
	

