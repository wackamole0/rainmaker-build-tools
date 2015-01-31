#!/bin/bash

#
# Start by upgrading to latest version of 14.04
#
apt-get -y update
apt-get -y upgrade
apt-get -y autoremove

#
# Install packages required to build/install Virtualbox Guest Additions
#
apt-get -y install linux-headers-generic build-essential dkms

#
# Install Virtualbox Guest Additions
#
wget "http://download.virtualbox.org/virtualbox/4.3.20/VBoxGuestAdditions_4.3.20.iso" -O /tmp/VBoxGuestAdditions_4.3.20.iso
mkdir /media/VBoxGuestAdditions
mount -o loop,ro /tmp/VBoxGuestAdditions_4.3.20.iso /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
umount /media/VBoxGuestAdditions
rmdir /media/VBoxGuestAdditions
unlink /tmp/VBoxGuestAdditions_4.3.20.iso

#
# Install Puppet
#
wget "https://apt.puppetlabs.com/puppetlabs-release-trusty.deb" -O /tmp/puppetlabs-release-trusty.deb
dpkg -i /tmp/puppetlabs-release-trusty.deb
apt-get -y update
apt-get -y install puppet
unlink /tmp/puppetlabs-release-trusty.deb

