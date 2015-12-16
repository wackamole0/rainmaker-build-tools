#!/usr/bin/env bash

if [ `id -u` -ne 0 ]; then
    echo "You must run this with root permissions"
    exit
fi

script_path=`dirname $0`
tools_path="$script_path/.."

cp $script_path/config/default/nic-br0.cfg /etc/network/interfaces.d/br0.cfg
cp $script_path/config/default/nfs-exports /etc/exports

if [ -d /srv/saltstack/salt/builder ]; then
    rm -Rf /srv/saltstack/salt/builder
fi

if [ -d /srv/saltstack/pillar/builder ]; then
    rm -Rf /srv/saltstack/pillar/builder
fi

apt-get clean
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c
