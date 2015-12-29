#!/bin/bash



echo " "
echo " "
echo "                                                  "
echo " Deploying New & Modified WebServices "
echo " ================================================ "
echo " "
echo " "


sleep 2

cd /efeap/deploy/logs/

rm -rf deploy_log.txt

cd /efeap/deploy/car

\rm -rf carfile.txt
\rm -rf carfiles.txt


ls  *.car  1> carfile.txt

# Check it's size is not greater than 0 ...
if [ ! -s carfile.txt ]; then

echo " There is no car files to Deploy the Web Services "

else
\cp carfile.txt /efeap/idt/
\cp *.car /efeap/idt/

cd /efeap/idt/

dep()
{
cd /efeap/idt
/opt/microfocus/cobol/bin/mfdepinst $1
cat /efeap/idt/deploylog.txt  >> /efeap/deploy/logs/deploy_log.txt
}

for i in `cat /efeap/idt/carfile.txt`
do
echo $i
cd /efeap/idt/
dep $i
done

\mv /efeap/idt/*.car /efeap/car/

#cd /efeap/deploy/car/

rm -rf /efeap/deploy/car/*.car

fi


