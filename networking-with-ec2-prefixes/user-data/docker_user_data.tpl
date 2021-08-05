#!/bin/bash -xe
echo "${public_key_contents}" >> ~ec2-user/.ssh/authorized_keys
#sleep 5
#/usr/sbin/dhclient -6 ens5
#apt -y update
#apt -y install docker.io
yum update -y
yum install -y docker
service docker start

