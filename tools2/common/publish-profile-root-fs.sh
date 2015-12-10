#!/bin/bash

usage() {
  cat << EOF

usage:
   $0 <container name> <profile> <version> <profile rootfs server> <--project|--branch>
   $0 -h

OPTIONS:
   -h,--help            : show this message
   --branch             : publish this profile as a branch profile
   --project            : publish this profile as a project profile

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
  echo "'profile' parameter is required"
  exit 1
fi

if [ "$3" == "" ]; then
  echo "'version' parameter is required"
  exit 1
fi

if [ "$4" == "" ]; then
  echo "'profile rootfs server' parameter is required"
  exit 1
fi

# Initialise some variables

container_lxc_name=$1
container_lxc_root="/var/lib/lxc/$1"
container_lxc_root_fs="$container_lxc_root/rootfs"

profile_type="project"
profile=$2
version=$3
profile_rootfs_server=$4

snapshot=1
snapshot_file=""

# Set up the path option

options=$(getopt -o h -l help,project,branch -- "$@")

if [ $? -ne 0 ]; then
  exit 1
fi

eval set -- "$options"

# Fetch command line parameters

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)            usage; exit 1;;
    --branch)             profile_type="branch"; shift 1;;
    --project)            profile_type="project"; shift 1;;
    *)                    break ;;
  esac
done

if [ "$snapshot" -eq 1 ]; then
  if [ "$snapshot_file" == "" ]; then
    normalised_profile_name=`echo $profile | tr / -`
    snapshot_file="/tmp/$normalised_profile_name-$version.tgz"
  fi
  $script_path/snapshot-rootfs.sh "$container_lxc_name" "$snapshot_file"
fi

chown rainmaker:rainmaker "$snapshot_file"

major=`echo $version | cut -d'.' -f1`
profile_type_dir="project"
if [ "$profile_type" == "branch" ]; then
  profile_type_dir="project-branch"
fi
remote_rootfs_full_path="/var/www/nginx/rootfs/$profile_type_dir/$profile/$major/$version.tgz"
remote_rootfs_dir=`dirname $remote_rootfs_full_path`

ssh -i /home/rainmaker/.ssh/id_rsa rainmaker@"$profile_rootfs_server" "mkdir -p $remote_rootfs_dir"
scp -i /home/rainmaker/.ssh/id_rsa "$snapshot_file" rainmaker@"$profile_rootfs_server":"$remote_rootfs_full_path"

unlink "$snapshot_file"
