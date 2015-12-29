# variable Declaration & Initialization...

starttime=`date +%d%m%Y'_'%H%M%S`
muser='remoteadmin'
sqlpath='/efeap/DB'
database="efeap"
mvdate=`date +%Y%b%d`
backuppath="/efeap/data/backup/softwarebkp/$mvdate/DB/"
unprocessedpath="/efeap/data/backup/softwarebkp/unprocessed/$mvdate"
logfile="$sqlpath/DB_patch_$starttime.log"
errorfile="$sqlpath/DB_patch_$starttime.err"
patcherrorfile="$sqlpath/"
statusfile="$sqlpath/DB_patch_status_$starttime.log"
pwdfile="$sqlpath/.mypwd"
logs="$sqlpath/*.log"
errs="$sqlpath/*.err"
removeall="$sqlpath/*"
extfile="$sqlpath/DB_Patch*.tgz"
cmd="$sqlpath/sql_ctrl.txt"
srv=0
mhost='localhost'
processlist="$sqlpath/.filesprocessed.list"
sqlfiles="$sqlpath/*.sql"
loadscript="$sqlpath/load_release_data.sh"

# Function for display message if any errors found started
dispmsg()
{
   echo -e "\n   $1\n   `tput blink`Please contact SDC & confirm IMMEDIATELY on +91-22-67090355.`tput sgr0`\n   `tput blink`DONOT start the application...`tput sgr0`\n"
   echo -e "\n   $1\n   Please contact SDC,IMMEDIATELY on +91-22-67090355.\n   DONOT start the application...">>$errorfile
   echo -e "\n   $1\n   Please contact SDC,IMMEDIATELY on +91-22-67090355.\n   DONOT start the application...">>$statusfile
   procstatus=`mysql -h$mhost -u$muser -p$mpwd $database -e "update patch_deploy set patch_status='FAIL',updated_by='$curuser' where patch_name='$curfilename' and patch_status in ('FAIL','Unprocessed') " 2>/dev/null`
   if [ $? -ne 0 ]; then
      echo -e "\n   Error while Updating details of patch $flnm into Database!!!"
   fi
   sleep 1 
}
# Function for display message if any errors found ended

clear

echo -e "\n   Start Time : $starttime"
echo -e "\n   Start Time : $starttime">$statusfile



# This while block verifies if TIBCO is ON, prompts till you make the tibco off... 
while [ 1 == 1 ];
do
   tibcochk=`ps -e | grep "LIC"|grep -v "grep" | wc -l `
   if [ $tibcochk != 0 ]; then
      echo -e "\n   Tibco is ON, Please put OFF the TIBCO and press ENTER...\c"
      echo -e "\n   Tibco is ON, Please put OFF the TIBCO and press ENTER...\c">>$statusfile
      read tibcheck
   else
      break
   fi
done # end of while



# Check if the MYSQL Service is ON or OFF. If off script throws error and comes out of execution.
# echo -e "\n   Please enter password for `whoami`"   
# msqlsrv=`sudo /etc/init.d/mysql status 1>/dev/null 2>/dev/null`
# if [ $? -ne 0 ]; then
#      dispmsg "MYSQL service is not running!!!"
#      exit 1
# fi

clear

# Check if server is DC or NON DC..
srv=`hostname | cut -d"-" -f3 2>/dev/null | tr 'A-Z' 'a-z' | sed 's/ //g' | cut -c1-3 `
if [ "$srv" != "app" -a "$srv" != "dba" ]; then
#   dc_nondc="0"
   mhost='localhost'
   if [ ! -d $backuppath ]; then
      echo -e "\n   Creating backup directory..."
      mkdir -p $backuppath 1>/dev/null 2>/dev/null
      if [ $? -eq 0 ]; then
         echo -e "\n   Backup directory $backuppath created Successfully..."
         echo -e "\n   Backup directory $backuppath created Successfully...">>$statusfile
      fi # mkdir -p if [ $? -eq 0 ]; then
   fi # if [ ! -d $backuppath ]; then
#   mpwd='myfeap@lic'
   echo "   Non DC Server..."
else   # for setting dc variables
#   dc_nondc="1"
   mhost=`cat /etc/hosts | grep -i 'MYSQL' | cut -d"	" -f1 | cut -d" " -f1  | sed 's/ //g'| sed 's/ //g' 2>/dev/null`
   echo "   DC Server..."
   if [ ! -d $backuppath ]; then 
      echo -e "\n   Creating backup directory..."
      mkdir -p $backuppath 1>/dev/null 2>/dev/null
      if [ $? -eq 0 ]; then
         echo -e "\n   Backup directory $backuppath created Successfully..."
         echo -e "\n   Backup directory $backuppath created Successfully...">>$statusfile
      fi #  mkdir -p if [ $? -eq 0 ]; then
   fi  # if [ ! -d $backuppath ]; then 
