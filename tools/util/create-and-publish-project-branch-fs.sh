#!/bin/bash

usage() {
    cat << EOF

usage: $0 --profile <profile> --version <version> [-hcp]

OPTIONS:
   -h,--help           : show this message
   -c,--create         : build project branch profile
   -p,--publish        : publish project branch profile rootfs
   --no-latest         : update the latest project branch profile version
   --profile <profile> : the branch profile to build
   --version <version> : the version of the branch profile that we are building

EOF
}

dir=`dirname $0`

# Set up the path option
options=$(getopt -o hcp -l help,profile:,version:,downloadhost:,create,publish,no-latest -- "$@")

if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$options"

create=1
publish=1
setlatest=1

profile_download_server="image.rainmaker-dev.com"
if [ -n "$RMK_DOWNLOAD_HOST" ]; then
    profile_download_server="$RMK_DOWNLOAD_HOST"
fi

# Fetch command line parameters
while true; do
	case "$1" in
        -h|--help)      usage; exit 1;;
        -c|--create)    create=1; publish=0; shift 1;;
        -p|--publish)   publish=1; create=0; shift 1;;
        --no-latest)    setlatest=0; shift 1;;
        --profile)      profile=$2; shift 2;;
        --version)      version=$2; shift 2;;
        --downloadhost) profile_download_server=$2; shift 2;;
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
	"$dir/create-golden-project-branch-container.sh" "--profile=$profile"
fi
	
if [ "$publish" -eq 1 ]; then
	tar --numeric-owner -C /var/lib/lxc/_golden-branch_/rootfs -czf /var/lib/lxc/_golden-branch_/rootfs.tgz .

	major=`echo $version | cut -d'.' -f1`
	upload_path="/var/www/nginx/rootfs/project-branch/$profile/$major/project-branch-$profile-$version.tgz"
	upload_dir=`dirname $upload_path`

	ssh -i /home/rainmaker/.ssh/image.rainmaker-dev.com_id_rsa rainmaker@"$profile_download_server" "mkdir -p $upload_dir"
	scp -i /home/rainmaker/.ssh/image.rainmaker-dev.com_id_rsa /var/lib/lxc/_golden-branch_/rootfs.tgz rainmaker@"$profile_download_server":"$upload_path"
	
	if [ "$setlatest" -eq 1 ]; then
		echo "$version" > /tmp/latest
		scp -i /home/rainmaker/.ssh/image.rainmaker-dev.com_id_rsa /tmp/latest rainmaker@"$profile_download_server":"/var/www/nginx/rootfs/project-branch/$profile/latest"
		unlink /tmp/latest
	fi

	unlink /var/lib/lxc/_golden-branch_/rootfs.tgz
	lxc-destroy -n _golden-branch_
fi
