#!/bin/bash

if [ ! -e ~/rainmaker-testbed ];
then
  mkdir ~/rainmaker-testbed
fi

mount -o rw -t nfs 10.250.0.254:/export/rainmaker ~/rainmaker-testbed
