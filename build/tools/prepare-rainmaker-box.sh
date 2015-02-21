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
