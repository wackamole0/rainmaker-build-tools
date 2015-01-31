#!/usr/bin/perl -w

use strict;
use warnings qw {all};

<> =~ /inet \d+\.\d+\.\d+\.\d+\/(\d+)/;

my $cidr = $1;
my $fullBlocks = int($cidr / 8);
my @netmask = ();
for (my $i = 0; $i < $fullBlocks; $i++) {
  push(@netmask, '255');
}

my $partialBlock = $cidr % 8;
if ($partialBlock > 0) {
  my $binBlock = ('1' x $partialBlock) . ('0' x (8 - $partialBlock));
  push(@netmask, oct('0b' . $binBlock));
  $fullBlocks++;
}

for (my $i = $fullBlocks; $i < 4; $i++) {
  push(@netmask, '0');
} 

print join('.', @netmask);