#   mpwd='admin123'
fi # if else if [ $srv == 0 ]; then

if [ ! -e $pwdfile ]; then
   echo -e "\n   Authentication file Unavailable!!!\n   `tput blink`Please contact SDC & confirm IMMEDIATELY on +91-22-67090355.`tput sgr0`\n   `tput blink`DONOT start the application...`tput sgr0`\n"
   echo -e "\n   Authentication file Unavailable!!!\n   Please contact SDC,IMMEDIATELY on +91-22-67090355.\n   DONOT start the application...">>$errorfile
   echo -e "\n   Authentication file Unavailable!!!\n   Please contact SDC,IMMEDIATELY on +91-22-67090355.\n   DONOT start the application...">>$statusfile
   exit 1
fi
mpwd=`cat $pwdfile 2>/dev/null`
mysql -h$mhost -u$muser -p$mpwd $database -e"select 1;" 1>$sqlpath/temp.temp.log 2>$sqlpath/temp.temp.err
grep "Access denied for user" $sqlpath/temp.temp.err 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
   echo -e "\n   MYSQL Authentication FAILED!!!"
   exit 1;
else
   echo -e "\n   Entered MYSQL password is correct..."
fi # grep "Access denied for user" if [ $? -eq 0 ]; then


#while [ 1 == 1 ];
#do
#    echo -e "\n   Please enter correct MYSQL password of $mhost server & $muser user:\c"
#    read -s mpwd
#    mysql -h$mhost -u$muser -p$mpwd $database -e"select 1;" 1>$sqlpath/temp.temp.log 2>$sqlpath/temp.temp.err
#    grep "Access denied for user" $sqlpath/temp.temp.err 1>/dev/null 2>/dev/null
#    if [ $? -eq 0 ]; then
#        echo -e "\n   MYSQL Authentication FAILED!!!"
#    else
#        echo -e "\n   Entered MYSQL password is correct..."
#        break
#    fi # grep "Access denied for user" if [ $? -eq 0 ]; then
#done


grep -i "ERROR" $sqlpath/temp.temp.err 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
   dispmsg "Unable to connect to MYSQL Server!!!"
   echo "$flnm|error|$starttime">>$processlist
   exit 1
fi

if [ ! -e $loadscript ]; then
   dispmsg "Load script $loadscript is not available in current directory. Please copy and rerun!!!"
   exit 1;
fi

echo -e "\n\n   Loading data into database for parameter table..."
sh $loadscript $database $muser $mpwd $mhost $sqlpath
if [ $? -ne 0 ]; then
   dispmsg "Error occured while loading data into parameter table!!!"
   exit 1
fi

echo -e "\n\n   Executing all Database patches one by one..."

#Check the tar file is available or not
/bin/ls $extfile 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
   dispmsg "Patch $extfile is either NOT COPIED or NO Database Patch today!!!"
   exit 1
