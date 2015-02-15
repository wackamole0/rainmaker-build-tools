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
"$DIR/install-packages.sh --update --upgrade --remove"

#
# Configure the networking
#

# Create software bridge for use by Linux containers
brctl addbr br0 && brctl addif br0 eth1

# Configure network interfaces
cp "$DIR/config/root/nic-eth1.cfg" /etc/network/interfaces.d/eth1.cfg
cp "$DIR/config/root/nic-br0-static.cfg" /etc/network/interfaces.d/br0.cfg
##"$DIR/util/create-guest-bridge-nic-conf.pl" > /etc/network/interfaces.d/br0.cfg

# Configure packet forwarding and exclude bridges from appearing in iptables
cat "$DIR/config/root/sysctl.conf" > /etc/sysctl.conf
sysctl -p

# Restart netwokring so config changes take effect
ifdown br0
ifdown eth1
ifup br0

# Configure hostname
echo "rainmaker.localdev" > /etc/hostname
hostname rainmaker.localdev

# Configure hosts file
cat "$DIR/config/root/hosts" > /etc/hosts

#
# Configure iptables
#
cat "$DIR/config/root/iptables-rules.v4" > /etc/iptables/rules.v4
iptables-restore < /etc/iptables/rules.v4

#
# Configure LXC
#

# Prevent LXC from creating its own bridge
echo 'manual' > /etc/init/lxc-net.override

# If lxc-net service is running, take it down
if [ "`service lxc-net status | fgrep stop`"="" ]
then
  service lxc-net stop
fi

# Configure LXC defaults
cat "$DIR/config/root/lxc-default.conf" > /etc/lxc/default.conf

#
# Create and configure root "services" container
#

# Create container
lxc-create --template download --name services -- --dist ubuntu --release trusty --arch amd64

SERVICES_LXC_ROOT="/var/lib/lxc/services"
SERVICES_LXC_ROOT_FS="$SERVICES_LXC_ROOT/rootfs"

# Configure container
cat "$DIR/config/root/lxc-services-config" > "$SERVICES_LXC_ROOT/config"

# Copy build tools into container and we will remove them once container configuration is complete
cp -R /mnt/rainmaker-tools/build/tools "$SERVICES_LXC_ROOT_FS/opt/rainmaker-tools"

# Install our core packages into the container
chroot "$SERVICES_LXC_ROOT_FS" /opt/rainmaker-tools/install-packages.sh --update --upgrade --remove

# Remove the build tools now we are finished with them
rm -Rf "$SERVICES_LXC_ROOT_FS/opt/rainmaker-tools"

# Configure container network interfaces
# fix this
cat "$DIR/config/services/network-interfaces" > "$SERVICES_LXC_ROOT_FS/etc/network/interfaces"
##cp "$DIR/config/services/nic-eth0.cfg" "$SERVICES_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"
cp "$DIR/config/services/nic-eth0-static.cfg" "$SERVICES_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"
##"$DIR/util/create-service-container-network-if-conf.pl" > "$SERVICES_LXC_ROOT_FS/etc/network/interfaces"

# Configure container resolv.conf
cat "$DIR/config/services/resolv.conf" > "$SERVICES_LXC_ROOT_FS/etc/resolv.conf"

# Configure container hostname
echo "services.rainmaker.localdev" > "$SERVICES_LXC_ROOT_FS/etc/hostname"

# Configure container hosts file
cat "$DIR/config/services/hosts" > "$SERVICES_LXC_ROOT_FS/etc/hosts"

#
# Configure container iptables
#

#
# Configure DHCP service
#

