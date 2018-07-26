# contools-ping

Cloudlab profile for contools ping experiments

# Experiment Protocol

## Controller (Bash)

1. Install Dependencies (docker.io, etc)
2. Start Monitors (tcpdump, watching /proc/PID..., watching children, etc.)
3. Bash: Experiment Script
4. Container: Bash: Experiment Script

# Notes

Probably need to set up separate repo for data. . .



# Questions

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