else
   /bin/ls $extfile 2>/dev/null | sort -u 1>$sqlpath/tarfiles.list 2>/dev/null
   filenameis="$sqlpath/tarfiles.list"
   for flnm in `cat $filenameis`
   do 
      echo " "
      extfile=$flnm
      curfilename=`basename $extfile 2>/dev/null`
      echo "   Deploying $curfilename patch..."
      execstatus=`mysql -s -h$mhost -u$muser -p$mpwd $database -e"select trim(patch_status) from patch_deploy where patch_name='$curfilename' " | sed 's/ //g' 2>/dev/null`
      if [ $? -ne 0 ]; then
         dispmsg "Error while fetching details of patch $flnm from Database!!!"
         continue 
      else       
         if [ "$execstatus" == "PASS" ]; then
            dispmsg "Patch $flnm is already processed!!!"
            sleep 4
            continue ;
         else 
            if [ "$execstatus" == "" ]; then
               dispmsg "Please update release_load.txt file as data is not available in Parameter table!!!"
               continue 
            fi
         fi
      fi
      rm -f $cmd $sqlfiles 1>/dev/null 2>/dev/null
      echo -e "\n   Extracting tar file $extfile, Please wait..."
      cp $flnm $backuppath 1>/dev/null 2>/dev/null
      tar xvzfC $extfile $sqlpath 1>/dev/null 2>/dev/null
      if [ $? -ne 0 ]; then 
         dispmsg "Error encountered while extracting tar file..."
         echo "$flnm|error|$starttime">>$processlist
         continue
      else 
         echo -e "\n   Patch extracted successfully at $sqlpath path..."
         echo -e "\n   Patch extracted successfully at $sqlpath path...">>$statusfile
      fi # tar xvzfC if & else
       
      # Verifying the control files V/S Physical files...
      if [ ! -e $cmd ]; then
         dispmsg "Control file sql_ctrl.txt is not available, DB Deployment pack issue.."
         echo "$flnm|error|$starttime">>$processlist
         continue
      fi 
      echo -e "\n   Comparing file counts..."
      echo -e "\n   Comparing file counts...">>$statusfile
      sqltxtcount=`wc -l $cmd 2>/dev/null | cut -d" " -f1`
      sqlfiles=`cat $cmd 2>/dev/null | tr "\n" " " `
      if [ $? -ne 0 ]; then
         dispmsg "Error encountered while verifying files..."
         echo "$flnm|error|$starttime">>$processlist
         continue
      fi # sqlfiles=`cat $cmd 2>/dev/null | tr "\n" " " ` if [ $? -ne 0 ]; then
      
      cd $sqlpath
      
      # Getting file count from physical file.
      filecount=`ls $sqlfiles 2>/dev/null | wc -l |cut -d" " -f1`
      if [ "$sqltxtcount" != "$filecount" ]; then
         dispmsg "Physical files list does not match with Control files list..."
         echo "$flnm|error|$starttime">>$processlist
         continue
      fi # filecount=`ls $sqlfiles 2>/dev/null | wc -l |cut -d" " -f1` if [ "$sqltxtcount" != "$filecount" ]; then
      
      sleep 2
      echo -e "\n   Processing all files in $extfile, Please wait..."
      echo -e "\n   Processing all files in $extfile, Please wait...">>$statusfile

      # Executing all sqls file by file.
      countervar=0
      for cnt in $(seq 1 `cat $cmd | wc -l`) 
      do
         sleep 1 
         echo ""
         echo "">>$statusfile 
         patcherrorfile="$sqlpath/${curfilename}.err"
         touch $patcherrorfile 1>/dev/null 2>/dev/null
         countervar=`expr $countervar + 1`
         echo -e "\n   Executing $countervar out of $filecount files..."
         echo -e "\n   Executing $countervar out of $filecount files...">>$statusfile
         i=`head -$cnt $cmd | tail -1`
         if [ ! -e $i ]; then
            echo "   File $i does not exist, Hence not executed."
            echo "   File $i does not exist, Please check" >>$errorfile
            echo "   File $i does not exist, Please check" >>$patcherrorfile
            echo "   File $i does not exist, Please check" >>$statusfile
         fi # i=`head -$cnt $cmd | tail -1` if [ ! -e $i ]; then
         table=`echo $i | cut -d"-" -f3`
         type=`echo $i | cut -d"-" -f2`
         neworold=`echo $i | cut -d"-" -f4`
         partissue=`echo $curfilename | cut -d"_" -f5 | cut -d"." -f1`
         bkpdttm=`date +%d%m%Y'_'%H%M%S`
         backupfile="$backuppath""$table""_"$type"-"$bkpdttm"-"$partissue".sql"
         if [ "$neworold" != "NEW" ]; then
            echo "   Dumping $table table, Please wait."
            mysqldump -h$mhost -u$muser -p$mpwd $database $table>$backupfile 2>/dev/null
            if [ $? -ne 0 ]; then
               dispmsg "Error while taking dump of $table table..."
            else
               echo "   Dump of $table table is successfull..."
               echo "   Dump of $table table is successfull...">>$statusfile
               echo "   Dump of $table table is successfull...">>$logfile
               echo "   Tarring the dump file ($backupfile), Please wait..."
               tar cvzf $backupfile.tgz $backupfile 1>/dev/null 2>$sqlpath/tmp.error.tmp
               if [ $? -ne 0 ]; then
                  dispmsg "Error while creating tar of $table table dump..."
                  cat $sqlpath/tmp.error.tmp >>$errorfile
                  cat $sqlpath/tmp.error.tmp >>$patcherrorfile
               else
                  echo "   Tar creation of $table table dump is successfull..."
                  echo "   Tar creation of $table table dump is successfull...">>$statusfile
                  echo "   Tar creation of $table table dump is successfull...">>$logfile
                  echo "   Removing the $backupfile by keeping $backupfile.tgz....."
                  rm -f $backupfile 1>/dev/null 2>$sqlpath/tmp.error.tmp
                  if [ $? -ne 0 ]; then
                     echo -e "\n   Error while removing $backupfile file..."
                     echo "   Error while removing $backupfile file...">>$statusfile
                     echo "   Error while removing $backupfile file...">>$errorfile
                     echo "   Error while removing $backupfile file...">>$patcherrorfile
                     cat $sqlpath/tmp.error.tmp >>$errorfile
                     cat $sqlpath/tmp.error.tmp >>$patcherrorfile
                  fi # rm -f if [ $? -ne 0 ]; then
               fi # tar cvzf [ $? -ne 0 ]; then
            fi  # mysqldump [ $? -ne 0 ]; then
         else
            echo "   Table $table is NEW, Hence table dump is not taken!!!"
            echo "   Table $table is NEW, Hence table dump is not taken!!!">>$statusfile
         fi # if else [ "$neworold" != "new" ]; then
         echo -e "   Executing $type changes for $table table, Please wait..."
         mysql -h$mhost -u$muser -p$mpwd $database<$i 1>$sqlpath/temp.temp.log 2>$sqlpath/temp.temp.err
         if [ $? -ne 0 ]; then
            dispmsg "Error while executing $i mysql file."
            sleep 1
            cat $sqlpath/temp.temp.err>>$errorfile
            cat $sqlpath/temp.temp.err>>$patcherrorfile
            echo "   Error while executing $i mysql file.">>$statusfile
         else
            echo "   $i file executed successfully."
            echo "   $i file executed successfully.">>$statusfile
            cat $sqlpath/temp.temp.log>>$logfile
            echo "   $i file executed successfully.">>$logfile
         fi # mysql -h$mhost -u$muser -p$mpwd $database<$i if [ $? -ne 0 ]; then
         errlns_tmp=`cat $patcherrorfile 2>/dev/null | wc -l`
         if [ $errlns_tmp == 0 ]; then
            procstatus=`mysql -h$mhost -u$muser -p$mpwd $database -e "update patch_deploy set patch_status='PASS',updated_by='$curuser' where patch_name='$curfilename' and patch_status in ('FAIL','Unprocessed') " 2>/dev/null`         
            if [ $? -ne 0 ]; then
               dispmsg "Unable to update $flnm into Database!!!"
            fi 
         fi
      done # for done
   echo "$flnm|processed|$starttime">>$processlist
   errlns=`cat $patcherrorfile 2>/dev/null | wc -l`
   if [ $errlns == 0 ]; then 
      curuser=`whoami 2>/dev/null` 
      procstatus=`mysql -h$mhost -u$muser -p$mpwd $database -e "update patch_deploy set patch_status='PASS',updated_by='$curuser' where patch_name='$curfilename' and patch_status in ('FAIL','Unprocessed') " 2>/dev/null`
      if [ $? -ne 0 ]; then
         dispmsg "Error while fetching details of patch $flnm from Database!!!"
         exit 1
      fi
   else
      if [ ! -d $unprocessedpath ]; then
         echo -e "\n   Creating unprocessed directory $unprocessedpath..."
         mkdir -p $unprocessedpath 1>/dev/null 2>/dev/null
         if [ $? -eq 0 ]; then
            echo -e "\n   Unprocessedpath directory $unprocessedpath created Successfully..."
            echo -e "\n   Unprocessedpath directory $unprocessedpath created Successfully...">>$statusfile
         fi # mkdir -p if [ $? -eq 0 ]; then
      fi # if [ ! -d $unprocessedpath ]; then
      mv $extfile $unprocessedpath 1>/dev/null 2>/dev/null
   fi
   done
