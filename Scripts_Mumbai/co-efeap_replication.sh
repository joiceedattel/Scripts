#!/bin/bash
# checking the rsync status from BKPA server

sshpass -p jubkpa145 ssh 10.63.1.145 "echo "ssh 10.63.1.145";echo "";echo "ssh 10.240.92.165 du -shc /efeap/data/ /usr3";ssh 10.240.92.165 du -shc /efeap/data/ /usr3;echo "";echo "du -shc /COEFEAP/efeap/data/ /COEFEAP/usr3"; du -shc /COEFEAP/efeap/data/ /COEFEAP/usr3"

echo ""
echo "mysql -h10.63.1.183  -uslave_user -plicindia -e "show slave status \G""
echo ""
#checking replication status in DR

mysql -h10.63.1.183  -uslave_user -plicindia -e "show slave status \G"

