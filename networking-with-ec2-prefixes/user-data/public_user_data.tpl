#!/bin/bash -xe
echo "${public_key_contents}" >> ~ubuntu/.ssh/authorized_keys
echo "${private_key_contents}" >> ~ubuntu/mykey
chown ubuntu:ubuntu ~ubuntu/mykey
chmod 600 ~ubuntu/mykey

