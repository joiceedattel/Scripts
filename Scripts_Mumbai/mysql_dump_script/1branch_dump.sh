#!/bin/bash
print_error()
{
        echo -e "$1\e[0;31;48m !! $2 !!\e[0m$3"
}

final_fnc()
{
        if [ `grep -v "\~\~\~\~\~\~" ${errfile_name} 2>>/dev/null| wc -l ` -eq 0 ]
        then
                rm -f ${errfile_name}
        fi
        echo ""
        echo " ----------------------------------------------------------- "
        echo " ----------------SCRIPT EXECUTION FINISHED------------------ "
        echo " ----------------------------------------------------------- "
}

clear;
echo " ----------------------------------------------------------- "
echo " -----------------SCRIPT EXECUTION STARTS------------------- "
echo " ----------------------------------------------------------- "
srv_name=`echo $HOSTNAME | cut -d"-" -f2-3 | tr "-" "_"`
td_date=`date +%F-%H%M%S`
if [ -z $srv_name ]
then
        srv_name="X000"
fi

errfile_name="dump_status_${srv_name}_${td_date}.err"

echo -e "\n Enter Credentials for mysql connectivity:"
read -p "      1. User ID  : " my_user
read -p "      2. Password : " -s my_passwd
my_host="localhost"
my_schema="efeap"

if [ -z "$my_host" -o -z "$my_user" -o -z "$my_schema" -o -z "$my_passwd" ]
then
        print_error "\n" "Error: Given credentials contain null values"
        final_fnc;
        exit 1;
fi

echo -e "\n\n Testing mysql credentials...."
mysql_query="mysql -h$my_host -u$my_user -p$my_passwd $my_schema"
mysqldump_query="mysqldump -h$my_host -u$my_user -p$my_passwd $my_schema"

$mysql_query -sN -e"select TABLE_NAME from information_schema.columns where TABLE_SCHEMA='$my_schema' and COLUMN_NAME='owning_location';" 1>table_name.txt 2>${errfile_name}
if [ $? -ne 0 ]
then
        print_error "\n" "Error while connecting database with given credentials... Please see logs in '${errfile_name}'"
        final_fnc;
        exit 1;
fi

echo -e " Connected successfully to: $my_schema "
       

for j in `cat branch_list.txt`
do
	echo -e "\n Taking dump of '$j' branch... Please Wait";
	
	####1 Only Structure Dump
        $mysqldump_query --skip-add-drop-table -d  > 1_structure_dump_branch_$j.sql 2> 1_structure_dump_$j.err
        if [ $? -ne 0 -o `tail -1 1_structure_dump_branch_$j.sql | grep "Dump completed" | wc -l` -ne 1 ]
        then
                print_error "\n" "Error while taking structure dump for '$j' branch... Please see logs in '1_structure_dump_$j.err'"
                final_fnc;
                exit 0;
        else
                [ ! -s "1_structure_dump_$j.err" ] && rm -f 1_structure_dump_$j.err 2>/dev/null
        fi	

	####2 Only Data dump 
        tblname=`cat table_name.txt | tr  "\n" " "` 	
	$mysqldump_query -f -t $tblname -w"owning_location='$j'" >2_data_dump_$j.sql 2>2_data_dump_$j.err
	if [ $? -ne 0 -o `tail -1 2_data_dump_$j.sql | grep "Dump completed" | wc -l` -ne 1 ]
	then
		print_error "\n" "Error while taking data dump for '$j' branch... Please see logs in '2_data_dump_$j.err'"
		final_fnc;
		exit 0;
	else
		[ ! -s "2_data_dump_$j.err" ] && rm -f 2_data_dump_$j.err 2>/dev/null		
	fi

	####3 Refer Tables dump
	$mysqldump_query -f -t $tblname -w"owning_location='LIC'"> 3_refer_dump_$j.sql  2> 3_refer_dump_$j.err
        if [ $? -ne 0 -o `tail -1 3_refer_dump_$j.sql | grep "Dump completed" | wc -l` -ne 1 ]
        then
                print_error "\n" "Error while taking data dump for '$j' branch... Please see logs in '3_refer_dump_$j.err'"
                final_fnc;
                exit 0;
        else
                [ ! -s "3_refer_dump_$j.err" ] && rm -f 3_refer_dump_$j.err 2>/dev/null
        fi

	####4 im_tables dump 
	$mysqldump_query -f -t --skip-lock-tables im_user_accs im_user_dept im_user_location im_location im_user_role im_authz_role im_authz_date_range im_authz_accs -w"loc_id in(select loc_id from im_location where loc_code = '$j')" >4_im_dump_$j.sql  2>4_im_dump_$j.err
	if [ $? -ne 0 -o `tail -1 4_im_dump_$j.sql | grep "Dump completed" | wc -l` -ne 1 ]
	then
		print_error "\n" "Error while taking IAM tables dump for '$j' branch... Please see logs in '4_im_dump_$j.err'"
		final_fnc;
		exit 0;
	else
		[ ! -s "4_im_dump_$j.err" ] && rm -f 4_im_dump_$j.err 2>/dev/null		
	fi
	
	####5 Config Tables dump
        $mysqldump_query -f -t app_88_params app_88_params_audit efeap_dropdown file_names file_xtns im_accs_level im_bmmis_reports im_dept im_menu_item im_module im_module_menu_map im_role job_definition message srv_cnfg srv_op_config web_service_meta_data im_menu_item_bmmis im_module_menu_map_bmmis im_location_type edin_trans_type navvalmn_navdtl webservice_menu_map svintrate >5_config_dump_$j.sql 2>5_config_dump_$j.err

        if [ $? -ne 0 -o `tail -1 5_config_dump_$j.sql | grep "Dump completed" | wc -l` -ne 1 ]
        then
                print_error "\n" "Error while taking IAM tables dump for '$j' branch... Please see logs in '5_config_dump_$j.err'"
                final_fnc;
                exit 0;
        else
                [ ! -s "5_config_dump_$j.err" ] && rm -f 5_config_dump_$j.err 2>/dev/null
        fi


	####6 User Profile Table 
	$mysqldump_query -f -t --skip-opt im_user_profile >6_user_profile_table_$j.sql 2>6_user_profile_table_$j.err
	if [ $? -ne 0 -o `tail -1 6_user_profile_table_$j.sql | grep "Dump completed" | wc -l` -ne 1 ]
	then
		print_error "\n" "Error while taking 'im_user_profile' table dump for '$j' branch... Please see logs in '6_user_profile_table_$j.err'"
		final_fnc;
		exit 0;
	else
		[ ! -s "6_user_profile_table_$j.err" ] && rm -f 6_user_profile_table_$j.err 2>/dev/null
	fi

	echo -e " Dump taken successfully for '$j' branch"
done

echo -e "\n Data Dump taken successfully for all branches present in 'branch_list.txt'"
final_fnc;
rm -f table_name.txt
exit 0;
