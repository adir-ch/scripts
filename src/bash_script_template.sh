# Linux bash scripts template 111
# By Adir Cohen


#! /bin/bash

# debug mode 
#set -x 

# need to use jobs control
#set -m 


function LOGGER {	
    if [[ "$DEBUG" == "1" && "$DEBUG_TO_VTY" == "1" ]] 
    then 
	echo "[$(date +%T)]: $1" 
    fi
	
    logger -t $PREFIX "$1"
}

function DEBUG {
    if [ "$DEBUG" == "1" ] 
    then 
	LOGGER "$1"
    fi
}	

function killScript {
	LOGGER "Terminating script (user request) at: $(date +%T)"
}

function readParams {
	
    DEBUG "reading cmd args"
       
}

function signalErrorHandle {
	DEBUG "Last command failed with: status=$?"
}

function signalExitHandle {
    LOGGER "Terminating script at: $(date +%T)"
    exit
}

function Usage {
        
    exit
}

function help {
    echo "SCRIPT version $VERSION"
    Usage
    exit
}

############################### Main 

# global script parameters
VERSION="1.0"
DEBUG=0	     		 			 # Dump debug info to system logs
DEBUG_TO_VTY=0			 		 # Dump debug info to screen (active only if DEBUG=1 too)
PREFIX="$(basename $0)"	 		 # system log file prefix (script name)
LOG_FILE=""   		 			 # Log file 
TEST_MODE=0
KEEP_RUNNING=1

# global variables

# Init parameters 

# signals handling 
trap signalErrorHandle ERR
trap signalExitHandle EXIT


# check if it a kill request 
[ "$1" == "--kill" ] && killScript

# starting log 
LOGGER "SCRIPT version: $VERSION starting"
 
# processing parameters
readParams "$@"	

# starting script		
