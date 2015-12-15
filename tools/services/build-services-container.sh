#!/bin/bash

usage() {
    cat << EOF

usage:
   $0 [container name] [--environment <environment>]
   $0 -h

OPTIONS:
   -h,--help            : show this message
   -e,--environment     : provision for a specified Salt environment

EOF
}

if [ `id -u` -ne 0 ]; then
    echo "You must run this with root permissions"
    exit
fi

script_path=`dirname $0`

# Check we have been given a name for the container we are going to build

if [ "$1" == "" ]; then
    container_lxc_name="services"
else
    container_lxc_name=$1
fi

container_lxc_root="/var/lib/lxc/$container_lxc_name"
container_lxc_root_fs="$container_lxc_root/rootfs"
container_hostname="$container_lxc_name.localdev"
environment="base"

# Set up the path option

options=$(getopt -o he -l help,environment: -- "$@")

if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$options"

# Fetch command line parameters

while [ "$#" -gt 0 ]; do
    case "$1" in
      -h|--help)            usage; exit 1;;
      -e|--environment)     environment=$2; shift 2;;
      *)                    break ;;
    esac
done

# Create container

lxc-create --name "$container_lxc_name" --bdev btrfs --template download -- --dist ubuntu --release trusty --arch amd64
$script_path/../common/set-lxc-config-params $script_path/config/lxc-config $container_lxc_root/config $container_lxc_root/config

echo "services.rainmaker.localdev" > "$container_lxc_root_fs/etc/hostname"
cp $script_path/config/hosts "$container_lxc_root_fs/etc/hosts"

# Configure container network

if [ ! -d "$container_lxc_root_fs/etc/network/interfaces.d" ]; then
    mkdir "$container_lxc_root_fs/etc/network/interfaces.d"
fi

cp "$script_path/../common/config/interfaces" "$container_lxc_root_fs/etc/network/interfaces"
#cp "$script_path/config/nic-eth0.cfg" "$container_lxc_root_fs/etc/network/interfaces.d/eth0.cfg"
./configure-services-interface.php "$script_path/config/nic-eth0.cfg.tmpl" "$container_lxc_root_fs/etc/network/interfaces.d/eth0.cfg"

echo 'nameserver 8.8.8.8' > "$container_lxc_root_fs/etc/resolv.conf"

$script_path/mount-filesystems.sh "$container_lxc_name"

# Boot container

lxc-start -d -n "$container_lxc_name"
sleep 5

# Bootstrap container

lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/upgrade-ubuntu.sh
lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/bootstrap-core-tools.sh
lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/bootstrap-salt.sh

if [ "$environment" != "base" ]; then
    lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/configure-salt.sh --fullstack
else
    lxc-attach -n "$container_lxc_name" -- /mnt/tools/common/configure-salt.sh
fi

echo $container_hostname > "$container_lxc_root_fs/etc/salt/minion_id"
