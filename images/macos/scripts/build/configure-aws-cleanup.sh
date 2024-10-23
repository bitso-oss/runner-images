#!/bin/bash -e -o pipefail
################################################################################
##  File:  configure-aws-cleanup.sh
##  Desc:  Cleanup AWS EC2 machine before creating the AMI
##
################################################################################

echo "Removing macos-init instance logs..."
sudo ec2-macos-init clean -all

echo "Disable password randomization in ec2-macos-init..."
sudo sed -i '' 's/RandomizePassword = true/RandomizePassword = false/g' /usr/local/aws/ec2-macos-init/init.toml

echo "Changing homebrew permissions to runner user..."
sudo chown -R runner /opt/homebrew

echo "Removing Bash history..."
history -c
