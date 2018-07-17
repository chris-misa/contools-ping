"""Construct a profile with two hosts for testing ping

Instructions:
  Wait for the profile to start, then wait for the results.
"""

# Boiler plate
import geni.portal as portal
import geni.rspec.pg as rspec
request = portal.context.makeRequestRSpec()

# Get nodes
node1 = request.RawPC("node1")
node2 = request.RawPC("node2")

link1 = request.Link(members = [node1, node2])

# Set scripts from repo
node1.addService(rspec.Execute(shell="sh", command="/local/repository/initDocker.sh"))

# Boiler plate
portal.context.printRequestRSpec()
