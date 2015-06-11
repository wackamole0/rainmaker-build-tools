#!/bin/bash

DIR=`dirname $0`

RESTART_NETWORKING=0;

while [ "$#" -gt 0 ]; do
  case $1 in
    --restart)
      RESTART_NETWORKING=1
      shift
      break
      ;;
  esac
  shift
done

echo 'nameserver 8.8.8.8' > /etc/resolv.conf

cp "$DIR/../config/root/nic-br0-build.cfg" /etc/network/interfaces.d/br0.cfg

# Restart networking so config changes take effect if necessary
if [ "$RESTART_NETWORKING" -eq 1 ];
then
  ifdown br0 && ifdown eth1
  ifup br0 && ifup eth1
fi