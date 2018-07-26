#!/bin/bash

#
# Install / build / configure for overheads ping performance test
#

sudo apt-get update
sudo apt-get install -y libcap-dev libidn2-0-dev nettle-dev
sudo apt-get install -y docker.io tmux

sudo docker pull chrismisa/contools:ping

git clone https://github.com/iputils/iputils.git
cd iputils
make
