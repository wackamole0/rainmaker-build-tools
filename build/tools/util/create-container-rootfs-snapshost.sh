#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

mkdir -p /var/cache/lxc/rainmaker/project-branch/0.1/rootfs
rsync -Ha /var/lib/lxc/_golden-proj_/rootfs/var/lib/lxc/_golden-branch_/rootfs/ /var/cache/lxc/rainmaker/project-branch/0.1/rootfs/

mkdir -p /var/cache/lxc/rainmaker/project/0.1/rootfs
rsync -Ha --exclude=var/lib/lxc/* /var/lib/lxc/_golden-proj_/rootfs/ /var/cache/lxc/rainmaker/project/0.1/rootfs/
