#!/bin/bash

# Automation to set up docker/minikube dev environment on Ubuntu 20.04 on WSL2 without needing Docker Desktop
echo "=========================================="
echo "Updating system"
echo "=========================================="
sudo apt update -y
sudo apt upgrade -y

# install docker
echo "Installing docker"
sudo apt remove docker docker-engine docker.io containerd runc -y # remove old versions
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

source /etc/os-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

sudo usermod -aG docker $USER

# TODO (optional): add logic to share dockerd across WSL distros: https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9

# Configure docker
echo "=========================================="
echo "Configuring docker"
echo "=========================================="
DOCKER_DIR=/mnt/wsl/shared-docker
sudo mkdir -pm o=,ug=rwx "$DOCKER_DIR"
sudo chgrp docker "$DOCKER_DIR"

sudo mkdir /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "hosts": ["unix:///mnt/wsl/shared-docker/docker.sock"]
}
EOF

# Change DOCKER_DISTRO to the name of your WSL2
echo "=========================================="
echo "Updating .profile to run dockerd on login"
echo "=========================================="
tee -a /home/$USER/.profile > /dev/null <<'EOF'

# dockerd launch script
DOCKER_DISTRO="Ubuntu"
DOCKER_DIR=/mnt/wsl/shared-docker
DOCKER_SOCK="$DOCKER_DIR/docker.sock"
export DOCKER_HOST="unix://$DOCKER_SOCK"
if [ ! -S "$DOCKER_SOCK" ]; then
    mkdir -pm o=,ug=rwx "$DOCKER_DIR"
    chgrp docker "$DOCKER_DIR"
    /mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
fi
EOF
