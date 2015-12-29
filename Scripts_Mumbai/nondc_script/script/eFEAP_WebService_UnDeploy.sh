#!/bin/bash


echo " "
echo " "
echo "                                       "
echo "   UnDeploy The Modified WebServices   "
echo " ===================================== "
echo " "
echo " "

sleep 5

cd /efeap/deploy/logs/

rm -rf /efeap/deploy/logs/*

cd /efeap/deploy/car

\rm -rf carfile.txt
\rm -rf carfiles.txt

ls  *.car  1> carfile.txt


if [ ! -s carfile.txt ]; then

echo " There is no car files to UnDeploy the Web Services "

else

cat carfile.txt | sed 's/\.car//' > carfiles.txt

dep()
{
mfpackage -s ESDEMO undeploy http://www.lic.com/efeap/$1 2>&1 | tee -a /efeap/deploy/logs/undeploy_log.txt
}
for i in `cat carfiles.txt`
do
dep $i
sleep 2
done

fi

