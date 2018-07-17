#!/bin/bash
#
# Shell script to setup and initialize a raw ping experiment
#   'active node' version
#
# 2018, Chris Misa
#

# Set variables
export DATE_TAG=`date +%Y%m%d%H%M%S`
export CONTAINER_PATH="chrismisa/contools:ping"
export MY_NAME="node1"
export TARGET_NAME="node2"
export NUM_PINGS=4
export BORDER="--------------------"
export TIME="`which time` -p"
export TCPDUMP_PID_LOC="tcpdump_pid"
export FILE_PREFIX="${DATE_TAG}_${MY_NAME}"

# Get ipv4 of node2
export TARGET_IPV4=`grep $TARGET_NAME /etc/hosts | cut -f 1`

echo "${BORDER} ${MY_NAME} started experiment at ${DATE_TAG} ${BORDER}"
echo "target name: ${TARGET_NAME}"
echo "target ipv4: ${TARGET_IPV4}"

# Install docker
sudo apt-get update
$TIME -o "${FILE_PREFIX}_install_docker.time" \
  sudo apt-get install -y docker.io
echo "${BORDER} Installed Docker ${BORDER}"

# Pull the container
$TIME -o "${FILE_PREFIX}_pull_container.time" \
  sudo docker pull $CONTAINER_PATH
echo "${BORDER} Pulled the container ${BORDER}"

# Start tcpdump listening to ip traffic on this node
# ----- explicity invoke subshell to get exact pid of tcpdump process
if [ -e $TCPDUMP_PID_LOC ]
then
  echo "Error: $TCPDUMP_PID_LOC already exists: experiment duplicated?"
fi
sudo bash -c 'tcpdump -i any -w "${FILE_PREFIX}.pcap" ip host $MY_NAME & echo $! > $TCPDUMP_PID_LOC'
echo "${BORDER} Started tcpdump listener (pid: `cat $TCPDUMP_PID_LOC`) ${BORDER}"

# Start host ping sequence
echo "${BORDER} Starting ipv4 ping from host ${BORDER}"
$TIME -o "${FILE_PREFIX}_host_ping.time" \
  ping -c $NUM_PINGS $TARGET_IPV4 > "${FILE_PREFIX}_host_ipv4.ping"
echo "${BORDER} Finished ipv4 ping from host ${BORDER}"

# Run dockerized ping sequence
echo "${BORDER} Starting ipv4 ping from container ${BORDER}"
$TIME -o "${FILE_PREFIX}_container_ping.time" \
  sudo docker run --rm $CONTAINER_PATH -c $NUM_PINGS $TARGET_IPV4 \
    > "${FILE_PREFIX}_container_ipv4.ping"
echo "${BORDER} Finished ipv4 ping from container ${BORDER}"

# Kill the tcpdump listener
sudo kill `cat $TCPDUMP_PID_LOC`
rm -f $TCPDUMP_PID_LOC
echo "${BORDER} Killed tcpdump listener ${BORDER}"

# Zip up the results

# Done
