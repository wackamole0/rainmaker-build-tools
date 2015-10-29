#!/bin/bash

apt-get install -y debconf-utils python-software-properties software-properties-common git

add-apt-repository -y ppa:saltstack/salt
apt-get update -y
apt-get install -y salt-master salt-minion salt-syndic
