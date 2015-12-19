#!/usr/bin/env bash

script_path=`dirname $0`
tools_path="$script_path/.."

$tools_path/image-server/configure-salt.sh

# Create base directory for state and pillar tree
if [ ! -d /srv/saltstack ]; then
    mkdir /srv/saltstack
fi

# Create basic directory structure for state tree file roots
if [ ! -d /srv/saltstack/salt ]; then
    mkdir /srv/saltstack/salt
fi

if [ ! -d /srv/saltstack/salt/base ]; then
    mkdir /srv/saltstack/salt/base
fi

if [ ! -d /srv/saltstack/salt/base/rainmaker ]; then
    mkdir /srv/saltstack/salt/base/rainmaker
fi

# Configure the top files
cp $script_path/config/salt/top.sls /srv/saltstack/salt/base/top.sls

# Create basic directory structure for Pillar tree file roots
if [ ! -d /srv/saltstack/pillar ]; then
    mkdir /srv/saltstack/pillar
fi

if [ ! -d /srv/saltstack/pillar/base ]; then
    mkdir /srv/saltstack/pillar/base
fi

if [ ! -d /srv/saltstack/pillar/base/rainmaker ]; then
    mkdir /srv/saltstack/pillar/base/rainmaker
fi

# Configure the top files for the Pillar trees
cp $script_path/config/pillar/top.sls /srv/saltstack/pillar/base/top.sls

# Create directory structure for Rainmaker profiles
if [ ! -d /srv/saltstack/profiles ]; then
    mkdir /srv/saltstack/profiles
fi

if [ ! -d /srv/saltstack/profiles/rainmaker-image-server ]; then
    git clone --branch develop https://github.com/wackamole0/rainmaker-image-server-salt.git /srv/saltstack/profiles/rainmaker-image-server
fi

if [ ! -d /srv/saltstack/salt/base/rainmaker/image-server ]; then
    ln -s /srv/saltstack/profiles/rainmaker-image-server/salt /srv/saltstack/salt/base/rainmaker/image-server
fi

if [ ! -d /srv/saltstack/pillar/base/rainmaker/image-server ]; then
    ln -s /srv/saltstack/profiles/rainmaker-image-server/pillar /srv/saltstack/pillar/base/rainmaker/image-server
fi
