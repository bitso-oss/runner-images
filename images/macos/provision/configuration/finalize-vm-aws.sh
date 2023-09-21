#!/bin/bash -e -o pipefail

echo "Removing macos-init instance logs..."
sudo ec2-macos-init clean -all

echo "Changing homebrew permissions to runner user..."
sudo chown -R runner /opt/homebrew

echo "Removing Bash history..."
rm -f /Users/ec2-user/.bash_history
