#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "You must run this with root permissions"
    exit
fi

script_path=`dirname $0`

# Check we have been given a name for the container we are going to destroy

if [ "$1" == "" ]; then
    echo "A name for the container must be specified"
    exit
fi

container_lxc_name=$1
container_lxc_root="/var/lib/lxc/$1"
container_lxc_root_fs="$container_lxc_root/rootfs"

# Unmount /srv/saltstack from container

if [ "`grep -s $container_lxc_root_fs/srv/saltstack /proc/mounts`" != "" ]; then
    umount "$container_lxc_root_fs/srv/saltstack"
fi

# Unmount /mnt/tools from container

if [ "`grep -s $container_lxc_root_fs/mnt/tools /proc/mounts`" != "" ]; then
    umount "$container_lxc_root_fs/mnt/tools"
fi

# Unmount /var/cache/lxc from container

if [ "`grep -s $container_lxc_root_fs/var/cache/lxc /proc/mounts`" != "" ]; then
    umount "$container_lxc_root_fs/var/cache/lxc"
fi
