#!/bin/bash

if [ `id -u` -ne 0 ]
then
  echo "You must run this with root permissions"
  exit
fi

script_path=`dirname $0`

# Check we have been given a name for the container we are going to destroy

if [ "$1" == "" ]
then
  echo "A name for the container must be specified"
  exit
fi

container_lxc_name=$1
container_lxc_root="/var/lib/lxc/$1"
container_lxc_root_fs="$container_lxc_root/rootfs"

# Stop container

if [ "`lxc-ls --running ^$container_lxc_name\$`" != "" ]
then
  lxc-stop -n $container_lxc_name
  sleep 5
fi

# Unmount /srv/salt from container

if [ "`grep -s $container_lxc_root_fs/srv/salt /proc/mounts`" != "" ]
then
  umount "$container_lxc_root_fs/srv/salt"
fi

# Unmount /mnt/tools from container

if [ "`grep -s $container_lxc_root_fs/mnt/tools /proc/mounts`" != "" ]
then
  umount "$container_lxc_root_fs/mnt/tools"
fi

# Destroy container

if [ "`lxc-ls --stopped ^$container_lxc_name\$`" != "" ]
then
  lxc-destroy -n $container_lxc_name
  sleep 5
fi
