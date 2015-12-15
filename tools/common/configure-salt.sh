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

# Stop the Salt services we do not need
if [ "`service salt-master status | fgrep running`" != "" ]; then
  service salt-master stop
fi

update-rc.d -f salt-master remove

if [ "`service salt-syndic status | fgrep running`" != "" ]; then
  service salt-syndic stop
fi

update-rc.d -f salt-syndic remove

# Configure Salt master and minion
if [ $fullstack -eq 1 ]
then
  cp $tools_path/common/config/salt/fullstack/master /etc/salt/master
  cp $tools_path/common/config/salt/fullstack/minion /etc/salt/minion
else
  cp $tools_path/common/config/salt/master /etc/salt/master
  cp $tools_path/common/config/salt/minion /etc/salt/minion
fi
