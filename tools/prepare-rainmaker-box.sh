#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

"$DIR/util/configure-root-vm.sh"

#
# Create and configure root "services" container
#

"$DIR/util/create-services-container.sh"

#
# Create "Golden Project" container, which includes createing "Golden Project Branch" container
#

"$DIR/util/create-golden-project-container.sh"

#
# Create LXC rootfs snapshots for "Golden Project" and "Golden Project Branch" LXC templates
#

"$DIR/util/create-container-rootfs-snapshost.sh"

#
# Destroy "Golden Project" and "Golden Project Branch" containers
#

"$DIR/util/destroy-golden-containers.sh"

#
# Replace bridge config used for building image with config that will be used in production
#
cp "$DIR/config/root/nic-br0.cfg" /etc/network/interfaces.d/br0.cfg
cp "$DIR/config/root/resolv.conf" /etc/resolv.conf

#
# Cleanup
#
apt-get clean
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c
