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

# Configure Salt master and minion
if [ $fullstack -eq 1 ]
then
  $tools_path/image-server/configure-salt.sh --fullstack
else
  $tools_path/image-server/configure-salt.sh
fi

# Create base directory for state and pillar tree
if [ ! -d /srv/saltstack ]
then
  mkdir /srv/saltstack
fi

# Create basic directory structure for state tree file roots
if [ ! -d /srv/saltstack/salt ]
then
  mkdir /srv/saltstack/salt
fi

if [ ! -d /srv/saltstack/salt/base ]
then
  mkdir /srv/saltstack/salt/base
fi

#if [ $fullstack -eq 1 ]
#then
#
#  if [ ! -d /srv/saltstack/salt/builder ]
#  then
#    mkdir /srv/saltstack/salt/builder
#  fi

#fi

if [ ! -d /srv/saltstack/salt/base/rainmaker ]
then
  mkdir /srv/saltstack/salt/base/rainmaker
fi

# Configure the top files
cp $script_path/config/salt/top.sls /srv/saltstack/salt/base/top.sls

#if [ $fullstack -eq 1 ]
#then
#  cp $script_path/config/salt/fullstack/builder-top.sls /srv/saltstack/salt/builder/top.sls
#fi

# Create basic directory structure for Pillar tree file roots
if [ ! -d /srv/saltstack/pillar ]
then
  mkdir /srv/saltstack/pillar
fi

if [ ! -d /srv/saltstack/pillar/base ]
then
  mkdir /srv/saltstack/pillar/base
fi

if [ ! -d /srv/saltstack/pillar/base/rainmaker ]
then
  mkdir /srv/saltstack/pillar/base/rainmaker
fi

#if [ $fullstack -eq 1 ]
#then
#
#  if [ ! -d /srv/saltstack/pillar/builder ]
#  then
#    mkdir /srv/saltstack/pillar/builder
#  fi
#
#  if [ ! -d /srv/saltstack/pillar/builder/rainmaker ]
#  then
#    mkdir /srv/saltstack/pillar/builder/rainmaker
#  fi

#fi

# Configure the top files for the Pillar trees
cp $script_path/config/pillar/top.sls /srv/saltstack/pillar/base/top.sls

#if [ $fullstack -eq 1 ]
#then
#  cp $script_path/config/pillar/fullstack/builder-top.sls /srv/saltstack/pillar/builder/top.sls
#fi

# Create directory structure for Rainmaker profiles
if [ ! -d /srv/saltstack/profiles ]
then
  mkdir /srv/saltstack/profiles
fi

# Ideally here we would checkout the Rainmaker Profile Manager tool and use it
# to install the basic profiles we need. However, the tool is not ready yet so
# we will have to do this manually here.

if [ ! -d /srv/saltstack/profiles/rainmaker-image-server ]
then
  git clone https://github.com/wackamole0/rainmaker-image-server-salt.git /srv/saltstack/profiles/rainmaker-image-server
fi

#/srv/saltstack/profiles/rainmaker-image-server/salt

if [ ! -d /srv/saltstack/salt/base/rainmaker/image-server ]
then
  ln -s /srv/saltstack/profiles/rainmaker-image-server/salt /srv/saltstack/salt/base/rainmaker/image-server
fi

if [ ! -d /srv/saltstack/pillar/base/rainmaker/image-server ]
then
  ln -s /srv/saltstack/profiles/rainmaker-image-server/pillar /srv/saltstack/pillar/base/rainmaker/image-server
fi

#if [ $fullstack -eq 1 ]
#then
#
#  if [ ! -d /srv/saltstack/pillar/builder/rainmaker/core ]
#  then
#    git clone https://github.com/wackamole0/rainmaker-builder-pillar.git /srv/saltstack/pillar/builder/rainmaker/core
#  fi
#
#fi
