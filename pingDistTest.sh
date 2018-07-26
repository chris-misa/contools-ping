#!/bin/bash

#
# Ping at various rate and collect data for
# testing the RTT distribution
#

#
# Make sure to test for ipv6 connectivity!

declare -a intervals=(0.2 0.4 0.6 0.8 1.0 1.2)
export NUM_PINGS=1000
export TARGET_HOST="node2"
export DATE_TAG=`date +%Y%m%d%H%M%S`
export B="----------"

export NATIVE_PING="/local/repository/iputils/ping"
export CONTAINER_PING="docker run --rm chrismisa/contools:ping"

echo $B Starting Ping Distribution Gathering $B
mkdir $DATE_TAG
cd $DATE_TAG

# Run native ping sequence
echo $B Running native pings $B
for i in ${intervals[@]}
do
  sleep 5
  echo Interval: $i
  echo ipv4 . . .
  $NATIVE_PING -4 -i $i -c $NUM_PINGS $TARGET_HOST > native_v4_${i}.ping
  sleep 5
  echo ipv6 . . .
  $NATIVE_PING -6 -i $i -c $NUM_PINGS $TARGET_HOST > native_v6_${i}.ping
done

# Run container ping sequence
echo $B Running container pings $B
for i in ${intervals[@]}
do
  sleep 5
  echo Interval: $i
  echo ipv4 . . .
  $CONTAINER_PING -4 -i $i -c $NUM_PINGS $TARGET_HOST > native_v4_${i}.ping
  sleep 5
  echo ipv6 . . .
  $CONTAINER_PING -6 -i $i -c $NUM_PINGS $TARGET_HOST > native_v6_${i}.ping
done