chroot "$SERVICES_LXC_ROOT_FS" apt-get install -y isc-dhcp-server
cat "$DIR/config/services/dhcpd.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.conf"
cat "$DIR/config/services/dhcpd.host.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.host.conf"
cat "$DIR/config/services/dhcpd.class.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.class.conf"
cat "$DIR/config/services/dhcpd.subnet.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.subnet.conf"
mkdir "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.host.conf.d"
mkdir "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.class.conf.d"
mkdir "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.subnet.conf.d"
cp $DIR/config/services/dhcpd.subnet.conf.d/* "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.subnet.conf.d/"
chroot "$SERVICES_LXC_ROOT_FS" update-rc.d isc-dhcp-server defaults

#
# Configure DNS service
#

chroot "$SERVICES_LXC_ROOT_FS" apt-get install -y bind9 bind9-doc dnsutils
cat "$DIR/config/services/named.conf.options" > "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.options"
cat "$DIR/config/services/named.conf.local" > "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.local"
mkdir "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.rainmaker"
cp $DIR/config/services/named.conf.rainmaker/* "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.rainmaker/"
mkdir "$SERVICES_LXC_ROOT_FS/etc/bind/db.rainmaker"
cp $DIR/config/services/db.rainmaker/* "$SERVICES_LXC_ROOT_FS/etc/bind/db.rainmaker/"
chroot "$SERVICES_LXC_ROOT_FS" update-rc.d bind9 defaults

#
# Create "Golden Project" container, which includes createing "Golden Project Branch" container
#

#
# Create "Golden Project" container
#
lxc-create --template download --name _golden-proj_ -- --dist ubuntu --release trusty --arch amd64

GOLDPROJ_LXC_NAME="_golden-proj_"
GOLDPROJ_LXC_ROOT="/var/lib/lxc/_golden-proj_"
GOLDPROJ_LXC_ROOT_FS="$GOLDPROJ_LXC_ROOT/rootfs"

# Configure container
cat "$DIR/config/root/lxc-golden-project-config" > "$GOLDPROJ_LXC_ROOT/config"

# Copy build tools into container and we will remove them once container configuration is complete
cp -R /mnt/rainmaker-tools/build/tools "$GOLDPROJ_LXC_ROOT_FS/opt/rainmaker-tools"

# Install our core packages into the container
chroot "$GOLDPROJ_LXC_ROOT_FS" /opt/rainmaker-tools/install-packages.sh --update --upgrade --remove

# Remove the build tools now we are finished with them
rm -Rf "$GOLDPROJ_LXC_ROOT_FS/opt/rainmaker-tools"

#
# Configure the networking
#

# Configure network interfaces
cat "$DIR/config/golden-project/network-interfaces" > "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces"
cp "$DIR/config/golden-project/nic-eth0.cfg" "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"
cp "$DIR/config/golden-project/nic-br0.cfg" "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces.d/br0.cfg"

# Configure packet forwarding and exclude bridges from appearing in iptables
cat "$DIR/config/golden-project/sysctl.conf" > "$GOLDPROJ_LXC_ROOT_FS/etc/sysctl.conf"

# Configure container resolv.conf
cat "$DIR/config/golden-project/resolv.conf" > "$GOLDPROJ_LXC_ROOT_FS/etc/resolv.conf"

# Configure hostname
echo "golden-project.localdev" > "$GOLDPROJ_LXC_ROOT_FS/etc/hostname"

# Configure hosts file
cat "$DIR/config/golden-project/hosts" > "$GOLDPROJ_LXC_ROOT_FS/etc/hosts"

#
# Configure iptables
#
cat "$DIR/config/golden-project/iptables-rules.v4" > "$GOLDPROJ_LXC_ROOT_FS/etc/iptables/rules.v4"

#
# Configure LXC
#

# Prevent LXC from creating its own bridge
echo 'manual' > "$GOLDPROJ_LXC_ROOT_FS/etc/init/lxc-net.override"

# Configure LXC defaults
cat "$DIR/config/golden-project/lxc-default.conf" > "$GOLDPROJ_LXC_ROOT_FS/etc/lxc/default.conf"

#
# Create "Golden Project Branch" container
#
##chroot "$GOLDPROJ_LXC_ROOT_FS" lxc-create --template download --name _golden-branch_ -- --dist ubuntu --release trusty --arch amd64

GOLDBRANCH_LXC_ROOT="$GOLDPROJ_LXC_ROOT_FS/var/lib/lxc/_golden-branch_"
GOLDBRANCH_LXC_ROOT_FS="$GOLDBRANCH_LXC_ROOT/rootfs"

# Configure container
##cat "$DIR/config/golden-project/lxc-golden-project-branch-config" > "$GOLDBRANCH_LXC_ROOT/config"

# Copy build tools into container and we will remove them once container configuration is complete
##cp -R /mnt/rainmaker-tools/build/tools "$GOLDBRANCH_LXC_ROOT_FS/opt/rainmaker-tools"

# Install our core packages into the container
##chroot "$GOLDBRANCH_LXC_ROOT_FS" /opt/rainmaker-tools/install-packages.sh --update --upgrade --remove

# Remove the build tools now we are finished with them
##rm -Rf "$GOLDBRANCH_LXC_ROOT_FS/opt/rainmaker-tools"
