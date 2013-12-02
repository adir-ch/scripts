#! /bin/bash

source agent.conf
source agent_functions

getActiveSetups | egrep -v "(^#|^$)" | tr -d ' '
