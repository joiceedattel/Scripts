#!/bin/bash
#---------------------------------------------------------------------------#
# Shell for deleting records of history tables from DBSA on every day 
# at specied size in MB.
#---------------------------------------------------------------------------#
# Date : 16/10/2012
#---------------------------------------------------------------------------#
# This shell should be present in /tmp dir in BKPA
#---------------------------------------------------------------------------#
initialze_values()
{
  curdate=`date +'%Y-%m-%d' --date='0 day ago'`
  curtime=`date +'%Y-%m-%d %H:%M:%S'`
  fsuffix=`date +'%Y-%m-%d_%H-%M'`
  ip_feed=10.240.13.116
  no_exec_crontab=10
  maxsize=50000
  ip_dbsa=`hostname -i | sed 's/...$/162/'`
  #reports=/home/coccc/del_log/del_log.txt
  reports=/home/coccc/del_log/del_log_$fsuffix.txt
  hreport=/home/coccc/del_log/.del_log_$fsuffix.txt
  delfile=/home/coccc/del_log/delfile_$curdate.txt
  control=/home/coccc/del_log/control_$curdate.txt
  my_user=remoteadmin
  my_pass=admin123
  echo "===============" >> $hreport
  echo "START OF SCRIPT at $curtime" >> $hreport
  echo "===============" >> $hreport
  echo "===============" >> $reports
  echo "START OF SCRIPT at $curtime" >> $reports
  echo "===============" >> $reports
}
#---------------------------------------------------------------------------#
check_prev_execs()
{
  proc_id=`echo $$`
  process=`ps -ef | grep del_log.sh | grep -v grep | grep -v $proc_id`
  if [ -n "$process" ]
  then
    echo "STEP 1 -> Previous execution is not yet completed" >> $reports
    echo "Script is not ended properly" >> $reports
    exit
  else
    echo "STEP 1 -> No Previous Execution is running" >> $reports
  fi
}
#---------------------------------------------------------------------------#
check_keygen()
{
  mas_act=`hostname -i | sed 's/...$/162/'` 
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@`hostname -i | sed 's/...$/162/
'` /sbin/ifconfig 1> /dev/null 2> /dev/null
  if [ $? != 0 ]
  then
    echo "STEP 2 -> Keygen not working between DBSR to DBSA"  1>> $reports 2>> $reports
    echo "Script is not ended properly" >> $reports
    exit
  else 
    echo "STEP 2 -> Keygen is OK!!!!" 1>> $reports 2>> $reports
  fi
}
#---------------------------------------------------------------------------#
check_replication()
{
mysql_connect="mysql -h$(hostname -i) -u$my_user -p$my_pass -e"
rep_status=`$mysql_connect "show slave status\G" | egrep "Slave_IO_Running|Slave_SQL_Running" | awk '{print$2}' | grep "Yes" | wc -l`
if [ $rep_status != 2 ]
then
  echo "STEP 3 -> Replication Failed between DBSA and DBSR" >> $reports
  echo "Script is not ended properly" >> $reports
  exit
else
  echo "STEP 3 -> Replication is OK between DBSA and DBSR" >> $reports
fi

}
#---------------------------------------------------------------------------#
deletion_logic()
{
  extract_control_records
  check_max_delete_size
  calc_dbsr_binlog_percent
  calc_dbsa_binlog_percent
  binlog_percent_checks
}
#---------------------------------------------------------------------------#
extract_control_records()
{
  dc_name=`hostname | sed 's/....\(....\).*/\1/'`
  mysql -h$ip_feed -udeluser -pdel1234 delrecs -N -e"select dc_code,control,delsize,bkpdate from dcs_det where dc_code = '$dc_name' and control = 'Y' and bkpdate != '0000-00-00'" | sed "s+	+|+g" > $control 
  if [ ! -s $control ] 
  then 
    echo "STEP 4 -> Control is Disabled / Special Backup Not Taken" >> $reports
    echo "Script is not ended properly" >> $reports
    exit
  else
    echo "STEP 4 -> Control record is extracted" >> $reports
  fi
}
#---------------------------------------------------------------------------#
check_max_delete_size()
{
  delsize=`cat $control | cut -d'|' -f3`
  allowed_max_size=`expr $delsize \* $no_exec_crontab` 
  if [ $maxsize -le $allowed_max_size ] 
  then
    echo "STEP 5 -> Maximum limit for deleting binlog is 50000 MB per day in $no_exec_crontab iterations, reduce deletion quota" >> $reports 
    echo "Script is not ended properly" >> $reports
    exit
  else
    echo "STEP 5 -> Maximum limit for deleting binlog is 50000 MB per day in $no_exec_crontab iterations, proceeding!!!!! " >> $reports 
  fi
}
#---------------------------------------------------------------------------#
calc_dbsr_binlog_percent()
{
  binbyte=`df | grep "/binlog" | sed "s= \+=|=g" | cut -d'|' -f4`
  binpers=`df | grep "/binlog" | sed "s= \+=|=g" | cut -d'|' -f5 | sed "s+%++" `
  bin_tot=`df | grep "/binlog" | sed "s= \+=|=g" | cut -d'|' -f2`
  delsize=`cat $control | cut -d'|' -f3`
  binrper=`expr  $binpers + $delsize \* 1024  \* 100 / $bin_tot `
  echo DBSR====binused====bin_tot====binaper====delsize >> $hreport
  echo DBSR====$binused====$bin_tot====$binpers====$delsize >> $hreport
}
#---------------------------------------------------------------------------#
calc_dbsa_binlog_percent()
{
  mas_act=`hostname -i | sed 's/...$/162/'` 
  #echo "mas_act" $mas_act
  binline=`ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 -o ConnectTimeout=1 coccc@$mas_act df | grep "/binlog" | sed "s= \+=|=g" `
  echo "binline" $binline
  binbyte=`echo $binline | cut -d'|' -f4`
  binpers=`echo $binline | cut -d'|' -f5 | sed "s+%++"`
  bin_tot=`echo $binline | cut -d'|' -f2`
  delsize=`cat $control | cut -d'|' -f3`
  #binaper=`expr \( $binpers + $delsize \* 1024 \) \* 100 / $bin_tot `
  binaper=`expr $binpers + $delsize \* 1024  \* 100 / $bin_tot `
  echo DBSA====binused====bin_tot====binaper====delsize >> $hreport
  echo DBSA====$binused====$bin_tot====$binaper====$delsize >> $hreport
}

