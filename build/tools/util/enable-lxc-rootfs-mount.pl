#!/usr/bin/perl -w

use strict;
use warnings qw {all};
use File::Basename;

my $fsloc = dirname($0);

open my $fh, "<", "$fsloc/../config/root/fstab" or die $!;
local $/;
my $content = <$fh>;
close $fh;

$content =~ s/#\/dev\/sdb1/\/dev\/sdb1/;

print $content;
