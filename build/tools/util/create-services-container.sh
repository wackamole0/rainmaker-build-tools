#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

# Create container

SERVICES_LXC_NAME="services"
SERVICES_LXC_ROOT="/var/lib/lxc/services"
SERVICES_LXC_ROOT_FS="$SERVICES_LXC_ROOT/rootfs"

lxc-create --name "$SERVICES_LXC_NAME" --bdev btrfs --template download -- --dist ubuntu --release trusty --arch amd64

# Configure container
cat "$DIR/../config/root/lxc-services-config" > "$SERVICES_LXC_ROOT/config"

# Configure container network interfaces
cat "$DIR/../config/services/network-interfaces" > "$SERVICES_LXC_ROOT_FS/etc/network/interfaces"
cp "$DIR/../config/services/nic-eth0-build.cfg" "$SERVICES_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"


# Configure container resolv.conf
echo 'nameserver 8.8.8.8' > "$SERVICES_LXC_ROOT_FS/etc/resolv.conf"

# Configure container hostname
echo "services.rainmaker.localdev" > "$SERVICES_LXC_ROOT_FS/etc/hostname"

# Configure container hosts file
cat "$DIR/../config/services/hosts" > "$SERVICES_LXC_ROOT_FS/etc/hosts"

#
# Configure container iptables
#

# Copy build tools into container and we will remove them once container configuration is complete
cp -R /mnt/rainmaker-tools/build/tools "$SERVICES_LXC_ROOT_FS/opt/rainmaker-tools"

lxc-start -d -n "$SERVICES_LXC_NAME"
sleep 10

# Install our core packages into the container
lxc-attach -n "$SERVICES_LXC_NAME" -- /opt/rainmaker-tools/install-packages.sh --update --upgrade --remove

# Create rainmaker user
lxc-attach -n "$SERVICES_LXC_NAME" -- /opt/rainmaker-tools/util/create-rainmaker-user.sh

#
# Configure DHCP service
#

lxc-attach -n "$SERVICES_LXC_NAME" -- apt-get install -y isc-dhcp-server
cat "$DIR/../config/services/dhcpd.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.conf"
cat "$DIR/../config/services/dhcpd.host.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.host.conf"
cat "$DIR/../config/services/dhcpd.class.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.class.conf"
cat "$DIR/../config/services/dhcpd.subnet.conf" > "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.subnet.conf"
mkdir "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.host.conf.d"
cp $DIR/../config/services/dhcpd.host.conf.d/* "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.host.conf.d/"
mkdir "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.class.conf.d"
cp $DIR/../config/services/dhcpd.class.conf.d/* "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.class.conf.d/"
mkdir "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.subnet.conf.d"
cp $DIR/../config/services/dhcpd.subnet.conf.d/* "$SERVICES_LXC_ROOT_FS/etc/dhcp/dhcpd.subnet.conf.d/"
lxc-attach -n "$SERVICES_LXC_NAME" -- update-rc.d isc-dhcp-server defaults

#
# Configure DNS service
#

lxc-attach -n "$SERVICES_LXC_NAME" -- apt-get install -y bind9 bind9-doc dnsutils
cat "$DIR/../config/services/named.conf.options" > "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.options"
cat "$DIR/../config/services/named.conf.local" > "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.local"
mkdir "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.rainmaker"
cp $DIR/../config/services/named.conf.rainmaker/* "$SERVICES_LXC_ROOT_FS/etc/bind/named.conf.rainmaker/"
mkdir "$SERVICES_LXC_ROOT_FS/etc/bind/db.rainmaker"
cp $DIR/../config/services/db.rainmaker/* "$SERVICES_LXC_ROOT_FS/etc/bind/db.rainmaker/"
lxc-attach -n "$SERVICES_LXC_NAME" -- update-rc.d bind9 defaults

# Cleanup
lxc-attach -n "$SERVICES_LXC_NAME" -- apt-get clean
lxc-attach -n "$SERVICES_LXC_NAME" -- cat /dev/null > ~/.bash_history
lxc-attach -n "$SERVICES_LXC_NAME" -- history -c

# Stop the container
lxc-stop -n "$SERVICES_LXC_NAME"

# Replace nic config used for building image with config that will be used in production
cp "$DIR/../config/services/nic-eth0.cfg" "$SERVICES_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"
cat "$DIR/../config/services/resolv.conf" > "$SERVICES_LXC_ROOT_FS/etc/resolv.conf"

# Remove the build tools now we are finished with them
rm -Rf "$SERVICES_LXC_ROOT_FS/opt/rainmaker-tools"
