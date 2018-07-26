#!/bin/bash

#
# Extract the raw RTT from a ping command
#
# Pipe ping to stdin, results on stdout
#

while read line
do
  PING_LINE=`grep "time=" <<< "$line"`
  if [ -n "$PING_LINE" ]
  then
    echo `sed -E "s/.* time=([0-9\.]+) ms/\1/" <<< "$PING_LINE"`
  fi
done < /dev/stdin
