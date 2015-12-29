#!/bin/bash
############################################################################################
#Purpose        :- Deploying eFeap related components on APPA, APPB, WEBA, WEBB & Database #
#Author         :- Wipro INFRA Team                                                        #
#Revised Version:- V3.0                                                                    #
#Date           :- 28/07/2012                                                              #
############################################################################################
# Scripts mandatory for this script on APPA, APPB, WEBA, WEBB & BKPA                       #
#__________________________________________________________________________________________#
#       /efeap/Script/eFEAP_DB_Deploy.sh                                                   #
#       /efeap/Script/eFEAP_incr_backup.sh                                                 #
#       /efeap/Script/check_keygen.sh                                                      #
#       /efeap/Script/mfcleanrestart.sh                                                    #
#       /efeap/Script/eFEAP_WebService_Deploy.sh                                    	   #
#       /efeap/Script/eFEAP_WebService_UnDeploy.sh                                  	   #
#       /efeap/Script/eFEAP_Java_Deploy.sh                                                 #
#	/efeap/DB/load_release_data.sh							   #
#	/efeap/DB/.mypwd								   #
############################################################################################

# ARGUMENT CHECKING SECTION
if [ $# -ne 1 -o "$1" != "FROM MAIN SHELL" ]
then
        echo "ERROR: $(basename $0) cannot execute independently. It cannot be call only through Patch Deploy shell."
        exit 1;
fi

# INCLUDE COMMON CODE SECTION
source $common_deploy_shell

# FUNCTION DECLARATION STARTED

load_ctlfile()
{
        for i in $(egrep -v "#|^$" $1 | tr -d [:blank:])
        do
                var1=$(echo $i | cut -d":" -f1)
                var2=$(echo $i | cut -d":" -f2)
                eval $var1="$(echo $var2)";
                export $var1
        done

	location_id=$(hostname | cut -d"-" -f2);
        zone_code=$(hostname | cut -d"-" -f1 | cut -c2-);
        div_code=$(hostname | cut -d"-" -f2 | cut -c2-);
	location_type="DC"
	export location_id
	export zone_code
	export div_code
	export location_type
}

load_patch_control()
{
	patch_name_with_path=$(ls $patchpath/$patchpattern 2>/dev/null )
	no_of_patch=$(ls $patchpath/$patchpattern 2>/dev/null | wc -l )

	if [ $no_of_patch -eq 0 ]
	then
		print_error "e_11" "$patchpath"
	fi		
	
	if [ $no_of_patch -gt 1 ]
	then
		print_error "e_12" "$patchpath" "$patch_name_with_path"
	fi

	tar -xzf $patch_name_with_path -C $patchpath/	
	if [ $? != 0 ]
        then
		print_error "e_13"
        fi	
	
	no_of_patchctl=$(ls $patchpath/$ctlfile_pattern 2>/dev/null | wc -l)
	pack_control_file=$(ls $patchpath/$ctlfile_pattern 2>/dev/null)
	pack_docname_with_path=$(echo $pack_control_file | sed 's/.ctl/.doc/')
        pack_name_with_path=$(echo $pack_control_file | sed 's/.ctl/.tgz/')

	if [ -z "$pack_control_file" -o $no_of_patchctl -eq 0 ]
	then
		print_error "e_43" "'$(basename $patch_name_with_path)'"
	fi

	if [ $no_of_patchctl -gt 1 ]
	then
		print_error "e_44" "'$patchpath'"
	fi

	if [ ! -s $pack_name_with_path ]
	then
		print_error "e_4" "$pack_name_with_path"
	fi

        if [ ! -s $pack_control_file ]
        then 
		print_error "e_4" "$pack_control_file"
	else
		load_ctlfile $pack_control_file
        fi
	export pack_control_file
	export pack_name_with_path
	export patch_name_with_path
}

patch_control_validate()
{
	if [ "$(sum -r $pack_name_with_path | sed 's/ [ ]*/-/g')" != $sum_r ]
        then
		print_error "e_26"
        fi

	if [ "$(ls -ltr $pack_name_with_path | awk '{print $5}')" != $byte_size ]
        then
		print_error "e_27"
        fi	

	cobol_components_loop="";
	for i in $(echo $cobol_deployment_order | tr '|' ' ')
	do
		if [ "$(eval echo \$${i}_components)" = "Y" ]
		then
			if [ "$i" = "bin" ] 
			then
				cobol_components_loop="${cobol_components_loop} gnt"
			else
				cobol_components_loop="${cobol_components_loop} $i"
			fi
		fi
	done
	
	if [ "$pack_type" = "$incremental_pack_type" -o "$pack_type" = "$emergency_pack_type" -o "$pack_type" = "$skip_pack_type" ]
	then
		echo "true" > /dev/null
	else
		print_error "e_37" "$pack_type"
	fi
	
	export cobol_components_loop

}

deploy_time_check()
{
	if [ ! -z "$from_time" -o ! -z "$to_time" ]
	then
		c_time=`date +%H%M`
		if [ $c_time  -gt $from_time -a $c_time -lt $to_time ]
		then
			print_error "e_15" "$from_time" "$to_time"
		fi
	fi
}

releaseid_check()
{
	release_id_ctl=$(echo $release_id | cut -c2- )
	$mysqlconnect -sN -e"select max(substr(release_id,2)) from $patch_control_tablename where final_status in ('PASS','PART','FAIL') and pack_type=\"$pack_type\";" 1>$tmp_logfile 2>$tmp_errfile
        if [ -s "$tmp_errfile" -o $? -ne 0 ]
        then 
                if [ `grep "Table '$mysql_schema.$patch_control_tablename' doesn't exist" $tmp_errfile | wc -l` -gt 0 ]
                then 
                        print_submsg "d_8" "$mysql_schema.$patch_control_tablename"
			if [ ! -s $patch_control_sqlfile ]
			then
				 print_error "e_24" "$patch_control_sqlfile"
			fi
                        $mysqlconnect < $patch_control_sqlfile 2>$tmp_errfile
                        if [ -s "$tmp_errfile" -o $? -ne 0 ]
                        then
				print_error "e_19" "$(cat $tmp_errfile)"
                        fi
			$mysqlconnect -sN -e"select max(substr(release_id,2)) from $patch_control_tablename where final_status in ('PASS','PART','FAIL') and pack_type=\"$pack_type\";" 1>$tmp_logfile 2>$tmp_errfile
			if [ -s "$tmp_errfile" -o $? -ne 0 ]
        		then
	                	if [ `grep "Table '$mysql_schema.$patch_control_tablename' doesn't exist" $tmp_errfile | wc -l` -gt 0 ]
				then
					print_error "e_25" "$(cat $tmp_errfile)"
				else
					print_error "e_23" "$(cat $tmp_errfile)"
				fi
			fi
                        req_release_id=$release_id_ctl;
                else
			print_error "e_23" "$(cat $tmp_errfile)"
                fi
        else
                rm -f $tmp_errfile 2>>/dev/null
                if [ `cat $tmp_logfile` = "NULL" ]
                then
			$mysqlconnect -sN -e"select max(substr(release_id,2)) from $patch_control_tablename where final_status in ('PASS','PART','FAIL') and pack_type=\"$pack_type\";" 1>$tmp_logfile 2>$tmp_errfile
			if [ $? -ne 0 ]
			then
				print_error "e_23" "$(cat $tmp_errfile)"
			fi

			if [ `cat $tmp_logfile` = "NULL" ]
			then
                        	req_release_id=$release_id_ctl;
			else
                        	req_release_id=`cat $tmp_logfile`
			fi

                else
                        max_release_id=`cat $tmp_logfile`
                        req_release_id=`expr $max_release_id + 1`
                fi
        fi

#-----------------------------------------------------------------------------
		id=`expr $release_id_ctl - $req_release_id`
                di=`expr $req_release_id - $release_id_ctl`
                if [ $id -gt 1 ]
                then
                print_error "e_21"
                exit
                fi
                if [ $di -gt 1 ]
                then
                print_error "e_20" "$patch_name_with_path"
                exit
                fi

#------------------------------------------------------------------------------

	if [ ! -z "$dependent_release_id" -a "$pack_type" = "$emergency_pack_type" ]
	then
		$mysqlconnect -sN -e"select final_status  from $patch_control_tablename where release_id='$dependent_release_id' and final_status='PASS';" 1>$tmp_logfile 2>$tmp_errfile
		if [ -s "$tmp_errfile" -o $? -ne 0 ]
                then
                	print_error "e_23" "$(cat $tmp_errfile)"
                fi

		if [ ! -s "$tmp_logfile" -a "$(cat $tmp_logfile | tr -d [:blank:])" != "PASS" ]
		then
			print_error "e_36" "$dependent_pack_name" 
		fi
	fi

	if [ "$pack_type" != "$skip_pack_type" ]
	then
	        if [ $req_release_id -gt $release_id_ctl ]
        	then
			status=`$mysqlconnect -sN -e"select max(final_status)  from $patch_control_tablename where release_id='V$max_release_id'"`
                        if [ $status = PASS ]
                        then
				print_error "e_20" "$patch_name_with_path"
                        fi
                        if [ $status = PART ]
                        then
                                if [ "$db_flag" = "N" ]
                                then
                                	print_error "e_46" "$patch_name_with_path"
                                fi
                        fi

	        fi

        	if [ $req_release_id -lt $release_id_ctl ]
	        then
        			print_error "e_21"
	        fi

        	if [ $req_release_id -eq $release_id_ctl ]
	        then
			status=`$mysqlconnect -sN -e"select max(final_status)  from $patch_control_tablename where release_id='V$max_release_id'"`
	                if [ "$status" = "PART" ]
        	        then
                        	if [ "$db_flag" = "N" ]
	                        then
                                	print_error "e_46" "$patch_name_with_path"
                         	fi
                	fi
                	if [ "$status" = "FAIL" ]
                	then
                        	print_error "e_21"
                	fi
		fi
fi

	
	$mysqlconnect -sN -e"select final_status  from $patch_control_tablename where release_id='$release_id' and pack_type='$pack_type' and final_status in ('PASS','PART');" 1>$tmp_logfile 2>$tmp_errfile
	if [ -s "$tmp_errfile" -o $? -ne 0 ]
        then
        	print_error "e_23" "$(cat $tmp_errfile)"
        fi
	cat $tmp_errfile
        if [ -s "$tmp_logfile" -a "$(cat $tmp_logfile | tr -d [:blank:])" = "PASS" ]
        then
        	print_error "e_20" "$patch_name_with_path"
        fi

        if [ -s "$tmp_logfile" -a "$(cat $tmp_logfile | tr -d [:blank:])" = "PART" ]
        then
        	print_error "e_45" "$patch_name_with_path"
        fi

	$mysqlconnect -e"INSERT INTO $patch_control_tablename(pack_name,version_name,release_id,release_date,pack_type,sum_r,byte_size,location_type,location_id,zone_code,div_code,xml_change,final_status,remarks,creation_ts) values(\"$pack_name\",\"$version\",\"$release_id\",\"$release_date\",\"$pack_type\",\"$sum_r\",\"$byte_size\",\"$location_type\",\"$location_id\",\"$zone_code\",\"$div_code\",\"$xml_change\",'FAIL','FIRST ENTRY',\"$deployment_time\") " 2>$tmp_errfile
        if [ -s "$tmp_errfile" -o $? -ne 0 ]
        then
		print_error "e_22" "$(cat $tmp_errfile)"
        fi

        record_ctl=`$mysqlconnect -sN -e"select creation_ts from $patch_control_tablename where release_id=\"$release_id\" order by 1 desc limit 1;" 2>$tmp_errfile`
        if [ -s "$tmp_errfile" ]
        then
		 print_error "e_23" "$(cat $tmp_errfile)"
        fi
	echo "$release_id|$location_id|$record_ctl" > $parent_record_ctl_file 
	export record_ctl
}

call_childscript()
{
	if [ ! -s "$1" ]
	then	
		print_error "e_3" "$1"
	fi
	$1 $2 "FROM DO SHELL"
	if [ $? -ne 0 ]
	then
		remove_unwanted_files "$SHELL_TEMP_FILES";
	        exit 1
	fi	
}

incr_backup()
{
	print_msg "d_10"
        call_childscript "$script_path/$incr_backup_shell" "$pack_name_with_path"
	if [ $? = 0 ]
        then
                print_msg "d_11"
        else
                print_error "e_28"
        fi
}

java_deployment()
{
	java_deployment_time=$(date "+%F %T")
	print_msg "d_17" "$java_deployment_time"
	
	$mysqlconnect -e"UPDATE $patch_control_tablename SET  java_start_time=\"$java_deployment_time\", java_status='FAIL',java_remarks='JAVA Deployment Started', remarks='JAVA Deployment Started'  where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
	if [ -s "$tmp_errfile" ]
        then
		print_error "e_103" "$(cat $tmp_errfile)"
        fi
	
	ssh -T -o StrictHostKeyChecking=no $deployuser@$(eval echo $(echo \$hname_$(echo $host_java_deploy | tr A-Z a-z))) <<_EOF_
		$script_path/$java_deploy_shell "FROM DO SHELL" "$patch_cnf_file" "$msg_cnf_file" "$common_deploy_shell" "DEPLOYMENT" "$host_java_secondary_deploy|$record_ctl|$mysqlconnect|$release_id|$location_id|$pack_name" 
_EOF_
	opt_val=$?
	if [ $opt_val -eq 0 ]
        then
	         print_msg "d_18"
		 java_deployment_time=$(date "+%F %T")
		$mysqlconnect -e"UPDATE $patch_control_tablename SET java_end_time=\"$java_deployment_time\", java_status='PASS',java_remarks='JAVA Deployment Completed', remarks='JAVA Deployment Completed' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
		if [ -s "$tmp_errfile" ]
	        then
			print_error "e_103" "$(cat $tmp_errfile)"
	        fi
        else
                print_msg "e_30"
                $mysqlconnect -e"UPDATE $patch_control_tablename SET remarks='JAVA Deployment Failed' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
		remove_unwanted_files "$SHELL_TEMP_FILES";
		exit 1;
        fi
}

patch_backup()
{
	print_msg "d_19"
        mv ${patch_name_with_path} ${patch_backupdir} 1>/dev/null 
        if [ $? != 0 ]
        then
                print_error "e_32"
        else
                print_submsg "d_20"
        fi
	remove_unwanted_files "$SHELL_TEMP_FILES";
	rm -rf ${patchpath}/efeap 1>/dev/null 2>/dev/null
}

db_deployment()
{
	stop_start_tibco "stop"
	
	db_deployment_time=$(date "+%F-%T")
	
	$mysqlconnect -e"UPDATE $patch_control_tablename SET  db_start_time=\"$db_deployment_time\", db_status='FAIL',db_remarks='DB Deployment Started', remarks='DB Deployment Started'  where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
	if [ -s "$tmp_errfile" ]
        then
		print_error "e_103" "$(cat $tmp_errfile)"
        fi
	export db_deployment_time

	$script_path/$db_deploy_shell "FROM DO SHELL"	
	opt_val=$?
	if [ $opt_val -eq 0 ]
	then
		db_deployment_time=$(date "+%F %T")
		db_deployment_status="PASS";
		print_msg "d_128" "$db_deployment_time"
		$mysqlconnect -e"UPDATE $patch_control_tablename SET db_end_time=\"$db_deployment_time\", db_status='PASS',db_remarks='DB Deployment Completed', remarks='DB Deployment Completed' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
		if [ -s "$tmp_errfile" ]
	        then
			print_error "e_103" "$(cat $tmp_errfile)"
	        fi
        elif [ $opt_val -eq 3 ]
	then
		db_deployment_time=$(date "+%F %T")
		db_deployment_status="PART";
                print_msg "d_129" "$db_deployment_time"
                $mysqlconnect -e"UPDATE $patch_control_tablename SET db_end_time=\"$db_deployment_time\", db_status='PART',db_remarks='DB Deployment Completed With errors or warnings', remarks='DB Deployment Completed With errors or warnings' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
                if [ -s "$tmp_errfile" ]
                then
			print_error "e_103" "$(cat $tmp_errfile)"
                fi
	elif [ $opt_val -eq 1 ]
	then
                print_msg "d_130"
		db_deployment_status="FAIL";
                $mysqlconnect -e"UPDATE $patch_control_tablename SET remarks='DB Deployment Failed' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
		stop_start_tibco "start"
		remove_unwanted_files "$SHELL_TEMP_FILES";
		exit 1;
        fi

	stop_start_tibco "start"
}

cobol_deployment()
{

	cobol_deployment_time=$(date "+%F %T")
        print_msg "d_9" "$cobol_deployment_time"

        $mysqlconnect -e"UPDATE $patch_control_tablename SET  cobol_start_time=\"$cobol_deployment_time\", cobol_status='FAIL',cobol_remarks='Cobol Deployment Started', remarks='Cobol Deployment Started' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
        if [ -s "$tmp_errfile" ]
        then
                print_error "e_103" "$(cat $tmp_errfile)"
        fi 

        $script_path/$cobol_deploy_shell "FROM DO SHELL"
        opt_val=$?
        if [ $opt_val -eq 0 ]
        then
                 print_msg "d_16"
                 cobol_deployment_time=$(date "+%F %T")
                $mysqlconnect -e"UPDATE $patch_control_tablename SET cobol_end_time=\"$cobol_deployment_time\", cobol_status='PASS', cobol_remarks='Cobol Deployment Completed', remarks='Cobol Deployment Completed' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
                if [ -s "$tmp_errfile" ]
                then
                        print_error "e_103" "$(cat $tmp_errfile)"
                fi
        else
                print_msg "e_28"
                $mysqlconnect -e"UPDATE $patch_control_tablename SET remarks='COBOL Deployment Failed' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
		remove_unwanted_files "$SHELL_TEMP_FILES";
                exit 1;
	fi
}

extract_patch()
{
	print_msg "d_215" "$pack_name"
	rm -rf ${patchpath}/efeap 1>/dev/null 2>/dev/null
	tar -zxvf $pack_name_with_path -C ${patchpath}/ 
	if [ $? -ne 0 ]
	then
		print_error "e_113" "$pack_name_with_path"
	fi		
	print_msg "d_15" "$pack_name"

	if [ "$db_components" = "Y" ]
	then
		cp -pr ${patchpath}/${db_sqlpath}/* ${db_sqlpath}/
		if [ $? -ne 0 ]
		then
			print_error "e_18" "${patchpath}/${db_sqlpath}" "${db_sqlpath}"
		fi
	fi

	if [ "$car_components" = "Y" ]
	then
		cp -pr ${patchpath}/${webservice_car_path}/* ${webservice_car_path}/
		if [ $? -ne 0 ]
                then
                        print_error "e_18" "${patchpath}/${webservice_car_path}" "${webservice_car_path}"
                fi
	
	fi

	if [ "$data_components" = "Y" ]
	then
		cp -pr ${patchpath}/${cobol_appdata_path}/* ${cobol_appdata_path}/
                if [ $? -ne 0 ]
                then
                        print_error "e_18" "${patchpath}/${cobol_appdata_path}" "${cobol_appdata_path}"
                fi
	fi
	
}

creating_backup_logpath()
{
	today_date=$(date +%Y%b%d)
	logdir="$logpath/$(basename $pack_name '.tgz')/$today_date"
	mkdir -p $logdir 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]
	then
		print_error "e_31" "$logdir"
	fi

	logfile=$(hostname|cut -d'-' -f1,2)_$(basename $pack_name '.tgz')_$( echo $deployment_time | tr ' ' '-').log
	
	echo "${logdir}/${logfile}" > $parent_logpath_file

	db_backupdir="$backuppath/$(basename $pack_name '.tgz')/$today_date/DB"
	mkdir -p $db_backupdir 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]
	then
		print_error "e_31" "$db_backupdir"
	fi
	
	patch_backupdir="$backuppath/$(basename $pack_name '.tgz')/$today_date/patch"
	mkdir -p $patch_backupdir 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]
	then
		print_error "e_31" "$patch_backupdir"
	fi
	
	war_backupdir="$backuppath/$(basename $pack_name '.tgz')/$today_date/war"
	mkdir -p $war_backupdir 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]
	then
		print_error "e_31" "$war_backupdir"
	fi
	
	reportdir="$backuppath/$(basename $pack_name '.tgz')/$today_date"
	export logdir
	export db_backupdir
	export patch_backupdir
	export war_backupdir
	export reportdir
}

stop_start_tibco()
{
        if [ $1 = "stop" ]
        then
                print_msg "d_301"
                $stop_tibco_shell
                sleep 3s
                killall rvd
                sleep 2s
                killall rvd
                print_msg "d_302"
        else
                print_msg "d_316"
                source $lic_env_shell
                $start_tibco_shell 1>/dev/null 2>/dev/null
		print_msg "d_319"
        fi
}

script_ending_log()
{
	deployment_time=$(date "+%F %T");
	print_msg "d_12" "$deployment_time"
	tmp_msg_string="$(eval echo -e $(grep -w "^[ ]*d_12" $msg_cnf_file 2>/dev/null | cut -d"|" -f2))"
	if [ -z "$tmp_msg_string" ]
        then
        	msg_string="'d_12' message code does not exist in '$(basename $message_file)'"
	else
		msg_string=$(echo "$tmp_msg_string $deployment_time")
        fi
	
	[ "$db_deployment_status" = "PART" ] && patch_deployment_status="PART" || patch_deployment_status="PASS"

	if [ ! -z "$record_ctl" ]
	then
		$mysqlconnect -e"UPDATE $patch_control_tablename SET remarks=replace(replace(\"$msg_string\",'\\n',' '),'\\t',','), final_status='$patch_deployment_status' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
	        if [ -s "$tmp_errfile" ]
        	then
	       		echo -e "Error while updating record in $patch_control_tablename : $(cat $tmp_errfile)"
        	fi
	fi

	rm -f $tmp_logfile $tmp_errfile 1>/dev/null 2>/dev/null
}

check_deployment_order()
{
	for i in $( echo $deployment_order | tr '|' '\n' )
	do
		j=$(echo $i | tr 'a-z' 'A-Z' );
		
        	if [ "$j" != "JAVA" -a "$j" != "COBOL" -a "$j" != "DB" ]
	        then	
			print_error "e_5" "deployment_order"	
		fi
	done
}

main_patch_deployment()
{
	for i in $( echo $deployment_order | tr '|' '\n' )
	do
		if [ "$( echo $i | tr 'a-z' 'A-Z' )" = "JAVA" ]
		then
			if [ ! -z "$hosts_java" -a "$java_components" = "Y" ] 
			then
				java_deployment 
			else
				$mysqlconnect -e"UPDATE $patch_control_tablename SET java_status='NAVL',java_remarks='Either Java Components or Java Hosts not available' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
			fi
		fi

		if [ "$( echo $i | tr 'a-z' 'A-Z' )" = "DB" ]
		then
			if [ "$db_components" = "Y" ]
			then
				db_deployment
			else
				$mysqlconnect -e"UPDATE $patch_control_tablename SET db_status='NAVL',db_remarks='Either DB Components or DB Host not available' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
			fi
		fi
		
		if [ "$( echo $i | tr 'a-z' 'A-Z' )" = "COBOL" ]
		then
			if [ ! -z "$cobol_loop_val" -a ! -z "$cobol_components_loop" ]
			then
				 cobol_deployment
			else
				$mysqlconnect -e"UPDATE $patch_control_tablename SET cobol_status='NAVL',cobol_remarks='Either COBOL Components or COBOL Hosts not available' where release_id=\"$release_id\" and location_id=\"$location_id\" and creation_ts=\"$record_ctl\"" 2>$tmp_errfile
			fi
		fi

	done
}

generate_report()
{
	report_logfile="$reportdir/component_report_$(basename $pack_name '.tgz')_$(date '+%F-%T').log"
	$script_path/$comp_report_shell "FROM DO SHELL" | tee -a $report_logfile	
}

initalize_shell_params()
{
	SHELL_TEMP_FILES="pack_name_with_path|pack_control_file|tmp_404_msgfilepath|tmp_503_msgfilepath|pack_docname_with_path|tmp_patch_extract_dir"
        SHELL_NAME=$(basename $0)
	deployment_time=$(date "+%F %T")
	param_custom_msgpath="$patchpath";
	tmp_404_msgfilepath="$patchpath/$msgfile_404_name"
	tmp_503_msgfilepath="$patchpath/$msgfile_503_name"
	tmp_patch_extract_dir="$patchpath/efeap"
	export param_custom_msgpath
}

generate_custom_msg()
{
	echo "<center>" > $tmp_404_msgfilepath
	echo "<font color="red">" >> $tmp_404_msgfilepath
	echo "!! Sorry for Inconvenience !!" >> $tmp_404_msgfilepath
	echo "<br>" >> $tmp_404_msgfilepath
	echo "<br>" >> $tmp_404_msgfilepath
	echo "Patch $(basename $pack_name_with_path '.tgz') is under deployment" >> $tmp_404_msgfilepath
	echo "</font>" >> $tmp_404_msgfilepath
	echo "</center>" >> $tmp_404_msgfilepath

	echo "<center>" > $tmp_503_msgfilepath
        echo "<font color="red">" >> $tmp_503_msgfilepath
        echo "!! Sorry for Inconvenience !!" >> $tmp_503_msgfilepath
        echo "<br>" >> $tmp_503_msgfilepath
        echo "<br>" >> $tmp_503_msgfilepath
        echo "Patch $(basename $pack_name_with_path '.tgz') is under deployment" >> $tmp_503_msgfilepath
        echo "</font>" >> $tmp_503_msgfilepath
        echo "</center>" >> $tmp_503_msgfilepath
}

# FUNCTION DECLARATION ENDED

# MAIN CODE STARTED HERE

initalize_shell_params;

check_host_script;

evaluate_cobol_hosts;

evaluate_java_hosts;

check_variable_length "emergency_pack_type,1|incremental_pack_type,1|skip_pack_type,1"

load_patch_control;

parameters_validate $neccesary_ctl_parameters $dependent_ctl_parameters;

patch_control_validate;

print_msg "d_1" "$deployment_time";

creating_backup_logpath;

releaseid_check;

deploy_time_check;

call_childscript "$script_path/$precheck_shell";

generate_custom_msg;

disable_war_file;

## Main Deployment Started

incr_backup

source /etc/profile

extract_patch

check_deployment_order;

main_patch_deployment;

generate_report;

enable_war_file;

patch_backup;

script_ending_log;

exit 0
