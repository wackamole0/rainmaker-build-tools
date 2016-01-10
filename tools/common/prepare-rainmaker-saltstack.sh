#!/usr/bin/env bash

script_path=`dirname $0`
tools_path="$script_path/.."

usage() {
    cat << EOF

usage: $0 [--help] [--fullstack]

OPTIONS:
   -h,--help   : show this message
   --fullstack : deploy all Salt environments and not just the base environment

EOF
}

# Initialise some variables
fullstack=0;

# Process command line options
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 1
        ;;
        --fullstack)
            fullstack=1
            shift
            break
        ;;
    esac
    shift
done

if [ $fullstack -eq 1 ]; then
    $script_path/configure-salt.sh --fullstack
else
    $script_path/configure-salt.sh
fi

saltenvs="base"
if [ $fullstack -eq 1 ]; then
    saltenvs="base builder profile-builder testbed"
fi

# Create base directory for state and pillar tree
if [ ! -d /srv/saltstack ]; then
    mkdir /srv/saltstack
fi

# Create basic directory structure for state tree file roots
if [ ! -d /srv/saltstack/salt ]; then
    mkdir /srv/saltstack/salt
fi

for saltenv in $saltenvs
do
    if [ ! -d "/srv/saltstack/salt/$saltenv" ]; then
        mkdir "/srv/saltstack/salt/$saltenv"
    fi

    if [ ! -d "/srv/saltstack/salt/$saltenv/rainmaker" ]; then
        mkdir "/srv/saltstack/salt/$saltenv/rainmaker"
    fi

    if [ ! -d "/srv/saltstack/salt/$saltenv/rainmaker/project" ]; then
        mkdir "/srv/saltstack/salt/$saltenv/rainmaker/project"
    fi

    if [ ! -d "/srv/saltstack/salt/$saltenv/rainmaker/branch" ]; then
        mkdir "/srv/saltstack/salt/$saltenv/rainmaker/branch"
    fi
done

# Configure the top files
cp $script_path/config/salt/top.sls /srv/saltstack/salt/base/top.sls

if [ $fullstack -eq 1 ]; then
    cp $script_path/config/salt/fullstack/builder-top.sls /srv/saltstack/salt/builder/top.sls
    cp $script_path/config/salt/fullstack/profile-builder-top.sls /srv/saltstack/salt/profile-builder/top.sls
    cp $script_path/config/salt/fullstack/testbed-top.sls /srv/saltstack/salt/testbed/top.sls
fi

# Create basic directory structure for Pillar tree file roots
if [ ! -d /srv/saltstack/pillar ]; then
    mkdir /srv/saltstack/pillar
fi

for saltenv in $saltenvs
do
    if [ ! -d "/srv/saltstack/pillar/$saltenv" ]; then
        mkdir "/srv/saltstack/pillar/$saltenv"
    fi

    if [ ! -d "/srv/saltstack/pillar/$saltenv/rainmaker" ]; then
        mkdir "/srv/saltstack/pillar/$saltenv/rainmaker"
    fi

    if [ ! -d "/srv/saltstack/pillar/$saltenv/rainmaker/project" ]; then
        mkdir "/srv/saltstack/pillar/$saltenv/rainmaker/project"
    fi

    if [ ! -d "/srv/saltstack/pillar/$saltenv/rainmaker/branch" ]; then
        mkdir "/srv/saltstack/pillar/$saltenv/rainmaker/branch"
    fi
done

# Configure the top files for the Pillar trees
cp $script_path/config/pillar/top.sls /srv/saltstack/pillar/base/top.sls

if [ $fullstack -eq 1 ]; then
    cp $script_path/config/pillar/fullstack/builder-top.sls /srv/saltstack/pillar/builder/top.sls
    cp $script_path/config/pillar/fullstack/profile-builder-top.sls /srv/saltstack/pillar/profile-builder/top.sls
    cp $script_path/config/pillar/fullstack/testbed-top.sls /srv/saltstack/pillar/testbed/top.sls
fi

# Create directory structure for Rainmaker profiles
if [ ! -d /srv/saltstack/profiles ]; then
    mkdir /srv/saltstack/profiles
fi

if [ ! -d /srv/saltstack/profiles/project ]; then
    mkdir /srv/saltstack/profiles/project
fi

if [ ! -d /srv/saltstack/profiles/branch ]; then
    mkdir /srv/saltstack/profiles/branch
fi

if [ ! -f /srv/saltstack/profiles/manifest.json ]; then
    cp $script_path/config/manifest.json /srv/saltstack/profiles/manifest.json
fi

# Core profile
/opt/rainmaker-profile-manager/rprofmgr profile:add https://github.com/wackamole0/rainmaker-salt-core.git

# Default root VM profile
/opt/rainmaker-profile-manager/rprofmgr profile:add https://github.com/wackamole0/rainmaker-default-core-profile.git

# Default service container profile
/opt/rainmaker-profile-manager/rprofmgr profile:add https://github.com/wackamole0/rainmaker-default-services-profile.git

# Default project
/opt/rainmaker-profile-manager/rprofmgr profile:add https://github.com/wackamole0/rainmaker-default-project-profile.git

# Default branch
/opt/rainmaker-profile-manager/rprofmgr profile:add https://github.com/wackamole0/rainmaker-default-branch-profile.git

# Drupal classic branch
/opt/rainmaker-profile-manager/rprofmgr profile:add https://github.com/wackamole0/rainmaker-drupal-classic-profile.git

if [ $fullstack -eq 1 ]; then

    if [ ! -d /srv/saltstack/pillar/builder/rainmaker/core ]; then
        git clone https://github.com/wackamole0/rainmaker-builder-pillar.git /srv/saltstack/pillar/builder/rainmaker/core
    fi

    if [ ! -d /srv/saltstack/pillar/profile-builder/rainmaker/core ]; then
        git clone https://github.com/wackamole0/rainmaker-profile-builder-pillar.git /srv/saltstack/pillar/profile-builder/rainmaker/core
    fi

    if [ ! -d /srv/saltstack/pillar/testbed/rainmaker/core ]; then
        git clone https://github.com/wackamole0/rainmaker-testbed-pillar.git /srv/saltstack/pillar/testbed/rainmaker/core
    fi

fi

for saltenv in $saltenvs
do
    /opt/rainmaker-profile-manager/rprofmgr node:add rainmaker.localdev rainmaker/default-core-dev 1.0 --salt-environment=$saltenv
    /opt/rainmaker-profile-manager/rprofmgr node:add services.rainmaker.localdev rainmaker/default-services-dev 1.0 --salt-environment=$saltenv
done
