#!/bin/bash
src=""
dst=""
cd $src
find -regextype posix-egrep -mtime +370 -type d -regex '.*[^/]{28}' >/efeap/data/dir-29.txt
for i in cat $(cat /efeap/data/dir-29.txt)
do
	mv $src/$i $dst
done
