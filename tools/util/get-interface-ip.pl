#!/usr/bin/perl -w

use strict;
use warnings qw {all};

<> =~ /inet (\d+\.\d+\.\d+\.\d+)/;

print $1;
