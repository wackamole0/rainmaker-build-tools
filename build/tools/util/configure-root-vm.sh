#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

# Set the resolver
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

#
# Install the packages required by rainmaker
#
"$DIR/../install-packages.sh" --update --upgrade --remove

#
# Configure the networking
#

# Create software bridge for use by Linux containers
brctl addbr br0 && brctl addif br0 eth1

# Configure network interfaces
cp "$DIR/../config/root/nic-eth1.cfg" /etc/network/interfaces.d/eth1.cfg
cp "$DIR/../config/root/nic-br0-build.cfg" /etc/network/interfaces.d/br0.cfg

# Configure packet forwarding and exclude bridges from appearing in iptables
cat "$DIR/../config/root/sysctl.conf" > /etc/sysctl.conf
sysctl -p

# Restart networking so config changes take effect
ifdown br0 && ifdown eth1
ifup br0 && ifup eth1

# Configure hostname
echo "rainmaker.localdev" > /etc/hostname
hostname rainmaker.localdev

# Configure hosts file
cat "$DIR/../config/root/hosts" > /etc/hosts

#
# Configure iptables
#
cat "$DIR/../config/root/iptables-rules.v4" > /etc/iptables/rules.v4
iptables-restore < /etc/iptables/rules.v4

#
# Configure LXC
#

# Prevent LXC from creating its own bridge
echo 'manual' > /etc/init/lxc-net.override

# If lxc-net service is running, take it down
if [ "`service lxc-net status | fgrep stop`" = "" ]
then
  service lxc-net stop
fi

# Configure LXC defaults
cat "$DIR/../config/root/lxc-default.conf" > /etc/lxc/default.conf

# Create rainmaker user
"$DIR/create-rainmaker-user.sh"

# Setup NFS server
apt-get install -y nfs-kernel-server
mkdir -p /export/rainmaker
chown root:root /export/rainmaker
cat "$DIR/../config/root/exports" > /etc/exports
cat "$DIR/../config/root/fstab" > /etc/fstab
