
mysql -h10.50.69.134 -uvorwerk -pUhdgeZtwkIurNh37Uz4-Dhg27iezs -e "select p_code,p_starttime,p_endtime from vorwerk.cronjobs WHERE p_starttime BETWEEN '2015-06-21 08:40:00' AND '2015-06-22 08:40:00' order by p_starttime \G;" >>/tmp/query.txt

sed -i 's/p_code/cron_name/' /tmp/query.txt
sed -i 's/p_starttime/cron_start_time/' /tmp/query.txt
sed -i 's/p_endtime/cron_end_time/' /tmp/query.txt

/bin/mail -s "Crons ran in last 24 hours" joice.joseph@mindcurv.com </tmp/query.txt
