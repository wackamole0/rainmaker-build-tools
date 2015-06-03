#!/bin/bash

dir=`dirname $0`

# Set up the path option
options=$(getopt -l profile:,version: -- "$@")

if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$options"

# Fetch command line parameters
while true; do
    case "$1" in
        --profile)      profile=$2; shift 2;;
        --version)      version=$2; shift 2;;
        *)              break ;;
    esac
done

if [ -z "$profile" ]; then
    echo "'profile' parameter is required"
    exit 1
fi

if [ -z "$version" ]; then
    echo "'version' parameter is required"
    exit 1
fi

"$dir/create-golden-project-container.sh"

tar --numeric-owner -C /var/lib/lxc/_golden-proj_/rootfs -czf /var/lib/lxc/_golden-proj_/rootfs.tgz .

major=`echo $version | cut -d'.' -f1`
upload_path="/var/www/nginx/rootfs/project/$profile/$major/project-$profile-$version.tgz"
upload_dir=`dir $upload_path`

ssh rainmaker@image.rainmaker.localdev "mkdir -p $upload_dir"
scp /var/lib/lxc/_golden-proj_/rootfs.tgz rainmaker@image.rainmaker.localdev:"$upload_path"

unlink /var/lib/lxc/_golden-proj_/rootfs.tgz
lxc-destroy -n _golden-proj_
