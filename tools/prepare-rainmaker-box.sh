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
# Replace bridge config used for building image with config that will be used in production
#
"$DIR/util/configure-bridge-for-production.sh"

#
# Cleanup
#
apt-get clean
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c
