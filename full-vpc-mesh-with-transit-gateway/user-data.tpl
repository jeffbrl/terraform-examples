#!/bin/bash
echo "${private_key_contents}" >> ~ubuntu/mykey
chown ubuntu:ubuntu ~ubuntu/mykey
chmod 600 ~ubuntu/mykey 
