#!/bin/bash

#
# Measure container bias by running from outside and inside container
# and taking difference of average RTT
#
# Arguments:
#   $1 number of pings
#   $2 host to ping
#
# Assumptions:
#   * docker is running
#   * the ping container is tagged 'ping'
#

export PING_COMMAND="ping -qnc $1 $2"


export NATIVE_RESULT=`$PING_COMMAND | grep min/avg/max`

export CONTAINER_RESULT=`docker run --rm $PING_COMMAND | grep min/avg/max`

echo "Native: $NATIVE_RESULT"
echo "Container: $CONTAINER_RESULT"
