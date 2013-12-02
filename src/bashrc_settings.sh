##########################################
# Shell functions + aliases 
##########################################

# work space manager defines

if [ -f ~/.ws_manager.conf ] 
then  
	source ~/.ws_manager.conf
	source ~/Work/scripts/ws_manager/ws_functions
fi 

# aliases 
alias rm='/bin/rm -i'
#alias cp='/bin/cp -i'
alias mv='/bin/mv -i'
alias ls='ls --color'
alias ll='ls -l --color'
alias grep='grep --color'
alias egrep='egrep --color'
alias vi='/usr/bin/vi'
alias xt='xterm -geometry 100x30 -bg gray -fg black'
alias ssu='sudo'
alias winrar='wine ~/Temp/WinRAR/WinRAR.exe'
alias gvim='gvim -geometry 120x40'
alias sb='/opt/Sublime/sublime_text &'
alias tmc='cd / ; `which mc` --colors  editnormal=white,black /local /'
alias g++='g++ -g3 -Wall -pedantic -std=c++11'

# Development 
alias mi='time make install'
alias mci='time make clean install'
alias mcm='make clean ; make'

# Locations 
alias tester='cd $DEV/source/tester/src'
alias scripts='cd $DEV/scripts'
alias dev='cd ~/Development'
alias projects="cd $DEV/Projects"

# CVS
alias cvs_chk_changes='cvs -n -q up -A 2>&1 | egrep "^(U|M|C).*"'
alias cvs_chk_locals='cvs status 2>&1 | grep "Status:" | grep Local'
alias cvs_list_modified='cvs -n up 2>&1 | egrep "^M.*" | cut -d " " -f2-'

function cvs_revert { rm -f $1; cvs up $1; }

# ws manager aliases 

if [ -f ~/.ws_manager.conf ] 
then 
	alias ws_change='$SCRIPTS/ws_manager/ws_change.sh'
	alias ws_del='$SCRIPTS/ws_manager/ws_del.sh'
	alias ws_list='$SCRIPTS/ws_manager/ws_list.sh'
	alias ws_note='$SCRIPTS/ws_manager/ws_note.sh'
	alias ws_to='$SCRIPTS/ws_manager/ws_to.sh'
	alias ws_add='$SCRIPTS/ws_manager/ws_add.sh'
fi

# PeerApp setup 
alias pa-186='ssh adir@192.168.6.186'
alias pa-build='ssh root@192.168.6.175'
alias local_peerapp='cd ~/Development/PeerApp/local-dev-machine'
alias remote_peerapp='cd ~/Development/PeerApp/remote-dev-machine'

# functions 
function setup-terminal() { putty -geometry 80x25 -telnet 172.16.253.87 $1 ; } 
function terminal() { putty -geometry 80x25 -telnet $1 $2 ; } 
function fff() { find . -type f -iname '*'$*'*' -ls ; }
function ff() { find . -name "*${1}*" ; }
function ffp() { path=$1; shift ; find $path -type f -iname '*'$*'*' -ls ; }
function cvne() { cvsedit $1 && nedit $1 > /dev/null 2>&1 &  }
function ne() { nedit $@ > /dev/null 2>&1 & }
function nw() { nedit $(which $1) > /dev/null 2>&1 & }
function remote_acc { host=$1 ; shift ; remote_setup.pl linux $host output "$*"; }
function rd { rdesktop -g 1152x864 -r sound:local  $1 & }
function srcdiff { vsdiff -t -filespec "*.c *.cpp *.h makefile Makefile" -excludefilespec "Entries* Tag*" $1 $2 & }  

function usbmount { 
	DEV=$(ssu fdisk -l | egrep "LBA|W95|FAT32" | cut -d ' ' -f1 | cut -d '/' -f3)
	if [ "$DEV" == "" ]; then DEV=$1 ; fi  
	ssu mount -t vfat -o utf8=true /dev/$DEV /local/usb/ 
} 

function flashusbmount { 
	ssu mount /dev/$1 /local/usb/ 
} 

function mame { /usr/games/mame -w -rompath  /home/adir/Temp/roms  $1 ; }  
function service { /etc/init.d/$1 $2; } 
function vs { cd /opt/slickedit/bin ; ./vs & }

