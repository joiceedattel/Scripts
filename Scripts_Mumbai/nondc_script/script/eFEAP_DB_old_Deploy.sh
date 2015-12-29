#!/bin/bash

#This shell will take the backup of config tables before restoring into efeap
#table_names="file_names|file_xtns|im_menu_item|im_module_menu_map|message|srv_cnfg|srv_op_config|edin_trans_type|efeap_dropdown|job_definition|navvalmn_navdtl|"

tdydir=`date +%Y%b%d`
DeployTimeStamp=`date +%Y%m%d%T`

if [[ -d /backup/softwarebkp/$tdydir ]] ;then
   echo "Backup Directory Folder Already Exists"
else
   mkdir /backup/softwarebkp/$tdydir
   echo "Backup Directory Folder Created "
fi

cd /backup/softwarebkp/$tdydir

echo " Performing BACKUP of CONFIG TABLES....."

mysqldump -uremoteadmin -padmin123 efeap efeap_dropdown file_names file_xtns im_menu_item im_module_menu_map job_definition message navvalmn_navdtl srv_cnfg srv_op_config edin_trans_type |gzip -9 > efeapconfig_dump_$DeployTimeStamp.sql.gz

echo " Performing Incremental Inserts for CONFIG TABLES....."

#Please make sure that end character is pipe symbol
table_names="efeap_dropdown|file_names|file_xtns|im_menu_item|im_module|im_module_menu_map|job_definition|message|srv_cnfg|srv_op_config|"
tbl_cnt=`echo $table_names|tr -cd "|"|wc -c`
echo $tbl_cnt
for i in $( seq 1 `echo $table_names|tr -cd "|"|wc -c` )
do
  tbl_name=`echo $table_names|cut -d"|" -f$i`
  echo $tbl_name
  mysql -uremoteadmin -padmin123 efeap < /efeap/DB/$tbl_name.sql 2>/efeap/DB/"$tbl_name"_"$DeployTimeStamp".log
  if [ $? -ne 0 ]
  then
   echo " Restoration is having errors for Table $tbl_name Plz check the log files "
  ls /efeap/DB/"$tbl_name"_"$DeployTimeStamp".log
      if [ $? -eq 0  ]
      then
          if [ -s "$tbl_name"_"$DeployTimeStamp".log ]
          then
              echo " Below is the log information for table $tbl_name"
              echo "                          "
              cat "$tbl_name"_"$DeployTimeStamp".log
              echo "                          "
              echo " CONFIG RESTORE Failed for Table --> $tbl_name . Refer Log File --> "$tbl_name"_"$DeployTimeStamp".log"
              echo " PLEASE WAIT ..... UNTIL SCRIPT COMPLETES"
              echo " PLEASE VERIFY WITH DB TEAM ....."
              sleep 10
              exit 1
          fi
      fi
      echo " Please check the availabilty of SQL file $tbl_name.sql in /efeap/DB directory for Table $tbl_name"
      sleep 10
      exit 1
  fi
echo " Completed RESTORATION OF CONFIG TABLE $tbl_name Successfully...................."
sleep 5
done;
echo " Restoration completed successfully......................."
sleep 5
exit 0
