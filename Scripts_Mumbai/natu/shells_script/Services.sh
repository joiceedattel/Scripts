#!/bin/bash
#For Making the Services ON/OFF on the Particular System

echo " Disabling Unwanted services "

Disable_Services=('NetworkManager' 'abrt-ccpp' 'abrtd' 'autofs' 'bluetooth' 'cups' 'dhcpd' 'ip6tables' 'iptables' 'iscsi' 'iscsid' 'mdmonitor' 'named' 'postfix' 'rhnsd' 'smb' 'tftp')

	for Services in ${Disable_Services[@]}
		do

			chkconfig --list $Services

		done

