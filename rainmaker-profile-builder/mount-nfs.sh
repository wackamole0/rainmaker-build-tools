#!/bin/bash

if [ ! -e ~/rainmaker-profile-builder ]; then
    mkdir ~/rainmaker-profile-builder
fi

mount -o rw -t nfs 10.251.0.254:/export/rainmaker ~/rainmaker-profile-builder
