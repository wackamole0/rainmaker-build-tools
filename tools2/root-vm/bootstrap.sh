#!/bin/bash


apt-get update -y
apt-get upgrade -y
apt-get install -y debconf-utils python-software-properties software-properties-common
apt-get autoremove -y

add-apt-repository -y ppa:saltstack/salt
apt-get update -y
apt-get install -y salt-master salt-minion salt-syndic
