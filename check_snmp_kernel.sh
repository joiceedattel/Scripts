#!/bin/bash
# Author : Joice Joseh

# This script will check the kernel version of remote server


# check for parameters
if [ $# -ne 6 ] ; then
  echo "Usage : $0 -h <HOSTANME> -l <COMMUNITY> -k <kernel>"
  exit 3;
fi


while getopts h:l:k: option ; do
  case $option in
    h) HOSTNAME="$OPTARG";;
    l) COMMUNITY="$OPTARG";;
    k) KERNEL="$OPTARG";;
    esac
done

new_kernel=$(snmpstatus -v1 -c $COMMUNITY $HOSTNAME|awk '{print $4}')
new_kernel_version=$(echo $new_kernel|awk '{print $1}')
if [ "$KERNEL" != "$new_kernel_version" ] ; then
echo "Critical : A change in kernel version detected, current kernel version is $new_kernel_version and old kernel was $KERNEL"
exit 2
else
echo "OK : Current kernel is $KERNEL"
exit 0
fi
