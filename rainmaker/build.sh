#!/bin/bash

CURDIR=`pwd`
DIR=`dirname $0`
BOX="wackamole/rainmaker"
PACKAGE="wackamole-rainmaker.box"

cd "$DIR"

vagrant up

if [ -f "$PACKAGE" ]; then
  unlink "$PACKAGE"
fi

vagrant package --output "$PACKAGE"

if [ "`vagrant box list | fgrep $BOX`" != "" ]; then
  vagrant box remove "$BOX"
fi

vagrant box add "$BOX" "$PACKAGE"

cd "$CURDIR"
