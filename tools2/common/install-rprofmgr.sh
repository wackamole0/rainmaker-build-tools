#!/usr/bin/env bash

script_path=`dirname $0`
tools_path="$script_path/.."

if [ ! -d /opt/rainmaker-profile-manager ]
then
  mkdir -p /opt/rainmaker-profile-manager
fi

curdir=`pwd`

cd /opt/rainmaker-profile-manager
git clone https://github.com/wackamole0/rainmaker-profile-manager.git .
git checkout dev

cd $curdir
