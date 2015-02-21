#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

#
# Create "Golden Project Branch" container
#

GOLDBRANCH_LXC_NAME="_golden-branch_"
GOLDBRANCH_LXC_ROOT="/var/lib/lxc/_golden-branch_"
GOLDBRANCH_LXC_ROOT_FS="$GOLDBRANCH_LXC_ROOT/rootfs"

##lxc-create --template download --name "$GOLDBRANCH_LXC_NAME" -- --dist ubuntu --release trusty --arch amd64

# Configure container
##cat "$DIR/../config/golden-project/lxc-golden-project-branch-config" > "$GOLDBRANCH_LXC_ROOT/config"

# Configure container network interfaces
##cat "$DIR/../config/golden-project-branch/network-interfaces" > "$GOLDBRANCH_LXC_ROOT_FS/etc/network/interfaces"
##cp "$DIR/../config/golden-project-branch/nic-eth0.cfg" "$GOLDBRANCH_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"

# Configure container resolv.conf
##cat "$DIR/../config/golden-project-branch/resolv.conf" > "$GOLDBRANCH_LXC_ROOT_FS/etc/resolv.conf"

# Configure container hostname
##echo "golden-branch.golden-project.localdev" > "$GOLDBRANCH_LXC_ROOT_FS/etc/hostname"

# Configure container hosts file
##cat "$DIR/../config/golden-project-branch/hosts" > "$GOLDBRANCH_LXC_ROOT_FS/etc/hosts"

# Configure container iptables

# Copy build tools into container and we will remove them once container configuration is complete
##cp -R "$DIR/../../rainmaker-tools" "$GOLDBRANCH_LXC_ROOT_FS/opt/rainmaker-tools"

# Start the container
##lxc-start -d -n "$GOLDBRANCH_LXC_NAME"

# Install our core packages into the container
##lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- /opt/rainmaker-tools/install-packages.sh --update --upgrade --remove

# Create rainmaker user
##lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- /opt/rainmaker-tools/util/create-rainmaker-user.sh

# Install "Drupal Classic" profile
lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- /opt/rainmaker-tools/util/configure-drupal-classic-container.sh

# Stop the containers
##lxc-stop -n "$GOLDBRANCH_LXC_NAME"

# Remove the build tools now we are finished with them
##rm -Rf "$GOLDBRANCH_LXC_ROOT_FS/opt/rainmaker-tools"
