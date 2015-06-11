#!/bin/bash

usage() {
    cat << EOF

usage: $0 --profile <profile> --version <version> [-hcp]

OPTIONS:
   -h,--help           : show this message
   -c,--create         : build project profile
   -p,--publish        : publish project profile rootfs
   --profile <profile> : the profile to build
   --version <version> : the version of the profile that we are building

EOF
}

dir=`dirname $0`

# Set up the path option
options=$(getopt -o hcp -l help,profile:,version:,create,publish -- "$@")

if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$options"

create=1
publish=1

# Fetch command line parameters
while true; do
	case "$1" in
        -h|--help)      usage; exit 1;;
        -c|--create)    create=1; publish=0; shift 1;;
        -p|--publish)   publish=1; create=0; shift 1;;
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

if [ "$create" -eq 1 ]; then
	"$dir/create-golden-project-container.sh"
fi

if [ "$publish" -eq 1 ]; then
	tar --numeric-owner -C /var/lib/lxc/_golden-proj_/rootfs -czf /var/lib/lxc/_golden-proj_/rootfs.tgz .

	major=`echo $version | cut -d'.' -f1`
	upload_path="/var/www/nginx/rootfs/project/$profile/$major/project-$profile-$version.tgz"
	upload_dir=`dir $upload_path`

	ssh rainmaker@image.rainmaker.localdev "mkdir -p $upload_dir"
	scp /var/lib/lxc/_golden-proj_/rootfs.tgz rainmaker@image.rainmaker.localdev:"$upload_path"

	unlink /var/lib/lxc/_golden-proj_/rootfs.tgz
	lxc-destroy -n _golden-proj_
fi
