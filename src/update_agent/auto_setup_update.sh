#! /bin/bash

PATH=/local/programming/scripts/update_agent/:$PATH
source agent.conf


############# Main

REMOTE_UPD_DLGT=${PWD}/flash_upload.sh
REMOTE_CMD=${PWD}/run_setup_cmd.sh

# checking for root 

if [ $(id -u) -ne 0 ] 
then 
     echo "You must be root to update"
     exit
fi 

# validating setups 

if [ ! -f $SETUPS_LIST_SRC ] 
then 
     echo "could not find setups file: $SETUPS_LIST_SRC"
     exit
fi

# updating setups
$REMOTE_UPDATOR $REMOTE_UPD_DLGT

# saving conf and reboot acc's
$REMOTE_CMD "cltgz.sh ; reboot"
