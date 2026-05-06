#!/bin/bash
set -e

echo "Updating system and installing MicroK8s..."
sudo apt update && sudo apt install -y util-linux-extra  # Required for newgrp/sg on some versions
sudo snap install microk8s --classic

echo "Configuring user permissions..."
# Add current user to microk8s group
sudo usermod -a -G microk8s $USER

# Fix permissions on ~/.kube to store config
mkdir -p ~/.kube
sudo chown -f -R $USER ~/.kube

echo "Waiting for MicroK8s to be ready..."
# Use 'sg' to run the command with the new group immediately without a subshell hang
sg microk8s -c "microk8s status --wait-ready"

echo "Enabling common addons..."
sg microk8s -c "microk8s enable dns dashboard hostpath-storage"

echo "Setting up kubectl alias..."
if ! grep -q "alias kubectl=" ~/.bash_aliases 2>/dev/null; then
    echo "alias kubectl='microk8s kubectl'" >> ~/.bash_aliases
fi

echo "--------------------------------------------------------"
echo "Installation complete!"
echo "IMPORTANT: To use microk8s in your CURRENT terminal, run:"
echo "   newgrp microk8s"
echo "Otherwise, just open a new terminal window."
echo "--------------------------------------------------------"
