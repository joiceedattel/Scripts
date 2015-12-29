exec &> /tmp/table_count.txt

	echo "---------------'2012-03-01'------------- "
	owning_location="284 286 287 289 28A 28C 28D 28F 28G 28H 28I 28J 28M 28N 28P 28Q 28R 28S 28T 28U 28V 291 293 294 295 297 D028 H028 U028"
	#owning_location="284 286";
	count=0
	for i in $owning_location
	do
		tmp=`mysql -sN efeap -e "select count(*) from pmh where owning_location='$i' and year_column=2012 and creation_ts like '2012-03-01 %';"`;
		count=`expr $count + $tmp`;
	done
	echo "pmh = $count"

	tablename="osh mkh nbh ach csh edh iph pyh ssh"
	for j in $tablename
	do
		echo "$j = `mysql -sN efeap -e "select count(*) from $j where year_column=2012 and creation_ts like '2012-03-01 %'"`"
	done
	echo "---------------------------------------- "
done
exit 0



