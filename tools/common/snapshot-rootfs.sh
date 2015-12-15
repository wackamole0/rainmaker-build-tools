#!/bin/bash

usage() {
  cat << EOF

usage:
   $0 <container name> <snapshot full path>
   $0 -h

OPTIONS:
   -h,--help            : show this message

EOF
}

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

if [ "$2" == "" ]; then
  echo "The full path to the snapshot is required"
  exit 1
fi

# Initialise some variables

container_lxc_name=$1
container_lxc_root="/var/lib/lxc/$1"
container_lxc_root_fs="$container_lxc_root/rootfs"
snapshot_full_path=$2

# If the container is running we must stop it
if [ "`lxc-info -n $container_lxc_name --state | fgrep -i running`" != "" ]; then
  lxc-stop -n "$container_lxc_name"
  sleep 5
fi

tar --numeric-owner -C "$container_lxc_root_fs" -czf "$snapshot_full_path" .
