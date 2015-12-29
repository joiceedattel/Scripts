#!/bin/bash
mkdir -p /home/coccc/scripts/logs
log_path="/home/coccc/scripts/logs"
log_file="archive_removal_list_`date +%F_%R`.lst"
log_report="archive_removal_deletion_report.log"
sumr="3941212"
arc_dir_list="/archive/bin/archive_dir_list.list"
brn_list="/archive/bin/branch_list.list"

if [ ! -e $brn_list ]; then
   echo "   File $brn_list doesnot exist, Please copy the file and rerun the script..."
   exit 1
fi

if [ ! -s $brn_list ]; then
   echo "  File $brn_list is a Zero Byte File. Please check and rerun the script... " 
   exit 1
fi

if [ ! -e $arc_dir_list ]; then
   echo "   File $arc_dir_list doesnot exist, Please copy the file and rerun the script..."
   exit 1
fi

if [ ! -s $arc_dir_list ]; then
   echo "  File $arc_dir_list is a Zero Byte File. Please check and rerun the script... " 
   exit 1
fi

if [ "$NV_STATUS" = "SUCCEEDED" ]
then
	sum=`sum -r /archive/bin/archive_dir_list.list |sed 's/ //g'`
	if [ $sum = $sumr ]
	then
		echo "" | tee -a $log_path/$log_file >> $log_path/$log_report
		echo "######################################################################################################" | tee -a $log_path/$log_file >> $log_path/$log_report 
		echo "		Script started at `date +%c`" | tee -a $log_path/$log_file >> $log_path/$log_report
		echo "								" >> $log_path/$log_report
	
		for j in $(seq 1 `cat $brn_list | wc -l`)
		do
		   branch=`head -$j $brn_list | tail -1`
		   cat $arc_dir_list | sed -e 's/<branch_code>/'$branch'/g' > arc_dir_list.tmp
		   arc_dir_list_tmp=arc_dir_list.tmp
                   days_prv=`cal -3 | awk '{print $1,$2,$3,$4,$5,$6,$7}' | tr ' ' '\n' | sed 's/^$/*/g' | grep -v '*' | tail -n 1`
	           days_crnt=`date +%d`
	           rtndays=`expr $days_prv + $days_crnt`

		   for i in $(seq 1 `cat $arc_dir_list_tmp | wc -l`)
		   do
		#	rtndays=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f1`
			srcdir=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f3`
			max=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f4`
			min=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f5`
			unwanted=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f6`
			type=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f7`
			pattern=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f8`
			char_check=`head -$i $arc_dir_list_tmp | tail -1 | cut -d";" -f9`

					echo "									" >> $log_path/$log_file
					echo "									" >> $log_path/$log_file
					echo "									" >> $log_path/$log_file
					echo "===========================================================================================" >> $log_path/$log_file
					echo "   Details of files & directories to be deleted under $srcdir" >> $log_path/$log_file
					echo "===========================================================================================" >> $log_path/$log_file
					if [ -e $srcdir ]
					then
						find $srcdir -maxdepth $max -mindepth $min -mtime +$rtndays -type $type |grep "$pattern" |egrep -v "$unwanted" |xargs -r du -sc > /home/coccc/scripts/archive.log
						if [ $(cat  /home/coccc/scripts/archive.log |wc -l) = 0 ]	
						then
							echo "Total size of files which was deleted under $srcdir: 0 KB"     >> $log_path/$log_report
							echo "		---------------------------------------------------------" >> $log_path/$log_file
							echo "		   No file found to delete under $srcdir" >> "$log_path/$log_file"
							echo "		---------------------------------------------------------" >> $log_path/$log_file
						else	
							echo "Total size of files which was deleted under $srcdir: $(expr $(cat /home/coccc/scripts/archive.log | grep -v "total$" | awk '{print $1}' | tr '\n' '+' | sed 's/$/0/g' |sed 's/^/0+/g'|sed 's/+/ + /g'))" KB >> $log_path/$log_report
							echo "		 	 -------------------------------" >> $log_path/$log_file
							echo "		 		 List of Files" >> $log_path/$log_file
							echo "			 -------------------------------" >> $log_path/$log_file

							if [ -z $(cat /home/coccc/scripts/archive.log |grep / |tail -n1 |awk '{print $2}') ]
							then
								echo "	  	  no file found to delete under $srcdir" >>$log_path/$log_file
								echo "									" >> $log_path/$log_file
							else
								cat /home/coccc/scripts/archive.log |awk '{print $2}' |grep -v total |xargs -r ls -ld  >> $log_path/$log_file
								echo "									" >> $log_path/$log_file
								cat /home/coccc/scripts/archive.log |awk '{print $2}' |xargs -r rm -rf
							fi
						fi
					
						rm -rf /home/coccc/scripts/archive.log
						echo "			 ---------------------------------" >> $log_path/$log_file
						echo "				 List of directories" >> $log_path/$log_file
						echo "			 ---------------------------------" >> $log_path/$log_file

						if [ "$char_check" = "29" ]
					        then
					                dir=`find $srcdir -maxdepth 1 -type d -mtime +$rtndays`
							if [ -z "$dir" ]
							then
								echo "          No 29 character directory found ubder $srcdir " >>$log_path/$log_file
							else
						                for i in $dir
						                do
						                        lnth=`echo $i |tr '/' '\n' |tail -n1 |wc -m`
						                        if [ $lnth = 29 ]
						                        then
						                                ls -ld $i >>$log_path/$log_file
					        	                       # rm -rf $i 			
					                        	fi
					                	done
							
					        	fi
						else
							echo "          No input has been given to search directory under $srcdir " >>$log_path/$log_file
						fi
					fi
		done
	done

	echo "									" >> $log_path/$log_file
	echo "									" >> $log_path/$log_file
	echo "									" >> $log_path/$log_report
	echo "		Script ended at `date +%c`" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "######################################################################################################" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "" | tee -a $log_path/$log_file >> $log_path/$log_report
  else
	echo "" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "#######################################################################################################" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "		Script started at `date +%c`" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "Input File is Corruped or Tampered. Plz contact CO for Rectification........" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "		Script ended at `date +%c`" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "#######################################################################################################" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "" | tee -a $log_path/$log_file >> $log_path/$log_report
  fi
else

	echo "" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "#######################################################################################################" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "		Script started at `date +%c`" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "Backup not completed" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "		Script ended at `date +%c`" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "#######################################################################################################" | tee -a $log_path/$log_file >> $log_path/$log_report
	echo "" | tee -a $log_path/$log_file >> $log_path/$log_report
fi
