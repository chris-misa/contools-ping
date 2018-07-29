# contools-ping

Cloudlab profile for contools ping experiments

# Experiment Protocol

## Controller (Bash)

1. Install Dependencies (docker.io, etc)
2. Start Monitors (tcpdump, watching /proc/PID..., watching children, etc.)
3. Bash: Experiment Script
4. Container: Bash: Experiment Script

# Notes

Current experiment started 7/27 at 6:00 pm will last ca 22 hours.

# Questions

## Container Bias

1. Run multiple measurements from inside container and compare with measurement made from outside container. (sanity check version)

2. Ping the host's interface from the container and use this RTT measure to
dynamically compute time packets spend going through the container interface.

This method is probably dependent on the container networking mode and might not be possible for all modes. . .

## Performance Overhead

### Timing

Start up time:
  Time from when user (script) issues command till when the first test packet is sent.
  Defined the first test packet as the first packet directly implicated in the resulting
  measurement: the tool may send DNS query packets and do various socket tests and operations
  before this first packet is sent.

Run time:
  Time from when first packet is sent to when last packet is revd (or sent if last packet had no response).

Tear down time:
  Time from when last test packet is recvd (or sent if last packet had no response) to when
  control is returned to user (script).


