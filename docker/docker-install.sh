#!/bin/bash
set -e

echo "Uninstalling any conflicting packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || true
done

echo "Setting up Docker's official repository..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker Engine and Compose Plugin..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Configuring user permissions..."
sudo usermod -aG docker $USER

echo "Verifying installation..."
# 'sg' runs the next command with the 'docker' group without requiring a logout
sg docker -c "docker version && docker compose version"

echo "--------------------------------------------------------"
echo "Success! Docker and Docker Compose are installed."
echo "IMPORTANT: To use docker in your CURRENT terminal, run:"
echo "   newgrp docker"
echo "--------------------------------------------------------"
