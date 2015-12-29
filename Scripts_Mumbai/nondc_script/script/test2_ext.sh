#!/bin/bash
# variable Declaration & Initialization...

extension = `date +%Y%b%d`
backuppath="/home/Abhinav/backup/$extension/"

echo " "
echo "                                                  "
echo " moving gnt's to efeap bin "
echo " ================================================ "
echo " "
echo " "




mkdir -p $backuppath


sleep 2




cd /home/Abhinav/todays_delivery/efeap/bin
ls  *.gnt  1> gnt.txt

if [ ! -s gnt.txt ]; then
echo " There is no gnt file to move"
cd /efeap/bin

else
\cp gnt.txt /efeap/bin/
\cp *.gnt $backuppath
cd /home/Abhinav/todays_delivery/efeap/bin
mv *.gnt /efeap/bin

fi




# processing of car files

cd /home/Abhinav/todays_delivery/efeap/deploy/car
ls  *.car  1> car.txt

if [ ! -s car.txt ]; then
echo " There is no car files to move"
cd /efeap/car

else
\cp car.txt /efeap/car/
\cp *.car $backuppath
cd /home/Abhinav/todays_delivery/efeap/deploy/car
mv *.car /efeap/deploy/car

fi




