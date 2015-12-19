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

cp $tools_path/image-server/config/salt/master /etc/salt/master
cp $tools_path/image-server/config/salt/minion /etc/salt/minion
