#!/bin/bash

if [ ! -e ~/rainmaker-builder ];
then
  mkdir ~/rainmaker-builder
fi

mount -o rw -t nfs 10.250.0.254:/export/rainmaker ~/rainmaker-builder

