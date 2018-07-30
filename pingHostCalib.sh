#!/bin/bash

#
# Attempt calibration vs host by pinging host's interface ip
# to measure bias. Test with measurements from container compd with 
# measurements from host
#
# Initial experiment with only one ping setting
#
declare -a intervals=(0.5 1.0) #(0.2 0.3 0.5 1.0)
declare -a sizes=(16 120) #(16 56 120 504 1472)
export NUM_PINGS=3

export TARGET_IPV4="10.0.0.190"
export TARGET_IPV6="2601:1c0:cb03:1a9d:226:8ff:fee3:b1b8"

export HOST_IPV4="10.0.0.204"
export HOST_IPV6="2601:1c0:cb03:1a9d::ed89"

export DATE_TAG=`date +%Y%m%d%H%M%S`
export B="----------"

export NATIVE_PING="$(pwd)/iputils/ping"
export CONTAINER_NAME="chrismisa/contools:ping"
export NATIVE_INTERFACE="eno1d1"

export PING_SCRIPT="ping_script.sh"

if [ -e $PING_SCRIPT ]
then
  echo "Error: $PING_SCRIPT already exists, not going to overwrite"
  exit 1
fi

echo $B Starting Ping Host-correction Testing $B

mkdir $DATE_TAG
cd $DATE_TAG

echo IPV4 . . .

for i in ${intervals[@]}
do
  echo interval: $i
  for s in ${sizes[@]}
  do
    echo payload size: $s
    sleep 5
    echo $B Running local control $B
    $NATIVE_PING -i $i -s $s -c $NUM_PINGS $TARGET_IPV4 > native_target_v4_i${i}_s${s}.ping

    sleep 5
    echo $B Running container $B
    echo "ping -i $i -s $s -c $NUM_PINGS $HOST_IPV4 > /data/container_host_v4_i${i}_s${s}.ping; \
          sleep 5; \
          ping -i $i -s $s -c $NUM_PINGS $TARGET_IPV4 > /data/container_target_v4_i${i}_s${s}.ping" \
      > $PING_SCRIPT
    chmod 755 $PING_SCRIPT
    docker run --rm -v $(pwd):/data $CONTAINER_NAME batch /data/$PING_SCRIPT
    rm -f $PING_SCRIPT
  done
done

echo IPV6 . . .

for i in ${intervals[@]}
do
  echo interval: $i
  for s in ${sizes[@]}
  do
    echo payload size: $s
    sleep 5
    echo $B Running local control $B
    $NATIVE_PING -6 -i $i -s $s -c $NUM_PINGS $TARGET_IPV6 > native_target_v6_i${i}_s${s}.ping

    sleep 5
    echo $B Running container $B
    echo "ping -6 -i $i -s $s -c $NUM_PINGS $HOST_IPV6 > /data/container_host_v6_i${i}_s${s}.ping; \
          sleep 5; \
          ping -6 -i $i -s $s -c $NUM_PINGS $TARGET_IPV6 > /data/container_target_v6_i${i}_s${s}.ping" \
      > $PING_SCRIPT
    chmod 755 $PING_SCRIPT
    docker run --rm -v $(pwd):/data $CONTAINER_NAME batch /data/$PING_SCRIPT
    rm -f $PING_SCRIPT
  done
done
