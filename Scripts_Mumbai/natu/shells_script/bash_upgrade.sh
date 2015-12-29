#!/bin/bash

dir=$(pwd)
cp -r /etc/profile /etc/bashrc $dir 

[ $(id -un) != 'root' ] && echo "Execute the Script through root user" && exit | tee -a $dir/bash_update.log

	if [ $(rpm -qa|grep bash |cut -d '-' -f3 |cut -d '.' -f1) -gt 33 ]  && [ $(sha256sum -c $dir/SHA-sum-bash |awk -F ':' '{print $2}') == 'OK' ]
	then
		echo "======================================="  | tee -a $dir/bash_update.log
		echo "Checking vulnerable before upgradation " | tee -a $dir/bash_update.log
		echo "======================================="  | tee -a $dir/bash_update.log
		
		cd /tmp; rm -f /tmp/echo; env 'x=() { (a)=>\' bash -c "echo date"; cat /tmp/echo | tee -a $dir/bash_update.log

		echo "================================="  | tee -a $dir/bash_update.log
		echo "   Proceeding to upgrade bash.."	 | tee -a $dir/bash_update.log	
		echo "================================="  | tee -a $dir/bash_update.log

#		rpm -Uvh $dir/bash-3.2-33.el5_11.4.x86_64.rpm 2> /dev/null  | tee -a $dir/bash_update.log
		if  [ $? == 0 ] && [ $(rpm -qa|grep bash |cut -d '-' -f3|cut -d '.' -f1) -eq 33 ]
 		then
		echo "================================="  | tee -a $dir/bash_update.log
		echo "Bash rpm is upgraded successfully"  | tee -a $dir/bash_update.log
		echo "================================="  | tee -a $dir/bash_update.log
			
		echo "======================================="  | tee -a $dir/bash_update.log
		echo "Checking vulnerable after upgradation " | tee -a $dir/bash_update.log
		echo "======================================="  | tee -a $dir/bash_update.log
		cd /tmp; rm -f /tmp/echo; env 'x=() { (a)=>\' bash -c "echo date"; cat /tmp/echo | tee -a $dir/bash_update.log

		
		echo "======================================="  | tee -a $dir/bash_update.log
		echo "Checking process need to be restarted " | tee -a $dir/bash_update.log
		echo "======================================="  | tee -a $dir/bash_update.log
		grep -l -z '[^)]=() {' /proc/[1-9]*/environ | cut -d/ -f3 | tee -a $dir/bash_update.log

		fi

	else
		echo "================================="  | tee -a $dir/bash_update.log
		echo "  Bash already upgraded  "   | tee -a $dir/bash_update.log
		echo "================================="  | tee -a $dir/bash_update.log
	fi													
