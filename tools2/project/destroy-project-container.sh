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

$script_path/unmount-filesystem.sh "$container_lxc_name"

# Destroy container

if [ "`lxc-ls --stopped ^$container_lxc_name\$`" != "" ]
then
  lxc-destroy -n $container_lxc_name
  sleep 5
fi
