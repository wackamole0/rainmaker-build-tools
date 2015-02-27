#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

#
# Create "Golden Project" container
#

GOLDPROJ_LXC_NAME="_golden-proj_"
GOLDPROJ_LXC_ROOT="/var/lib/lxc/_golden-proj_"
GOLDPROJ_LXC_ROOT_FS="$GOLDPROJ_LXC_ROOT/rootfs"

lxc-create --template download --name "$GOLDPROJ_LXC_NAME" -- --dist ubuntu --release trusty --arch amd64

# Configure container
cat "$DIR/../config/root/lxc-golden-project-config" > "$GOLDPROJ_LXC_ROOT/config"

#
# Configure basic networking so that we can install our core packages
#

# Configure network interfaces
cat "$DIR/../config/golden-project/network-interfaces" > "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces"
cp "$DIR/../config/golden-project/nic-eth0-build.cfg" "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"

# Configure packet forwarding and exclude bridges from appearing in iptables
cat "$DIR/../config/golden-project/sysctl.conf" > "$GOLDPROJ_LXC_ROOT_FS/etc/sysctl.conf"

# Configure container resolv.conf
echo 'nameserver 8.8.8.8' > "$GOLDPROJ_LXC_ROOT_FS/etc/resolv.conf"

# Configure hostname
echo "golden-project.localdev" > "$GOLDPROJ_LXC_ROOT_FS/etc/hostname"

# Configure hosts file
cat "$DIR/../config/golden-project/hosts" > "$GOLDPROJ_LXC_ROOT_FS/etc/hosts"

# Copy build tools into container and we will remove them once container configuration is complete
cp -R /mnt/rainmaker-tools/build/tools "$GOLDPROJ_LXC_ROOT_FS/opt/rainmaker-tools"

# Start the container
lxc-start -d -n "$GOLDPROJ_LXC_NAME"

# Install our core packages into the container
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- /opt/rainmaker-tools/install-packages.sh --update --upgrade --remove

# Create software bridge for use by Linux containers
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- brctl addbr br0
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- brctl addif br0 eth0
cp "$DIR/../config/golden-project/nic-eth0.cfg" "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"
cp "$DIR/../config/golden-project/nic-br0-build.cfg" "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces.d/br0.cfg"
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- ifdown br0
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- ifdown eth0
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- ifup br0
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- ifup eth0

# Stop the container
lxc-stop -n "$GOLDPROJ_LXC_NAME"

#
# Configure iptables
#
cat "$DIR/../config/golden-project/iptables-rules.v4" > "$GOLDPROJ_LXC_ROOT_FS/etc/iptables/rules.v4"

#
# Configure LXC
#

# Prevent LXC from creating its own bridge
echo 'manual' > "$GOLDPROJ_LXC_ROOT_FS/etc/init/lxc-net.override"

# Configure LXC defaults
cat "$DIR/../config/golden-project/lxc-default.conf" > "$GOLDPROJ_LXC_ROOT_FS/etc/lxc/default.conf"

# Start the container
lxc-start -d -n "$GOLDPROJ_LXC_NAME"

# Create rainmaker user
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- /opt/rainmaker-tools/util/create-rainmaker-user.sh

# Create "Golden Project Branch" container
sleep 5
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- /opt/rainmaker-tools/util/create-golden-project-branch-container.sh

# Cleanup
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- apt-get clean
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- cat /dev/null > ~/.bash_history
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- history -c

# Stop the container
lxc-stop -n "$GOLDPROJ_LXC_NAME"

# Replace bridge config used for building image with config that will be used in production
cp "$DIR/../config/golden-project/nic-br0.cfg" "$GOLDPROJ_LXC_ROOT_FS/etc/network/interfaces.d/br0.cfg"
cat "$DIR/../config/golden-project/resolv.conf" > "$GOLDPROJ_LXC_ROOT_FS/etc/resolv.conf"

# Remove the build tools now we are finished with them
rm -Rf "$GOLDPROJ_LXC_ROOT_FS/opt/rainmaker-tools"
