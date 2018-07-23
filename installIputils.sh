#!/bin/bash

#
# Install and build iputils found on github
#

sudo apt-get update
sudo apt-get install -y libcap-dev libidn2-0-dev nettle-dev

git clone https://github.com/iputils/iputils.git
cd iputils
make
