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
export B="----------"

echo ${B} Starting biasDiff ${B}
sleep 3

echo ${B} Running native pings ${B}
NATIVE_RESULT=`$PING_COMMAND | grep min/avg/max`
NATIVE_DATA=`echo $NATIVE_RESULT | sed -E "s/.* = ([0-9\.]+)\/([0-9\.]+)\/([0-9\.]+)\/([0-9\.]+) ms/\1 \2 \3 \4/"`
NATIVE_MIN=`cut -d ' ' -f 1 <<< $NATIVE_DATA`
NATIVE_AVG=`cut -d ' ' -f 2 <<< $NATIVE_DATA`
NATIVE_MAX=`cut -d ' ' -f 3 <<< $NATIVE_DATA`
NATIVE_DEV=`cut -d ' ' -f 4 <<< $NATIVE_DATA`
echo Native min avg max stddev = $NATIVE_MIN
sleep 3

echo ${B} Running container pings${B}
CONTAINER_RESULT=`docker run --rm $PING_COMMAND | grep min/avg/max`
CONTAINER_DATA=`echo $CONTAINER_RESULT | sed -E  "s/.* = ([0-9\.]+)\/([0-9\.]+)\/([0-9\.]+)\/([0-9\.]+) ms/\1 \2 \3 \4/"`
echo Container min avg max stddev = $CONTAINER_DATA



echo ${B} Results ${B}
MIN_DIFF=`bc
echo Difference
