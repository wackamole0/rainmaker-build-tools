#!/bin/bash

usage() {
    cat << EOF

usage: $0 [--help] [--environment]

OPTIONS:
   -h,--help        : show this message
   -e,--environment : provision for a specified Salt environment

EOF
}

# Set up the path option
options=$(getopt -o he: -l help,environment: -- "$@")

if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$options"

# Initialise some variables
environment=""

# Process command line options
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 1;;
        -e|--environment) environment=$2; shift 2;;
        *) break ;;
    esac
done

# Set the resolver
#echo 'nameserver 8.8.8.8' > /etc/resolv.conf

if [ "$environment" != "" ]; then
    salt-call -l debug --local state.highstate saltenv="$environment"
else
    salt-call -l debug --local state.highstate
fi

