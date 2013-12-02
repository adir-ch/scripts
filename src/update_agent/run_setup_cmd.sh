#! /bin/bash 
# set -x

source agent.conf
source agent_functions

function isAlive {
        okiMessage="1 packets transmitted, 1 received"
        cmd=`ping -c 1 -w 1 $1 | grep "1 packets transmitted, 1 received" | wc -l`
        echo $cmd
}

####################### MAIN ############################

export LD_LIBRARY_PATH=/local/develop/lib

REMOTER=${REMOTE_SETUP_CTL}
EXEC="cpd"
STRIPPED="cpd_s"
SETUP_LIST=""
QUITE_MODE="$1"
CMD="$@"

if [ "$QUITE_MODE" == "-q" ] 
then 
	QUITE_MODE=1
	shift 
	CMD="$@"
else 
	QUITE_MODE=0
fi 


if [ $CMD="$@" == "" ] 
then 
	echo "No command found"
    exit
fi


	
# getting setups (takes non empty lines that dont start with  #)
tempList=$(getActiveSetups | egrep -v "[!(^#)]" | grep -v '^$' | egrep "^[0-9]" | tr -s '\n' ' ')

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

# looping on setups
for setup in $SETUP_LIST
   do
	
        if [ $(isAlive $setup) -eq 1 ]
        then
                echo -e "\\033[1;31m---------------------------------------------------\\033[1;0m"
                echo "handle setup: $setup"
                if [ $QUITE_MODE -eq 1 ] 
				then 
					$REMOTER -q linux $setup output "$CMD"
				else 
					$REMOTER linux $setup output "$CMD"
				fi
        else
		echo -e "\\033[1;31m---------------------------------------------------\\033[1;0m"
        echo -e "\\033[05;31m-$setup - is not responding-\\033[1;0m"
        fi
   done


