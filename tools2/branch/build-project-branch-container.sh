#!/bin/bash

if [ `id -u` -ne 0 ]
then
  echo "You must run this with root permissions"
  exit
fi

script_path=`dirname $0`

# Check we have been given a name for the container we are going to build

if [ "$1" == "" ]
then
  echo "A name for the container must be specified"
  exit
fi

container_lxc_name=$1
container_lxc_root="/var/lib/lxc/$1"
container_lxc_root_fs="$container_lxc_root/rootfs"

# Create container

lxc-create --name "$container_lxc_name" --bdev btrfs --template download -- --dist ubuntu --release trusty --arch amd64
$script_path/../common/set-lxc-config-params $script_path/config/lxc-config $container_lxc_root/config $container_lxc_root/config

# Configure container network

if [ ! -d "$container_lxc_root_fs/etc/network/interfaces.d" ]
then
  mkdir "$container_lxc_root_fs/etc/network/interfaces.d"
fi

cp "$script_path/../common/config/interfaces" "$container_lxc_root_fs/etc/network/interfaces"
cp "$script_path/../project/config/nic-eth0.cfg" "$container_lxc_root_fs/etc/network/interfaces.d/eth0.cfg"

echo 'nameserver 8.8.8.8' > "$container_lxc_root_fs/etc/resolv.conf"

# Mount /mnt/tools from root VM into container

if [ ! -d "$container_lxc_root_fs/mnt/tools" ]
then
  mkdir "$container_lxc_root_fs/mnt/tools"
fi

mount -o bind /mnt/rainmaker-tools/tools2 "$container_lxc_root_fs/mnt/tools"

# Mount /srv/saltstack from root VM into container

if [ ! -d "$container_lxc_root_fs/srv/saltstack" ]
then
  mkdir "$container_lxc_root_fs/srv/saltstack"
fi

mount -o bind /srv/saltstack "$container_lxc_root_fs/srv/saltstack"

# Boot container

lxc-start -d -n "$container_lxc_name"
sleep 5

# Bootstrap container

lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/upgrade-ubuntu.sh
lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/bootstrap-core-tools.sh
lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/bootstrap-salt.sh
