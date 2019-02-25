#!/bin/bash
echo "${private_key_contents}" >> ~ec2-user/mykey
chown ec2-user:ubuntu ~ec2-user/mykey
chmod 600 ~ec2-user/mykey

