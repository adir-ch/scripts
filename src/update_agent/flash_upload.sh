#! /bin/bash


source /local/scripts/update_agent/agent.conf
source /local/scripts/update_agent/agent_functions

############# Functions 

function backupLastVersion {
	backupName="/root/$(basename $2).ver"
	echo "backup: $2 -> $backupName"
	$REMOTER -q linux $setup no_output "echo '[$(date +%T)]: saving last version: $2' > $OUTPUT_TTY"
	$REMOTER -q linux $1 output "cp $2 $backupName"
}

function updateSetup {
	$REMOTER -q linux $setup no_output "echo '[$(date +%T)]: uploading files' > $OUTPUT_TTY"
	for file in $UPLOAD_FILES_LIST 
	  do
                
		from=$(echo $file | cut -d ';' -f1)
		to=$(echo $file | cut -d ';' -f2)
		doStrip=$(echo $file | cut -d ';' -f3)
		if [ "$doStrip" == "Y" ]; then 
			ssu strip $from
		fi
		
		backupLastVersion $setup "$to/$(basename $from)"
		/usr/bin/scp $from root@$1:$to
		
		# lilo for new kernel image
		if [ $(echo $to | grep bzImage | wc -l) -eq 1 ]; then 
			$REMOTER linux $1 output "lilo"
		fi 	 
	  done

	$REMOTER -q linux $setup no_output "echo '[$(date +%T)]: restarting expand' > $OUTPUT_TTY"
	$REMOTER linux $1 output "shlog -c xslcp ; expand_run &"
	#$REMOTER linux $1 output "shlog -c xslcp ; expand_run"
	#$REMOTER linux $1 output "cpd --v"
	#echo "local cpd ver: `$DEV_BIN/cpd --v`"
	$REMOTER -q linux $setup no_output "echo '[$(date +%T)]: update finished' > $OUTPUT_TTY"
}

function isAlive {
	okiMessage="1 packets transmitted, 1 received"
	cmd=`ping -c 1 -w 1 $1 | grep "1 packets transmitted, 1 received" | wc -l`	
	echo $cmd
}

function parseSetupsList {
	# getting setups (takes non empty lines that dont start with  #)
	tempList=$(getActiveSetups | egrep -v '[!(^#)]' | grep -v '^$' | egrep "^[0-9].*" | tr -s '\n' ' ')

	for setup in $tempList
	   do
        	if [ $(echo $setup | egrep -v "[!^#]" | wc -l) -eq 1 ]
	        then
        	        if [ $(isAlive $setup) -eq 1 ]
					then
						echo "Adding: $setup"
                		SETUP_LIST="$SETUP_LIST $setup"
					else 
						echo -e "Setup $setup \\033[1;31m- is not responding and removed \\033[1;0m"
					fi
	        fi
	   done

	if [ "$SETUP_LIST" == "" ]
	then
        	echo "No setups found"
	        exit
	fi
}


function parseUpdateList {
	# getting files to upload
	UPLOAD_FILES_LIST=$(cat $UPDATE_LIST_FILE | egrep -v '(^#|^$)' | tr -d ' ')
	if [ "$UPLOAD_FILES_LIST" == "" ] 
	then 
		echo "No files for update found - aborting"
                exit
	fi

	echo "Uploading files:"
	for file in $UPLOAD_FILES_LIST
          do
				from=$(echo $file | cut -d ';' -f1)
                echo "$from"
          done

}

############# Main

# globals

REMOTER=${REMOTE_SETUP_CTL}
CONF_FILE=${SETUPS_LIST_SRC}
UPDATE_LIST_FILE=${FILES_LIST_SRC}
UPLOAD_FILES_LIST=""
SETUP_LIST=""
OUTPUT_TTY=/dev/ttyS1

# exporting library path
export LD_LIBRARY_PATH=${DEV_LIB}

# printing start data 
echo "Using conf files: $CONF_FILE, $UPDATE_LIST_FILE"

parseSetupsList # builds setups list from file 
parseUpdateList # builds upload files list 

# Stopping setups 
for setup in $SETUP_LIST 
   do 
	if [ $(isAlive $setup) -eq 1 ] 
	then
		echo -e "\\033[1;31m---------------------------------------------------\\033[1;0m"
		echo "Stopping setup: $setup"
		$REMOTER -q linux $setup no_output "echo '[$(date +%T)]: starting flash update' > $OUTPUT_TTY"
		$REMOTER -q linux $setup no_output "echo '[$(date +%T)]: stopping expand' > $OUTPUT_TTY"
		$REMOTER linux $setup output "killall -9 expsh ; expand_stop; cpd --kill"
	else 
		echo -e "\\033[1;31m---------------------------------------------------\\033[1;0m"
		echo -e "\\033[05;31m-$setup - is not responding-\\033[1;0m"
	fi
   done 

# Updating setups 
for setup in $SETUP_LIST
   do
	if [ $(isAlive $setup) -eq 1 ]
        then
		echo -e "\\033[1;31m---------------------------------------------------\\033[1;0m"
        	echo -e "Updating setup: $setup (logs will be deleted !!!)"
        	updateSetup $setup
	else
                echo "$setup - is not responding"
        fi
   done
