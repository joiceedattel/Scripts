Given Pack '1branch_dump_v1.tgz' contains shell script that will take dump of branch present in 'branch_list.txt' from local efeap database which can be used to setup first branch only. The folder and file structure of the given pack is:

1branch_dump
|-- 1branch_dump.sh
|-- README.txt
`-- branch_list.txt

NOTE: I. EXECUTE THIS SCRIPT WITH PROPER PRIVILEGES TO MySQL USER.
     II. ENSURE THAT PARTITION WILL BE HAVING ENOUGH SPACE TO STORE DATA DUMP FILES.

### Steps for following process:

I) Login to Server from which you want to take dump of all efeap tables branch wise. Ensure that MySQL is running local to that server.

II) Copy '1branch_dump_v<version>.tgz' to the decided directory of server in which proper space is available.

III) Untar '1branch_dump_v<version>.tgz'
	~]#tar xvfz 1branch_dump_v<version>.tgz

IV) Open branch_list.txt and replace <brachcode> with suitable brach code.

IV) Execute script '1branch_dump.sh' 
	~]#cd 1branch_dump
	~]#sh 1branch_dump.sh

	Script ask for some inputs as shown below:
	  a) Credentials to connect Mysql

        	 Enter Credentials for mysql connectivity:
        	      1. User ID  : <user_id>
	              2. Password : <passwd>

	     - enter <user_id> and <passwd> to connect database with proper privileges.

    The execution of the script may take some time.

V) Make sure that error file should not be created.

In case of any queries, Please contact CO_IT Team at SDC Mumbai.
