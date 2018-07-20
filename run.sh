#
# Run invetro ping experiment
#
# Must be run as sudo for perf and docker commands
#
# 2018, Chris Misa
#

# Probably need to use cgroups or something to restrict perf's view to
# just the container: current configuration get solidly bogged down
# in the container engine's system calls

# Status: phase 1: timing only
# Assumes docker etc are up and running

# Make sure we're running as root
if [ `id -u` -ne 0 ]
then
  echo "Error: Rerun under sudo or as root"
  exit 1
fi

export B="----------"
export TARGET_NAMES="google.com amazon.com economist.com"
export DATE_TAG=`date +%Y%m%d%H%M%S`
export PINGS=3
export CONTAINE_PID=`ps -e | grep containe | cut -d ' ' -f 1`
export PERF_FLAGS="-T -e '{syscalls:sys_enter_*,syscalls:sys_exit_*}'"
export PERF_PID_FILE="perf.pid"

echo "${B} Starting Experiment at $DATE_TAG ${B}"
echo "targets: $TARGET_NAMES"
echo "containe pid: ${CONTAINE_PID}"

# Make sure there is no perf_pid file
if [ -e $PERF_PID_FILE ]
then
  echo "Error: $PERF_PID_FILE already exists: experiment duplicated?"
  exit 1
fi

# Native pings
echo "${B} Running Native Pings ${B}"
for i in $TARGET_NAMES
do
  echo "Pinging $i"
  perf record -o ${DATE_TAG}_${i}_native.perf $PERF_FLAGS ping -c $PINGS $i \
    > ${DATE_TAG}_${i}_native.ping
done

# Container pings
echo "${B} Running container pings ${B}"
for i in $TARGET_NAMES
do
  bash -c "perf record -o ${DATE_TAG}_${i}_container.perf $PERF_FLAGS -p $CONTAINE_PID" &
  echo $! > $PERF_PID_FILE
  echo "Pinging  $i"
  docker run --rm ping -c $PINGS $i \
    > ${DATE_TAG}_${i}_container.ping
  kill `cat $PERF_PID_FILE`
done
rm -f $PERF_PID_FILE