fi # if else of /bin/ls $extfile
extfile="$sqlpath/DB_Patch*.tgz"


echo -e "\n   Checking for errors, Please wait..."

errlines=`cat $errorfile 2>/dev/null | wc -l`
if [ $errlines != 0 ]; then
   dispmsg "ERRORS occured while executing DB Patch(es),Please check $unprocessedpath path..."
   echo -e "\n   Please Note, DONOT START THE APPLICATION!!!">>$statusfile
   echo -e "\n   Please Note, DONOT START THE APPLICATION!!!"
else 
   echo -e "\n   SUCCESSFULLY executed DB Patch without any errors!!!">>$statusfile
   echo -e "\n   SUCCESSFULLY executed DB Patch without any errors!!!"
fi #errlines=`cat $errorfile 2>/dev/null | wc -l` if [ $errlines != 0 ]

echo -e "\n   Removing Unwanted files, Please wait till it completes..."
echo -e "\n   Removing Unwanted files, Please wait till it completes...">>$statusfile
#mv $extfile $backuppath 1>/dev/null 2>/dev/null
mv $logs $backuppath 1>/dev/null 2>/dev/null
mv $errs $backuppath 1>/dev/null 2>/dev/null
mv $sqls $backuppath 1>/dev/null 2>/dev/null
#rm $pwdfile 1>/dev/null 2>/dev/null
rm $extfile $sqlpath/temp.temp.* $sqlpath/tmp.error.tmp $sqlpath/tarfiles.list 1>/dev/null 2>/dev/null
echo -e "\n   Removed Unwanted files..."
echo -e "\n   Removed Unwanted files...">>$statusfile

if [ $errlines != 0 ]; then
   exit 1
else
   exit 0
fi # if [ $errlines != 0 ]
 
