#!/usr/bin/perl -w

use strict;
use warnings qw {all};
use File::Basename;

my $fsloc = dirname($0);

my $script;

$script = $fsloc . '/get-interface-ip.pl';
my $gateway = `ip addr show br0 | fgrep inet | $script`;

$gateway =~ /^(\d+\.\d+)/;
my $ip = $1 . '.0.2';

$script = $fsloc . '/get-interface-netmask.pl';
my $netmask = `ip addr show br0 | fgrep inet | $script`;

open my $fh, "<", "$fsloc/../config/services/network-interfaces" or die $!;
local $/; # enable localized slurp mode
my $content = <$fh>;
close $fh;

$content =~ s/_IP_/$ip/;
$content =~ s/_NETMASK_/$netmask/;
$content =~ s/_GATEWAY_/$gateway/;

print $content;
