#!/bin/bash

#
# Ping at various rate and collect data for
# testing the RTT distribution
#

#
# IP addresses currently manually configured because
# the rspec does not enter ipv6 in /etc/hosts . . .
#
# Leaving out ipv6 as we're still working on getting containers into it
#

declare -a intervals=(0.2 1.0) #(0.2 0.3 0.5 1.0)
declare -a sizes=(16 504) #(16 56 120 504 1472)
export NUM_PINGS=3 #2000
export TARGET_IPV4="10.0.0.190"
export TARGET_IPV6="2601:1c0:cb03:1a9d:226:8ff:fee3:b1b8"
export DATE_TAG=`date +%Y%m%d%H%M%S`
export B="----------"

export NATIVE_PING="$(pwd)/iputils/ping"
export CONTAINER_PING="docker run --rm chrismisa/contools:ping"

export NATIVE_INTERFACE="wlp2s0"

echo $B Starting Ping Distribution Gathering $B
mkdir $DATE_TAG
cd $DATE_TAG

for i in ${intervals[@]}
do
  echo $B Interval: $i $B
  sleep 5
  for s in ${sizes[@]}
  do
    echo $B Packet Size: $s $B
    sleep 5
    echo Native ipv4 . . .
    $NATIVE_PING -i $i -s $s -c $NUM_PINGS $TARGET_IPV4 > native_v4_i${i}_s${s}.ping
    sleep 5
    echo Native ipv6 . . .
    $NATIVE_PING -i $i -s $s -c $NUM_PINGS -I $NATIVE_INTERFACE $TARGET_IPV6 > native_v6_i${i}_s${s}.ping
    sleep 5
    echo Container ipv4 . . .
    $CONTAINER_PING -i $i -s $s -c $NUM_PINGS $TARGET_IPV4 > container_v4_i${i}_s${s}.ping
    sleep 5
    echo Container ipv6 . . .
    $CONTAINER_PING -i $i -s $s -c $NUM_PINGS $TARGET_IPV6 > container_v6_i${i}_s${s}.ping
  done
done