#---------------------------------------------------------------------------#
binlog_percent_checks()
{
  if [ $binrper -ge 80 ]
  then
    echo "STEP 6 -> Size to be removed in this execution (Deltion Quota) = `expr $delsize ` MB" >> $reports
    echo "STEP 6 -> Unable to delete records from DBSA/B as Used Space Percent will reach >=80% in Binlog partition of DBSR" >> $reports
    echo "Script is not ended properly" >> $reports
    exit
  elif [ $binaper -ge 80 ]
  then
    echo "STEP 6 -> Size to be removed in this execution (Deltion Quota) = `expr $delsize ` MB" >> $reports
    echo "STEP 6 -> Unable to delete records from DBSA/B as Used Space Percent will reach >=80% in Binlog partition of DBSA/B" >> $reports
    echo "Script is not ended properly" >> $reports
    exit
  else 
    echo "STEP 6 -> Binlog Size is less than 80 % proceed for deletions!!!!!!!" >> $reports
    extract_table_list
    proceed
  fi
}
#---------------------------------------------------------------------------#
extract_table_list()
{
  #echo "TableLists" >> $reports
  mysql -h$ip_feed -udeluser -pdel1234 delrecs -N -e"select tabname,remrecs,remsize,delyear from hisrecs where dc_code = '$dc_name' and remsize > 0 order by remsize" | sed "s+	+|+g" > $delfile
  if [ ! -s $delfile ]
  then
    echo "STEP 7 -> No Tables Records Are Eligible For Deletion" >> $reports 
    echo "Script is not ended properly" >> $reports
    exit
  else
    echo "STEP 7 -> Tables Records Eligible For Deletion are" >> $reports 
    cat $delfile >> $reports
  fi
}
#---------------------------------------------------------------------------#
proceed()
{
  no_recs=0
  cnt=0
  while [ $delsize -gt 0 ]
  do
    cnt=`expr $cnt + 1`
    hisline=`cat -n $delfile | grep "^ *$cnt	"`
    linecnt=`wc -l $delfile | sed "s+ .*delfile.*++"`
    extract_nth_record
    cnt_del_logics
    delete_update_feedbak_server
  done
  inform_over
 }
