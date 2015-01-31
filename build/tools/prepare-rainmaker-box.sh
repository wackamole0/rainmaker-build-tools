#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

#
# Install the packages required by rainmaker
#
##"$DIR/install-packages.sh"

#
# Configure the networking
#

# Create software bridge for use by Linux containers
##brctl addbr br0 && brctl addif br0 eth1

# Configure network interfaces
##"$DIR/util/create-network-if-conf.pl" > /etc/network/interfaces

# Configure packet forwarding and exclude bridges from appearing in iptables
##cat "$DIR/config/root/sysctl.conf" > /etc/sysctl.conf
##sysctl -p

# Restart netwokring so config changes take effect
##ifdown eth0
##ifdown br0
##ifdown eth1
##ifup eth0
##ifup br0

# Configure hostname
##echo "rainmaker.localdev" > /etc/hostname
##hostname rainmaker.localdev

# Configure hosts file
##cat "$DIR/config/root/hosts" > /etc/hosts

#
# Configure iptables
#
##cat "$DIR/config/root/iptables-rules.v4" > /etc/iptables/rules.v4
##iptables-restore < /etc/iptables/rules.v4

#
# Configure LXC
#

# Prevent LXC from creating its own bridge
##echo 'manual' > /etc/init/lxc-net.override

# If lxc-net service is running, take it down
##if [ "`service lxc-net status | fgrep stop`"="" ]
##then
##  service lxc-net stop
##fi

# Configure LXC defaults
##cat "$DIR/config/root/lxc-default.conf" > /etc/lxc/default.conf

#
# Create and configure root "services" container
#

# Create container
##lxc-create --template download --name services -- --dist ubuntu --release trusty --arch amd64

# Configure container
##cat "$DIR/config/root/lxc-services-config" > /var/lib/lxc/services/config

# Configure container network interfaces
# fix this
##"$DIR/util/create-service-container-network-if-conf.pl" > /var/lib/lxc/services/rootfs/etc/network/interfaces

# Configure container resolv.conf
##cat "$DIR/config/services/resolv.conf" > /var/lib/lxc/services/rootfs/etc/resolv.conf

# Configure container hostname
##echo "services.rainmaker.localdev" > /var/lib/lxc/services/rootfs/etc/hostname

# Configure container hosts file
##cat "$DIR/config/services/hosts" > /var/lib/lxc/services/rootfs/etc/hosts

#
# Configure container iptables
#


#
# Create "Golden Project" container, which includes createing "Golden Project Branch" container
#

