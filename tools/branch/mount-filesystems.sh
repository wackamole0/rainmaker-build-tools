#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "You must run this with root permissions"
    exit
fi

script_path=`dirname $0`

# Check we have been given a name for the container we are going to build

if [ "$1" == "" ]; then
    echo "A name for the container must be specified"
    exit
fi

container_lxc_name=$1
container_lxc_root="/var/lib/lxc/$1"
container_lxc_root_fs="$container_lxc_root/rootfs"

# Mount /mnt/tools from root VM into container

if [ ! -d "$container_lxc_root_fs/mnt/tools" ]; then
    mkdir "$container_lxc_root_fs/mnt/tools"
fi

mount -o bind /mnt/rainmaker-tools "$container_lxc_root_fs/mnt/tools"

# Mount /srv/saltstack from root VM into container

if [ ! -d "$container_lxc_root_fs/srv/saltstack" ]; then
    mkdir "$container_lxc_root_fs/srv/saltstack"
fi

mount -o bind /srv/saltstack "$container_lxc_root_fs/srv/saltstack"
