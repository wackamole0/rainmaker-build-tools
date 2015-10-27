#!/usr/bin/env bash

if [ `id -u` -ne 0 ]
then
  echo "You must run this with root permissions"
  exit
fi

script_path=`dirname $0`
tools_path="$script_path/.."

$tools_path/common/upgrade-ubuntu.sh
$tools_path/common/bootstrap-salt.sh

cp $script_path/config/master /etc/salt/master
cp $script_path/config/minion /etc/salt/minion

if [ ! -d /srv/salt/rainmaker ]
then
  mkdir /srv/salt/rainmaker
fi

$script_path/provision-root-vm.sh
