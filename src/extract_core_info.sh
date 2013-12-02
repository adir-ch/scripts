#!/bin/bash
 
# Extract core-file info - Adir :)

 
if [[ $# -lt 1 || $# -gt 2 ]]
then
  echo "Usage: `basename $0` <binary-image> [core file]" 
  exit -1
fi

binimg=$1

if [ $# -eq 1 ]
then 
  cores=`find . -type f -regextype posix-egrep  -regex "./*core\.[1-9]+"`
fi 

if [ $# -eq 2 ]
then 
  cores=$2
fi
 
for core in $cores 
do 
  gdblogfile="log_$(basename $core).gdb"
  rm $gdblogfile
 
  bininfo=`ls -l $binimg`
  coreinfo=`ls -l $core`
 
  gdb -batch \
      -ex "set logging file $gdblogfile" \
      -ex "set logging on" \
      -ex "set pagination off" \
      -ex "printf \"**\n** Process info for $binimg - $core \n** Generated `date`\n\"" \
      -ex "printf \"**\n** $bininfo \n** $coreinfo\n**\n\"" \
      -ex "file $binimg" \
      -ex "core-file $core" \
      -ex "bt" \
      -ex "info proc" \
      -ex "printf \"*\n* Libraries \n*\n\"" \
      -ex "info sharedlib" \
      -ex "printf \"*\n* Memory map \n*\n\"" \
      -ex "info target" \
      -ex "printf \"*\n* Registers \n*\n\"" \
      -ex "info registers" \
      -ex "printf \"*\n* Current instructions \n*\n\"" -ex "x/16i \$pc" \
      -ex "printf \"*\n* Threads (full) \n*\n\"" \
      -ex "info threads" \
      -ex "bt" \
      -ex "thread apply all bt full" \
      -ex "printf \"*\n* Threads (basic) \n*\n\"" \
      -ex "info threads" \
      -ex "thread apply all bt" \
      -ex "printf \"*\n* Done \n*\n\"" \
      -ex "quit" 
done
