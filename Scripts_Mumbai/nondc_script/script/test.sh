#!/bin/bash



echo " "
echo " "
echo "                                                  "
echo " moving gnt's to efeap bin "
echo " ================================================ "
echo " "
echo " "


sleep 2

cd /home/Abhinav/todays_delivery/efeap/bin

ls  *.gnt  1> gnt.txt

if [ ! -s gnt.txt ]; then

echo " There is no gnt files to move"

cd /efeap/bin

else
\cp gnt.txt /efeap/bin/
\cp *.gnt /home/Abhinav/backup
cd /home/Abhinav/todays_delivery/efeap/bin
mv *.gnt /efeap/bin

fi




