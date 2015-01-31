#!/bin/bash

#
# Here we will install core packages and services.
# Ubuntu starts some services upon install.
# We will prevent automatic starting of those services with an override
#

echo 'manual' > /etc/init/lxc-net.override

apt-get install -y \
	apache2-dev \
	bridge-utils \
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
	wget
