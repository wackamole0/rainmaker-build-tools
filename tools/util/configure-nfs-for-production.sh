#!/bin/bash

DIR=`dirname $0`

RESTART_NFS_SERVICE=0;

while [ "$#" -gt 0 ]; do
  case $1 in
    --restart)
      RESTART_NFS_SERVICE=1
      shift
      break
      ;;
  esac
  shift
done

cp "$DIR/../config/root/exports" /etc/exports

# Restart NFS so config changes take effect if necessary
if [ "$RESTART_NFS_SERVICE" -eq 1 ];
then
  service nfs-kernel-server reload
fi
