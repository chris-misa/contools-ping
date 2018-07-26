#!/bin/bash

#
# Attempts to extract the startup time for the given strace results
#

if [ $# -ne 2 ]
then
  echo "Usage: getStartupTime <native strace> <container strace>"
  exit 1
fi

TARGET_IP="216.58.216.142"

# First time is the first entry in the trace
NATIVE_FIRST_TIME_LINE=`cat $1 | grep -m 1 ".*"`
NATIVE_FIRST_TIME=`echo $NATIVE_FIRST_TIME_LINE | sed -E 's/[^ ]+ +([0-9\.]+) .*/\1/'`

# Find the second time by the first time we send to the given address
NATIVE_SECOND_TIME_LINE=`cat $1 | grep -m 1 "sendto.*$TARGET_IP"`
NATIVE_SECOND_TIME=`echo $NATIVE_SECOND_TIME_LINE | sed -E 's/[^ ]+ +([0-9\.]+) .*/\1/'`

echo From line:
echo $NATIVE_FIRST_TIME_LINE
echo To line:
echo $NATIVE_SECOND_TIME_LINE

# Subtract the two as floating points
NATIVE_START_TIME=`python -c "print($NATIVE_SECOND_TIME - $NATIVE_FIRST_TIME)"`

echo Native start time:
echo $NATIVE_START_TIME
echo "\n"

# First time is the first entry in the trace
CONTAINER_FIRST_TIME_LINE=`cat $2 | grep -m 1 ".*"`
CONTAINER_FIRST_TIME=`echo $CONTAINER_FIRST_TIME_LINE | sed -E 's/[^ ]+ +([0-9\.]+) .*/\1/'`

# Find the second time by the first time we send to the given address
CONTAINER_SECOND_TIME_LINE=`cat $2 | grep -m 1 "sendto.*$TARGET_IP"`
CONTAINER_SECOND_TIME=`echo $CONTAINER_SECOND_TIME_LINE | sed -E 's/[^ ]+ +([0-9\.]+) .*/\1/'`

echo From line:
echo $CONTAINER_FIRST_TIME_LINE
echo To line:
echo $CONTAINER_SECOND_TIME_LINE

# Subtract the two as floating points
CONTAINER_START_TIME=`python -c "print($CONTAINER_SECOND_TIME - $CONTAINER_FIRST_TIME)"`

echo Container start time:
echo $CONTAINER_START_TIME
