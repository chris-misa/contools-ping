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

declare -a intervals=(0.2 1.0) # (0.2 0.4 0.6 0.8 1.0 1.2)
export NUM_PINGS=3 #1000
export TARGET_IPV4="10.10.1.2"
export TARGET_IPV6="fe80::eeb1:d7ff:fe85:6ae3"
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
  $NATIVE_PING -i $i -c $NUM_PINGS $TARGET_IPV4 > native_v4_${i}.ping
  sleep 5
  echo ipv6 . . .
  $NATIVE_PING -i $i -I eno1d1 -c $NUM_PINGS $TARGET_IPV6 > native_v6_${i}.ping
done

# Run container ping sequence
echo $B Running container pings $B
for i in ${intervals[@]}
do
  sleep 5
  echo Interval: $i
  echo ipv4 . . .
  $CONTAINER_PING -i $i -c $NUM_PINGS $TARGET_IPV4 > container_v4_${i}.ping
  # sleep 5
  # echo ipv6 . . .
  # $CONTAINER_PING -i $i -c $NUM_PINGS $TARGET_IPV6 > container_v6_${i}.ping
done
