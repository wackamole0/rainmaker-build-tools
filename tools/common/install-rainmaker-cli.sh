#!/usr/bin/env bash

script_path=`dirname $0`
tools_path="$script_path/.."

if [ ! -d /opt/rainmaker-cli ]; then
    mkdir -p /opt/rainmaker-cli
fi

curdir=`pwd`

apt-get install -y php5-curl

cd /opt/rainmaker-cli
git clone https://github.com/wackamole0/rainmaker-tool.git .
git checkout develop

cd $curdir

if [ ! -h /usr/local/bin/rainmaker ]; then
    ln -s /opt/rainmaker-cli/rainmaker /usr/local/bin/rainmaker
fi
