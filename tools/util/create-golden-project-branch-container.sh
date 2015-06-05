#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

profile=""

# Set up the path option
options=$(getopt -o p -l profile: -- "$@")

if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$options"

# Fetch command line parameters
while true; do
	case "$1" in
        --profile)      profile=$2; shift 2;;
        *)              break ;;
    esac
done

profile_path=""
if [ -n "$profile" ]; then
	profile_path="$DIR/project-branch-profiles/configure-$profile-container.sh"
	echo "$profile_path"
	if [ ! -f "$profile_path" ]; then
    	echo "profile '$profile' does not exist"
	    exit 1
	fi
fi

#
# Create "Golden Project Branch" container
#

GOLDBRANCH_LXC_NAME="_golden-branch_"
GOLDBRANCH_LXC_ROOT="/var/lib/lxc/_golden-branch_"
GOLDBRANCH_LXC_ROOT_FS="$GOLDBRANCH_LXC_ROOT/rootfs"

lxc-create --name "$GOLDBRANCH_LXC_NAME" --bdev btrfs --template download -- --dist ubuntu --release trusty --arch amd64

# Configure container
cat "$DIR/../config/golden-project/lxc-golden-project-branch-config" > "$GOLDBRANCH_LXC_ROOT/config"

# Configure container network interfaces
cat "$DIR/../config/golden-project-branch/network-interfaces" > "$GOLDBRANCH_LXC_ROOT_FS/etc/network/interfaces"
cp "$DIR/../config/golden-project-branch/nic-eth0-build.cfg" "$GOLDBRANCH_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"

# Configure container resolv.conf
echo 'nameserver 8.8.8.8' > "$GOLDBRANCH_LXC_ROOT_FS/etc/resolv.conf"

# Configure container hostname
echo "golden-branch.golden-project.localdev" > "$GOLDBRANCH_LXC_ROOT_FS/etc/hostname"

# Configure container hosts file
cat "$DIR/../config/golden-project-branch/hosts" > "$GOLDBRANCH_LXC_ROOT_FS/etc/hosts"

# Configure container iptables

# Copy build tools into container and we will remove them once container configuration is complete
cp -R /mnt/rainmaker-tools/tools "$GOLDBRANCH_LXC_ROOT_FS/opt/rainmaker-tools"

# Start the container
lxc-start -d -n "$GOLDBRANCH_LXC_NAME"
sleep 10

# Install our core packages into the container
lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- /opt/rainmaker-tools/install-packages.sh --update --upgrade --remove

# Create rainmaker user
lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- /opt/rainmaker-tools/util/create-rainmaker-user.sh

# Install "Drupal Classic" profile
if [ -n "$profile" ]; then
	#lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- /opt/rainmaker-tools/util/configure-drupal-classic-container.sh
	lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- "/opt/rainmaker-tools/util/project-branch-profiles/configure-$profile-container.sh"
fi

# Cleanup
lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- apt-get clean
lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- cat /dev/null > ~/.bash_history
lxc-attach -n "$GOLDBRANCH_LXC_NAME" -- history -c

# Stop the containers
lxc-stop -n "$GOLDBRANCH_LXC_NAME"

cp -R $DIR/../config/root/lxc-templates/* "$GOLDBRANCH_LXC_ROOT_FS/usr/share/lxc/templates"

# Replace adapter config used for building image with config that will be used in production
cp "$DIR/../config/golden-project-branch/nic-eth0.cfg" "$GOLDBRANCH_LXC_ROOT_FS/etc/network/interfaces.d/eth0.cfg"
cat "$DIR/../config/golden-project-branch/resolv.conf" > "$GOLDBRANCH_LXC_ROOT_FS/etc/resolv.conf"

# Remove the build tools now we are finished with them
rm -Rf "$GOLDBRANCH_LXC_ROOT_FS/opt/rainmaker-tools"
