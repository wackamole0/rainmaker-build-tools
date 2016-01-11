#!/usr/bin/env bash

script_path=`dirname $0`
tools_path="$script_path/.."

if [ ! -d /opt/rainmaker-cli ]; then
    mkdir -p /opt/rainmaker-cli
fi

curdir=`pwd`

apt-get install -y php5-curl php5-sqlite

cd /opt/rainmaker-cli
git clone https://github.com/wackamole0/rainmaker-tool.git .
git checkout 0.1

cd $curdir

if [ ! -h /usr/local/bin/rainmaker ]; then
    ln -s /opt/rainmaker-cli/rainmaker /usr/local/bin/rainmaker
fi
