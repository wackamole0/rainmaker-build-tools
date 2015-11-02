#!/usr/bin/env php
<?php

$script_dir = dirname(__FILE__);
$nic_template = file_get_contents($argv[1]);

$output = `ip addr show br0`;
$host_ip = '10.100.0.254';
$services_ip = '10.100.0.2';
if (preg_match('/inet\s(.+?)\//', $output, $matches) === 1) {
  $host_ip = $matches[1];
  $octets = explode('.', $host_ip);
  $octets[3] = '2';
  $services_ip = implode('.', $octets);
}

#print "$host_ip\n";
#print "$services_ip\n";

$nic_template = str_replace('{{ip_address}}', $services_ip, $nic_template);
$nic_template = str_replace('{{gateway_address}}', $host_ip, $nic_template);

file_put_contents($argv[2], $nic_template);
