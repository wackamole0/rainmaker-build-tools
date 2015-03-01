#!/bin/bash

#
# Here we will install core packages and services.
# Ubuntu starts some services upon install.
# We will prevent automatic starting of those services with an override
#

# Initialise some variables
UPDATE=0;
UPGRADE=0;
REMOVE=0;

# Process command line options
while [ "$#" -gt 0 ]; do
  case $1 in
    --update)
      UPDATE=1
      shift
      break
      ;;
    --upgrade)
      UPGRADE=1
      shift
      break
      ;;
    --remove)
      REMOVE=1
      shift
      break
      ;;
  esac
  shift
done

# Update if necessary
if [ "$UPDATE" -eq 1 ];
then
  apt-get update -y
fi

# Upgrade if necessary
if [ "$UPGRADE" -eq 1 ];
then
  apt-get upgrade -y
fi

# Install debconf utilities for preseeding
apt-get install -y debconf-utils

# Preseed answers to questions
echo "iptables-persistent	iptables-persistent/autosave_v4	boolean	true" | debconf-set-selections
echo "iptables-persistent	iptables-persistent/autosave_v6	boolean	true" | debconf-set-selections

echo "ntop	ntop/interfaces	string	none" | debconf-set-selections
echo "ntop	ntop/admin_password	password	admin" | debconf-set-selections
echo "ntop	ntop/admin_password_again	password	admin" | debconf-set-selections

# Customise which serices should be automatically started prior to their installation
echo 'manual' > /etc/init/lxc-net.override

# Install the packages
apt-get install -y \
	apache2-dev \
	bridge-utils \
	curl \
	dnsutils \
	fuse \
	jwhois \
	git \
	htop \
	iftop \
	iotop \
	iptables \
	iptables-persistent \
	iptraf \
	lftp \
	lsof \
	lsyncd \
	lxc \
	man \
	mtr \
	mytop \
	nano \
	nmap \
	ntop \
	openssh-client \
	openssh-server \
	pv \
	rssh \
	rsync \
	siege \
	sshfs \
	sysstat \
	tcpdump \
	telnet \
	traceroute \
	unzip \
	wget \
	zip

# Auto-remove redundant packages if necessary
if [ "$REMOVE" -eq 1 ];
then
  apt-get autoremove -y
fi
