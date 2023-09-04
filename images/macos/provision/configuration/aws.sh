#!/bin/bash -e -o pipefail

echo "Setting user password..."
echo "$PASSWORD" | sudo -S sh -c "dscl . -passwd /Users/$USERNAME $PASSWORD"

echo "Creating runner user..."
sudo sysadminctl -addUser runner -shell /bin/bash -password $PASSWORD -home /Users/runner -admin
sudo createhomedir -c -u runner
sudo sh -c "echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/runner"

echo "Configuring runner user..."
cp /Users/$USERNAME/.bash_profile /Users/runner/.bash_profile
ln -s /Users/$USERNAME/.bashrc /Users/runner/.bashrc

mkdir /Users/$USERNAME/hostedtoolcache
chown $USERNAME:staff /Users/$USERNAME/hostedtoolcache
ln -s /Users/$USERNAME/hostedtoolcache /Users/runner/hostedtoolcache

echo "Activating Remote Desktop..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -restart -agent -privs -all

# tmp until SoftwareReport.Generator.ps1 is fixed
mkdir image-generation/output
