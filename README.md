# contools-ping

Cloudlab profile for contools ping experiments

# Questions

How to listen for experiment termination from target nodes.
How to copy data out of test machines? (Where to? What protocol?)

  1) Build protocol within cluster? (risks interfecence with experiment)

    simple implementation using nc on some unused port:
      1) targets launch an nc -l in the background
      2) leader runs experiment
      3) leader sends each target finished message
      4) targets return their logs to leader
      5) leader tars logs
      6) user manually scp's log tarball out of testbed

  2) Have each node scp back to some receiving server (ix-dev?)
  3) Network filesystems?
  4) Local script to gleen information from experiment nodes


