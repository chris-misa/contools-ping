#!/bin/bash

#
# Measure container bias by running from outside and inside container
# and taking difference of average RTT
#
# Arguments:
#   $1 host to ping
#   $2 number of pings
#
# Assumptions:
#   * docker is running
#   * the ping container is tagged 'ping'
#

export PING_COMMAND="ping -qnc $2 $1"


NATIVE_RESULT=`$PING_COMMAND | grep "round-trip min/avg/max/stddev"`

CONTAINER_RESULT=`docker run --rm $PING_COMMAND | grep "round-trip min/avg/max/stddev"`

echo Native: $NATIVE_RESULT
echo Container: $CONTAINER_RESULT
