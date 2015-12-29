#/bin/bash


#Objective
################################################################################################
#Find the size of the table from dbsb and check if space is available in /archive directory
#If space is available then take the dump of the specific table and put it to archive directory.
#################################################################################################


cluster_ip=$(grep MYSQL /etc/hosts|gawk '{print $1}')
echo $cluster_ip
db_name='efeap'
dump_path='/archive/cluster_table_dumps'

for i in `cat /tmp/omkar/table_list.txt`
do
size_of_table=$("mysql -B -S -e -h$cluster_ip -uremoteadmin -padmin123 -e 'select table_name' 'Table Name',sum(data_length + index_length) / 1024  'Table size in KB' from information_schema.TABLES where  table_schema='$dbname' and table_name='$i'")

archive_size=$(df |grep archive|gawk '{print $3}'|tail -1)

#Comparing size of table with partition size :)
if [ $size_of_table  > $archive_size -a `ps aux|grep $j|grep -v 'grep'|wc -l` == 0 ]
then
	echo  "Skipping $i as space not available on /archive partition" |tee -a /tmp/omkar/tabledump_script.log
else
        mysqldump -P3306  -h$cluster_ip -uremoteadmin -padmin123 $db_name $i |tee -a $dump_path/$i.sql
        if [ $? == 0 ] 
	then
		echo "$i table dump completed successfully" |tee -a /tmp/omkar/tabledump_script.log
	else
		echo "$i table dump failed" |tee -a /tmp/omkar/tabledump_script.log
	fi
      	
        echo `gzip $dump_path/$i.sql &`
        mysql -h$cluster_ip -uremoteadmin -padmin123 $db_name -e "optimize table $i" |tee -a /tmp/omkar/tabledump_script.log
        j="$i"
fi
done


