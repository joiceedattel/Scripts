print_error()
{
        echo -e "$1\e[0;31;48m !! $2 !!\e[0m$3"
}

final_fnc()
{
        rm -rf table_list.txt final_count_list.txt 1>>/dev/null 2>>/dev/null
        echo " ~~~~~~~~~~~~~~ Ending Date & Time :: `date`  ~~~~~~~~~~~~~~~ " >> ${logfile_name}
        echo " ~~~~~~~~~~~~~~ Ending Date & Time :: `date`  ~~~~~~~~~~~~~~~ " >> ${errfile_name}
        if [ `grep -v "\~\~\~\~\~\~" ${logfile_name} 2>>/dev/null| wc -l ` -eq 0 ]
        then
                rm -f ${logfile_name}
        fi
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

logfile_name="count_status_${srv_name}_${td_date}.log"
errfile_name="count_status_${srv_name}_${td_date}.err"
echo " ~~~~~~~~~~~~~ Starting Date & Time :: `date`  ~~~~~~~~~~~~~~ " > ${logfile_name}
echo " ~~~~~~~~~~~~~ Starting Date & Time :: `date`  ~~~~~~~~~~~~~~ " > ${errfile_name}

echo -e "\n Enter Credentials for mysql connectivity:"
read -p "      1. User ID  : " my_user
read -p "      2. Password : " -s my_passwd
my_host="localhost"
my_schema="vorwerk"

if [ -z "$my_host" -o -z "$my_user" -o -z "$my_schema" -o -z "$my_passwd" ]
then
        print_error "\n" "Error: Given credentials contain null values"
        final_fnc;
        exit 1;
fi

echo -e "\n\n Testing mysql credentials...."
mysql_query="mysql -h$my_host -u$my_user -p$my_passwd $my_schema"

$mysql_query -sNB -e"show tables;" | grep -v "Tables_in_efeap" 1>table_list.txt 2>>${errfile_name}
if [ $? -ne 0 ]
then
        print_error "\n" "Error while connecting database with given credentials... Please see logs in '${errfile_name}'"
        final_fnc;
        exit 1;
fi

echo -e " Connected successfully to: $my_schema "
#sed -e "s/^/Select count(*) from /" table_list.txt | sed -e "s/$/;/" > final_count_list.txt 
count="1"
echo -e "\n Taking count of '`cat table_list.txt | wc -l`' tables present in '$my_host'@'$my_schema'\n Please Wait...."
	while [ true ]
	do
		for i in $(cat -n table_list.txt |  awk -v val=$count 'BEGIN{FS=" "} {if ( $1==val ){  print $2}}')
		do
			if [ $($mysql_query -vvv -e"show processlist" |grep -i count | wc -l ) -le "10" ]
				then
				echo "$i = `$mysql_query -B -e"select count(*) from $i" |grep -v count`" >> ${logfile_name} 2>>${errfile_name} &
				count=$(expr "$count" + 1)
			fi
		done
	sleep 1 
#	else
#		break;
#	fi
	done
	if [ $? -ne 0 ]
	then
	print_error "\n" "Error while taking count of tables... Please see logs in '${errfile_name}'"
        final_fnc;
        exit 1;
	fi
echo -e "\n Count of all tables taken successfully...\n Count status present in '`pwd`/${logfile_name}'"
final_fnc;
exit 0;
