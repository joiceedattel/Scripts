#!/bin/bash
User=`mysql  -e " select user from mysql.user where user='efeap_read';" | grep efeap`
if [ "$User" = "efeap_read" ]
  then
echo " User Present..... Kinldy check with efeap monitoring team "
else 
IPADDR="10.240.42.76"
my_user="efeap_read"
my_passwd="drvm@200315"
my_priv="select"
                mysql -vvv -uroot mysql -e "GRANT $my_priv ON efeap.* TO '$my_user'@'$IPADDR' identified by '$my_passwd'" 2>>privileges.err

		mysql -vvv -uroot mysql -e " flush privileges;"

		mysql -vvv -uroot mysql -e " show grants for '$my_user'@'$IPADDR'"  1>>${my_user}_privileges.log 2>>privileges.err 
fi
