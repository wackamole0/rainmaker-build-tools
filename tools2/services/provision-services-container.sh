#!/bin/bash

# Set the resolver
echo 'nameserver 8.8.8.8' > /etc/resolv.conf


salt-call -l debug --local state.highstate
