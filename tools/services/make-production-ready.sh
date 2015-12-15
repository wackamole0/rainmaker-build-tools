#!/usr/bin/env bash

if [ `id -u` -ne 0 ]
then
  echo "You must run this with root permissions"
  exit
fi

script_path=`dirname $0`
tools_path="$script_path/.."

cp $script_path/config/production/nic-eth0.cfg /etc/network/interfaces.d/eth0.cfg

#dhcpd

cp $script_path/config/production/dhcpd.subnet.10.100.0.0.conf /etc/dhcp/dhcpd.subnet.conf.d/10.100.0.0.conf

#bind9

cp $script_path/config/production/named.conf.options /etc/bind/named.conf.options
cp $script_path/config/production/rainmaker.conf /etc/bind/named.conf.rainmaker/rainmaker.conf
cp $script_path/config/production/db.rainmaker.localdev /etc/bind/db.rainmaker/db.rainmaker.localdev

apt-get clean
cat /dev/null > ~/.bash_history
history -c
