#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

# Set the resolver
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

#
# Prepare the disks
#
if [ -e /dev/sdb ];
then
  apt-get update -y
  apt-get install -y btrfs-tools
  sfdisk /dev/sdb < "$DIR/../config/root/lxc-disk.sfdisk"
  pvcreate /dev/sdb1
  vgcreate lxc-vg /dev/sdb1
  lvcreate -l 100%FREE -n root-lxc lxc-vg
  mkfs.btrfs /dev/lxc-vg/root-lxc
  "$DIR/enable-lxc-rootfs-mount.pl" > /etc/fstab
  mkdir -p /var/lib/lxc
  chmod go-rwx /var/lib/lxc
  mount /var/lib/lxc
else
  cat "$DIR/../config/root/fstab" > /etc/fstab
fi

#
# Install the packages required by rainmaker
#
"$DIR/../install-packages.sh" --update --upgrade --remove

#
# Configure the networking
#

# Create software bridge for use by Linux containers
brctl addbr br0 && brctl addif br0 eth1

# Configure packet forwarding and exclude bridges from appearing in iptables
cat "$DIR/../config/root/sysctl.conf" > /etc/sysctl.conf
sysctl -p

# Configure network interfaces
cp "$DIR/../config/root/nic-eth1.cfg" /etc/network/interfaces.d/eth1.cfg
"$DIR/configure-bridge-for-build.sh" --restart

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

# Make sure Kernel support for btrfs is enabled
modprobe btrfs
echo 'btrfs' >> /etc/modules

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

cp -R "$DIR/../config/root/lxc-templates/*" /usr/share/lxc/templates

# Create rainmaker user
"$DIR/create-rainmaker-user.sh"

# Setup NFS server
apt-get install -y nfs-kernel-server
mkdir -p /export/rainmaker
chown root:root /export/rainmaker
cat "$DIR/../config/root/exports" > /etc/exports
