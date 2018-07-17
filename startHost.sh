#!/bin/bash
#
# Shell script to setup and initialize a raw ping experiment
#   'active node' version
#
# 2018, Chris Misa
#

# Set variables
DATE_TAG=`date +%Y%m%d%H%M%S`
CONTAINER_PATH="chrismisa/contools:ping"
MY_NAME="node1"
TARGET_NAME="node2"
NUM_PINGS=4
BORDER="--------------------"
TIME="`which time` -p"

# Get ipv4 of node2
TARGET_IPV4=`grep $TARGET_NAME /etc/hosts | cut -f 1`

echo "${BORDER} ${MY_NAME} started experiment at ${DATE_TAG} ${BORDER}"
echo "target name: ${TARGET_NAME}"
echo "target ipv4: ${TARGET_IPV4}"

# Install docker
sudo apt-get update
$TIME -o "${DATE_TAG}_install_docker.time" \
  sudo apt-get install -y docker.io
echo "${BORDER} Installed Docker ${BORDER}"

# Pull the container
$TIME -o "${DATE_TAG}_pull_container.time" \
  sudo docker pull $CONTAINER_PATH
echo "${BORDER} Pulled the container ${BORDER}"

# Start tcpdump listening to ip traffic on this node
sudo tcpdump -i any -w "${DATE_TAG}_${MY_NAME}.pcap" ip host $MY_NAME &
TCPDUMP_PID=$!
echo "${BORDER} Started tcpdump listener (pid: ${TCPDUMP_PID}) ${BORDER}"

# Start host ping sequence
echo "${BORDER} Starting ipv4 ping from host ${BORDER}"
$TIME -o "${DATE_TAG}_host_ping.time" \
  ping -c $NUM_PINGS $TARGET_IPV4 > "${DATE_TAG}_host_ipv4.ping"
echo "${BORDER} Finished ipv4 ping from host ${BORDER}"

# Run dockerized ping sequence
echo "${BORDER} Starting ipv4 ping from container ${BORDER}"
$TIME -o "${DATE_TAG}_container_ping.time" \
  sudo docker run --rm $CONTAINER_PATH -c $NUM_PINGS $TARGET_IPV4 \
    > "${DATE_TAG}_container_ipv4.ping"
echo "${BORDER} Finished ipv4 ping from container ${BORDER}"

# Kill the tcpdump listener
sudo kill $TCPDUMP_PID
echo "${BORDER} Killed tcpdump listener ${BORDER}"

# Zip up the results

# Done
