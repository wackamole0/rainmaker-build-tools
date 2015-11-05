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

if [ $fullstack -eq 1 ]
then
  $script_path/configure-salt.sh --fullstack
else
  $script_path/configure-salt.sh
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

if [ $fullstack -eq 1 ]
then

  if [ ! -d /srv/saltstack/salt/builder ]
  then
    mkdir /srv/saltstack/salt/builder
  fi

  if [ ! -d /srv/saltstack/salt/profile-builder ]
  then
    mkdir /srv/saltstack/salt/profile-builder
  fi

  if [ ! -d /srv/saltstack/salt/testbed ]
  then
    mkdir /srv/saltstack/salt/testbed
  fi

fi

if [ ! -d /srv/saltstack/salt/base/rainmaker ]
then
  mkdir /srv/saltstack/salt/base/rainmaker
fi

if [ ! -d /srv/saltstack/salt/base/rainmaker/project ]
then
  mkdir /srv/saltstack/salt/base/rainmaker/project
fi

if [ ! -d /srv/saltstack/salt/base/rainmaker/branch ]
then
  mkdir /srv/saltstack/salt/base/rainmaker/branch
fi

# Configure the top files
cp $script_path/config/salt/top.sls /srv/saltstack/salt/base/top.sls

if [ $fullstack -eq 1 ]
then
  cp $script_path/config/salt/fullstack/builder-top.sls /srv/saltstack/salt/builder/top.sls
  cp $script_path/config/salt/fullstack/profile-builder-top.sls /srv/saltstack/salt/profile-builder/top.sls
  cp $script_path/config/salt/fullstack/testbed-top.sls /srv/saltstack/salt/testbed/top.sls
fi

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

if [ $fullstack -eq 1 ]
then

  if [ ! -d /srv/saltstack/pillar/builder ]
  then
    mkdir /srv/saltstack/pillar/builder
  fi

  if [ ! -d /srv/saltstack/pillar/builder/rainmaker ]
  then
    mkdir /srv/saltstack/pillar/builder/rainmaker
  fi

  if [ ! -d /srv/saltstack/pillar/profile-builder ]
  then
    mkdir /srv/saltstack/pillar/profile-builder
  fi

  if [ ! -d /srv/saltstack/pillar/profile-builder/rainmaker ]
  then
    mkdir /srv/saltstack/pillar/profile-builder/rainmaker
  fi

  if [ ! -d /srv/saltstack/pillar/testbed ]
  then
    mkdir /srv/saltstack/pillar/testbed
  fi

  if [ ! -d /srv/saltstack/pillar/testbed/rainmaker ]
  then
    mkdir /srv/saltstack/pillar/testbed/rainmaker
  fi

fi

# Configure the top files for the Pillar trees
cp $script_path/config/pillar/top.sls /srv/saltstack/pillar/base/top.sls

if [ $fullstack -eq 1 ]
then
  cp $script_path/config/pillar/fullstack/builder-top.sls /srv/saltstack/pillar/builder/top.sls
  cp $script_path/config/pillar/fullstack/profile-builder-top.sls /srv/saltstack/pillar/profile-builder/top.sls
  cp $script_path/config/pillar/fullstack/testbed-top.sls /srv/saltstack/pillar/testbed/top.sls
fi

# Create directory structure for Rainmaker profiles
if [ ! -d /srv/saltstack/profiles ]
then
  mkdir /srv/saltstack/profiles
fi

if [ ! -d /srv/saltstack/profiles/project ]
then
  mkdir /srv/saltstack/profiles/project
fi

if [ ! -d /srv/saltstack/profiles/branch ]
then
  mkdir /srv/saltstack/profiles/branch
fi


# Ideally here we would checkout the Rainmaker Profile Manager tool and use it
# to install the basic profiles we need. However, the tool is not ready yet so
# we will have to do this manually here.

if [ ! -d /srv/saltstack/profiles/core ]
then
  git clone https://github.com/wackamole0/rainmaker-salt-core.git /srv/saltstack/profiles/core
fi

if [ ! -d /srv/saltstack/salt/base/rainmaker/core ]
then
  ln -s /srv/saltstack/profiles/core/salt /srv/saltstack/salt/base/rainmaker/core
fi

if [ ! -d /srv/saltstack/pillar/base/rainmaker/core ]
then
  ln -s /srv/saltstack/profiles/core/pillar /srv/saltstack/pillar/base/rainmaker/core
fi

if [ $fullstack -eq 1 ]
then

  if [ ! -d /srv/saltstack/pillar/builder/rainmaker/core ]
  then
    git clone https://github.com/wackamole0/rainmaker-builder-pillar.git /srv/saltstack/pillar/builder/rainmaker/core
  fi

  if [ ! -d /srv/saltstack/pillar/profile-builder/rainmaker/core ]
  then
    git clone https://github.com/wackamole0/rainmaker-profile-builder-pillar.git /srv/saltstack/pillar/profile-builder/rainmaker/core
  fi

  if [ ! -d /srv/saltstack/pillar/testbed/rainmaker/core ]
  then
    git clone https://github.com/wackamole0/rainmaker-testbed-pillar.git /srv/saltstack/pillar/testbed/rainmaker/core
  fi

fi
