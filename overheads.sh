#
# Time overhead tests for ping
#
# Assumptions:
#   * Running as sudo (for docker and tracers);
#   * Docker is running;
#   * There is an appropriate docker 'ping' container.
#
# Outputs:
#   * Tracefile are save with date prefix
#   * Ping output dumped to /dev/null
#
# 2018, Chris Misa
#

# Would be nice to restict traces to container only. . . .

#
# Set up environment
#

# Some handy variables
export PING_COMMAND='ping -c 5 google.com'
export CONTAINE_PID=`ps -e | grep containe | sed -E 's/ *([0-9]*) .*/\1/'`
export DATE_TAG=`date +%Y%m%d%H%M%S`
export B="----------"

# Monitor options
export STRACE_FLAGS="-tttTf -e trace=execve,socket,sendto,recvmsg"
export PERF_FLAGS="-T -e '{syscalls:sys_enter_exec*,syscalls:sys_exit_exec*,syscalls:sys_enter_socket*,syscalls:sys_exit_socket*,syscalls:sys_enter_sendto*,syscalls:sys_exit_sendto*,syscalls:sys_enter_recvmsg*,syscalls:sys_exit_recvmsg*}'"
export TOP_FLAGS="-b -d 1 -o PID"
export COLLECTL_FLAGS="-sZ -i1:1"

#
# Test preconditions
#
echo ${B} Testing preconditions ${B}
echo "  test command: $PING_COMMAND"
echo "  containe pid: ${CONTAINE_PID}"

# Make sure we're running as root
if [ `id -u` -ne 0 ]
then
  echo "Error: Re-run under sudo or as root"
  exit 1
fi

# Make sure docker is running
if [ -z $CONTAINE_PID ]
then
  echo "Faild to find docker containe process!"
  exit 1
fi

#
# Start Experiement
#
echo "${B} Starting Experiment at $DATE_TAG ${B}"


#
# Part 1: Memory Test
#   Measure memory usage with pidstat
#

# Native top
echo ${B} Running native under top ${B}
top $TOP_FLAGS > ${DATE_TAG}_native.top &
TOP_PID=$!
$PING_COMMAND > /dev/null
kill $TOP_PID
echo Done.
sleep 5

# Native collectl
echo ${B} Running native under collectl ${B}
collectl -f ${DATE_TAG}_native.collectl $COLLECTL_FLAGS &
COLLECTL_PID=$!
$PING_COMMAND > /dev/null
kill $COLLECTL_PID
wait $COLLECTL_PID
collectl -p ${DATE_TAG}
echo Done.
sleep 5


# Container top
echo ${B} Running container under top ${B}
top $TOP_FLAGS > ${DATE_TAG}_container.top &
TOP_PID=$!
docker run --rm $PING_COMMAND > /dev/null
kill $TOP_PID
echo Done.
sleep 5

# Container collectl
echo ${B} Running container under collectl ${B}
collectl -f ${DATE_TAG}_container.collectl $COLLECTL_FLAGS &
COLLECTL_PID=$!
docker run --rm $PING_COMMAND > /dev/null
kill $COLLECTL_PID
echo Done.
sleep 5

#
# Part 2: Timing Test
#   Trace system calls with strace and perf focused on reporting time
#

# Native Strace
echo ${B} Running native under strace ${B}
strace $STRACE_FLAGS -o ${DATE_TAG}_native.strace $PING_COMMAND > /dev/null
echo Done.
sleep 5

# Native Perf
echo ${B} Running native under perf ${B}
perf record $PERF_FLAGS -o ${DATE_TAG}_native.perf.data $PING_COMMAND > /dev/null
perf script -i ${DATE_TAG}_native.perf.data > ${DATE_TAG}_native.perf
echo Done.
sleep 5

# Container Strace
echo ${B} Running container under strace ${B}
strace $STRACE_FLAGS -o ${DATE_TAG}_container.strace -p ${CONTAINE_PID} &
STRACE_PID=$!
docker run --rm $PING_COMMAND > /dev/null
kill $STRACE_PID
wait $STRACE_PID
echo Done.
sleep 5

# Container Perf
echo ${B} Running container under perf ${B}
perf record $PERF_FLAGS -o ${DATE_TAG}_container.perf.data -p ${CONTAINE_PID} &
PERF_PID=$!
docker run --rm $PING_COMMAND > /dev/null
kill $PERF_PID
wait $PERF_PID
perf script -i ${DATE_TAG}_container.perf.data > ${DATE_TAG}_container.perf
echo Done.
sleep 5

echo ${B} Finished experiment ${B}
