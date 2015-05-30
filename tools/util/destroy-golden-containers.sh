#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

GOLDPROJ_LXC_NAME="_golden-proj_"
GOLDBRANCH_LXC_NAME="_golden-branch_"

lxc-start -d -n "$GOLDPROJ_LXC_NAME"
sleep 10
lxc-attach -n "$GOLDPROJ_LXC_NAME" -- lxc-destroy -n "$GOLDBRANCH_LXC_NAME"
sleep 30

lxc-stop -n "$GOLDPROJ_LXC_NAME"
lxc-destroy -n "$GOLDPROJ_LXC_NAME"
sleep 30