#---------------------------------------------------------------------------#
extract_nth_record()
{
  if [ $cnt -gt $linecnt ]
  then 
    no_recs=1
    break 
  else 
    hisline=`cat -n $delfile | grep " $cnt	" | sed "s+.* $cnt	++" `
    tabname=`echo $hisline | cut -d'|' -f1` 
    tablename_check
    remrecs=`echo $hisline | cut -d'|' -f2` 
    remrcmb=`echo $hisline | cut -d'|' -f3` 
    delyear=`echo $hisline | cut -d'|' -f4` 
    remsize=`expr $remrcmb`
    echo Extracting $cnt ") record"  $tabname $remrecs $remsize $delyear >> $hreport
  fi
}
#---------------------------------------------------------------------------#
tablename_check()
{
    if [ $tabname != "ach" -a $tabname != "csh" -a $tabname != "edh" -a $tabname != "mkh" -a $tabname != "nbh" -a $tabname != "osh" -a $tabname != "pmh" -a $tabname != "ssh" -a $tabname != "tibin_data" -a $tabname != "tibout_data" -a $tabname != "tibin_bin" -a $tabname != "tibout_bin" -a $tabname != "ssh_tmp" -a $tabname != "csh_tmp" ]
    then
       echo "Table $tabname is not meant for deletion " >> $reports
       continue
    fi
}
#---------------------------------------------------------------------------#
cnt_del_logics()
{
   if [ $remsize -gt $delsize ]
   then 
     echo "Table records size ($remsize MB) is more than Deletion Quota ($delsize MB) " >> $reports
     delrecs=`expr $delsize \* $remrecs / $remsize`
     remrecs=`expr $remrecs - $delrecs`
     remsize=`expr $remsize - $delsize`
     del_upd=$delsize
     delsize=0
   fi
   if [ $remsize -le $delsize ]
   then 
     echo "Table records size ($remsize MB) is less than Deletion Quota ($delsize MB)" >> $reports
     delrecs=$remrecs
     remrecs=`expr $remrecs - $delrecs`
     delsize=`expr $delsize - $remsize`
     del_upd=$remsize
     remsize=0
   fi 
}
#---------------------------------------------------------------------------#
delete_update_feedbak_server()
{
  mysql_delete_cmd

  if [ -s mys_err ] 
  then
    echo "DBSA DELETION ERROR" >> $hreport
    delrecs=0
    del_upd=0
    del_err=`cat mys_err`
  else 
    echo "DBSA HAS NO DELETION ERROR, UPDATING FEEDBACK SERVER" >> $hreport
    update_remain_records
    update_control_record
  fi
  update_dailyst_record
  echo "Remaining Quota to Delete $delsize MB" >> $reports
  echo "Remaining Quota to Delete $delsize MB" >> $hreport
}
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
mysql_delete_cmd()
{
  if [ $tabname = "tibin_bin_tmp" -o $tabname = "tibout_bin" -o $tabname = "tibin_bin" ]
  then
    del_rec="delete from $tabname where year(tpc_trans_date) between 1995 and $delyear limit $delrecs" 
  else
    del_rec="delete from $tabname where year_column between 1995 and $delyear limit $delrecs" 
  fi 

  echo "mysql -u$my_user -p$my_pass efeap -h$ip_dbsa -e$del_rec" >> $hreport
  echo "Deleting from $tabname records between 1995 and $delyear limiting to $delrecs" >> $reports

  mysql -u$my_user -p$my_pass efeap -h$ip_dbsa -e"$del_rec" -vvvv 1> mys_out 2> mys_err

  del_dur=`cat mys_out | grep "rows affected" | sed "s+.*rows affected (\(.*\))+\1+"`
  act_del=`cat mys_out | grep "rows affected" | sed "s+.*, \(.*\) rows affected.*+\1+"`

  echo "DELRECS MYSQL OUTPUT START" >> $hreport
  cat mys_out | grep -v "delete from" | grep -v "\-\-\-"  >> $reports
  cat mys_out >> $hreport
  echo "DELRECS MYSQL ERROR START" >> $hreport
  cat mys_err >> $hreport
  echo "DELRECS MYSQL ERROR END" >> $hreport
  echo $del_rec >> $hreport
}
#---------------------------------------------------------------------------#
update_remain_records()
{
  curtime=`date +'%Y-%m-%d %H:%M:%S'`
  del_err="No Error, Query OK, Actual Records deleted $act_del at $curtime"
  echo "EMPTY"     >> $hreport
  upd_his="update hisrecs set remsize=$remsize , remrecs = $remrecs where dc_code = '$dc_name' and tabname='$tabname'" 
  echo "mysql -udeluser -pdel1234 delrecs -h$ip_feed -e$upd_his" >> $hreport
  mysql -udeluser -pdel1234 delrecs -h$ip_feed -e"$upd_his" 1> mysqlst 2>> mysqlst
  echo "hisrecs mysql output/error START" >> $hreport
  cat mysqlst >> $hreport
  echo "hisrecs mysql output/error END" >> $hreport
  echo $upd_his >> $hreport
}
#---------------------------------------------------------------------------#
update_control_record()
{
  binbyte=`df | grep "/binlog" | sed "s= \+=|=g" | cut -d'|' -f4`
  binfree=`expr $binbyte / 1024 `
  upd_dcs="update dcs_det set binsize = $binfree where dc_code = '$dc_name'" 
  echo "mysql -udeluser -pdel1234 delrecs -h$ip_feed -e$upd_dcs" >> $hreport
  mysql -udeluser -pdel1234 delrecs -h$ip_feed -e"$upd_dcs" 1> mysqlst 2>> mysqlst
  echo "dcs_det mysql output/error START" >> $hreport
  cat mysqlst >> $hreport
  echo "dcs_det mysql output/error END" >> $hreport
  echo $upd_dcs >> $hreport
}
#---------------------------------------------------------------------------#
update_dailyst_record()
{
  dly_upd="insert into dailyst (dc_code,tabname,deldate,delrecs,delsize,del_dur,del_err) values ('$dc_name','$tabname','$curtime','$delrecs','$del_upd','$del_dur','$del_err')" 
  echo "mysql -udeluser -pdel1234 delrecs -h$ip_feed -e$dly_upd" >> $hreport
  mysql -udeluser -pdel1234 delrecs -h$ip_feed -e"$dly_upd" 1> mysqlst 2>> mysqlst
  echo "dailyst mysql output/error START" >> $hreport
  cat mysqlst >> $hreport
  echo "dailyst mysql output/error END" >> $hreport
  echo $dly_upd >> $hreport
}

#---------------------------------------------------------------------------#
inform_over()
{
 if [ $no_recs -eq 1 ]
  then 
    echo "All Listed Table Records are Deleted !!!" >> $reports
    echo "All Listed Table Records are Deleted !!!" >> $hreport
  else
    chksize=`cat $control | cut -d'|' -f3`
    echo "$chksize MB records deleted"   >> $hreport
    echo "$chksize MB records deleted"   >> $reports
  fi
}
#---------------------------------------------------------------------------#
the_end()
{
  curtime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "=======" >> $reports
  echo "THE END at $curtime" >> $reports
  echo "=======" >> $reports
  echo "=======" >> $hreport
  echo "THE END" >> $hreport
  echo "=======" >> $hreport
}
#---------------------------------------------------------------------------#
#                      Actual program starts here
#---------------------------------------------------------------------------#
initialze_values
check_prev_execs
check_keygen
check_replication
deletion_logic
the_end
#-------------------------------------E-O-F---------------------------------#
