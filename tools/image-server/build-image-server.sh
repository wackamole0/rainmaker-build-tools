#!/usr/bin/env bash

if [ `id -u` -ne 0 ]
then
  echo "You must run this with root permissions"
  exit
fi

script_path=`dirname $0`
tools_path="$script_path/.."

hostname image.rainmaker.localdev
echo "image.rainmaker.localdev" > /etc/hostname
cp $script_path/config/hosts /etc/hosts

echo 'nameserver 8.8.8.8' > /etc/resolv.conf

$tools_path/common/upgrade-ubuntu.sh
$tools_path/common/bootstrap-core-tools.sh
$tools_path/common/bootstrap-salt.sh

$script_path/prepare-saltstack.sh --fullstack

echo "image.rainmaker.localdev" > /etc/salt/minion_id

$script_path/provision-image-server.sh --environment=builder
