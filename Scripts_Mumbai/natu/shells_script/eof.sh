#!/bin/bash


ssh -T 10.240.13.214 -o StrictHostKeyChecking=yes  <<_EOF_

df -h | grep "/usr" |awk '{print $5}'|sed 's/%//'
df -h | grep "/home" |awk '{print $5}'|sed 's/%//'
df -h

_EOF_


