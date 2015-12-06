#!/usr/bin/env bash

script_path=`dirname $0`
tools_path="$script_path/.."

curdir=`pwd`

cd /tmp
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

cd $curdir
