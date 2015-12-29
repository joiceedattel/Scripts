#!/bin/bash
mkdir -p /home/coccc/scripts/logs/file-check-status/`date +%F`
log_path="/home/coccc/scripts/logs/file-check-status/`date +%F`"


echo " " >> $log_path/FilesSizeMoreThan10MB.txt
echo " " >> $log_path/FilesSizeMoreThan10MB.txt
echo " " >> $log_path/FilesSizeMoreThan10MB.txt
echo "######################################################| `date +%F_%T` |#########################################################" >> $log_path/FilesSizeMoreThan10MB.txt
echo "===================================================================================================================================== " >> $log_path/FilesSizeMoreThan10MB.txt
echo "				   List of the files which are greater than 10 MB" >> $log_path/FilesSizeMoreThan10MB.txt
echo "===================================================================================================================================== " >> $log_path/FilesSizeMoreThan10MB.txt
echo " " >> $log_path/FilesSizeMoreThan10MB.txt

	find /efeap/data/ -size +10M |xargs -r du -sh >> $log_path/FilesSizeMoreThan10MB.txt

echo " " >> $log_path/FilesSizeMoreThan10MB.txt
echo "===================================================================================================================================== " >> $log_path/FilesSizeMoreThan10MB.txt
echo "######################################################################################################################################" >> $log_path/FilesSizeMoreThan10MB.txt




echo " " >> $log_path/FilesOneYearBack.txt
echo " " >> $log_path/FilesOneYearBack.txt
echo " " >> $log_path/FilesOneYearBack.txt
echo "#####################################################| `date +%F_%T` |##########################################################"  >> $log_path/FilesOneYearBack.txt
echo "===================================================================================================================================== " >> $log_path/FilesOneYearBack.txt
echo "				  List of files which are not ACCESSED from Last 1 Year" >> $log_path/FilesOneYearBack.txt
echo "===================================================================================================================================== " >> $log_path/FilesOneYearBack.txt
echo " " >> $log_path/FilesOneYearBack.txt

        find /efeap/data/ -type f -mtime +365 |xargs -r ls -l >> $log_path/FilesOneYearBack.txt

echo " " >> $log_path/FilesOneYearBack.txt
echo "===================================================================================================================================== " >> $log_path/FilesOneYearBack.txt
echo "#######################################################################################################################################"  >> $log_path/FilesOneYearBack.txt




echo " " >> $log_path/Files3monthsBack.txt 
echo " " >> $log_path/Files3monthsBack.txt 
echo " " >> $log_path/Files3monthsBack.txt 
echo "#####################################################| `date +%F_%T` |#########################################################" >> $log_path/Files3monthsBack.txt
echo "===================================================================================================================================== " >> $log_path/Files3monthsBack.txt
echo "				  List of files which are not TOUCHED from Last 3 months" >> $log_path/Files3monthsBack.txt
echo "===================================================================================================================================== " >> $log_path/Files3monthsBack.txt
echo " " >> $log_path/Files3monthsBack.txt 

        find /efeap/data/ -type f -mtime +90 |xargs -r ls -l >> $log_path/Files3monthsBack.txt

echo " " >> $log_path/Files3monthsBack.txt 
echo "===================================================================================================================================== " >> $log_path/Files3monthsBack.txt
echo "######################################################################################################################################" >> $log_path/Files3monthsBack.txt


echo " " >> $log_path/DirHavingMoreThan500files.txt
echo " " >> $log_path/DirHavingMoreThan500files.txt
echo " " >> $log_path/DirHavingMoreThan500files.txt
echo "#####################################################| `date +%F_%T` |#########################################################" >> $log_path/DirHavingMoreThan500files.txt
echo "===================================================================================================================================== " >> $log_path/DirHavingMoreThan500files.txt
echo "				 Directory under /efeap/data which having more than 500 files" >> $log_path/DirHavingMoreThan500files.txt
echo "===================================================================================================================================== " >> $log_path/DirHavingMoreThan500files.txt
echo " " >> $log_path/DirHavingMoreThan500files.txt
dir=`find /efeap/data -type d ` 
for i in $dir
do
	file=`ls -ltr $i |wc -l`
	if [ $file -gt 500 ]
	then
		echo "	$i" >> $log_path/DirHavingMoreThan500files.txt
	fi
done
echo " " >> $log_path/DirHavingMoreThan500files.txt
echo "===================================================================================================================================== " >> $log_path/DirHavingMoreThan500files.txt
echo "######################################################################################################################################" >> $log_path/DirHavingMoreThan500files.txt
