#!/usr/bin/perl -w

use strict;
use warnings qw {all};
use File::Basename;

my $fsloc = dirname($0);

my $script;

$script = $fsloc . '/get-interface-ip.pl';
my $ip = `ip addr show eth1 | fgrep inet | $script`;

$script = $fsloc . '/get-interface-netmask.pl';
my $netmask = `ip addr show eth1 | fgrep inet | $script`;

open my $fh, "<", "$fsloc/../config/root/nic-br0.cfg" or die $!;
local $/; # enable localized slurp mode
my $content = <$fh>;
close $fh;

$content =~ s/_IP_/$ip/;
$content =~ s/_NETMASK_/$netmask/;

print $content;
