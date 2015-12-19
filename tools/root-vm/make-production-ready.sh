#!/usr/bin/env bash

if [ `id -u` -ne 0 ]; then
    echo "You must run this with root permissions"
    exit
fi

script_path=`dirname $0`
tools_path="$script_path/.."

cp $script_path/config/default/nic-br0.cfg /etc/network/interfaces.d/br0.cfg
cp $script_path/config/default/nfs-exports /etc/exports

saltenvs="builder profile-builder testbed"

for saltenv in $saltenvs
do
    rprofmgr node:remove --salt-environment=$saltenv rainmaker.localdev
    rprofmgr node:remove --salt-environment=$saltenv services.rainmaker.localdev

    if [ -d "/srv/saltstack/salt/$saltenv" ]; then
        rm -Rf "/srv/saltstack/salt/$saltenv"
    fi

    if [ -d "/srv/saltstack/pillar/$saltenv" ]; then
        rm -Rf "/srv/saltstack/pillar/$saltenv"
    fi
done

# Clear LXC caches
find /var/cache/lxc/* -maxdepth 0 -type d | fgrep -v rainmaker | xargs rm -Rf

apt-get clean
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c
