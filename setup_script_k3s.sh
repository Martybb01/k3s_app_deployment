#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y curl

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

sudo apt-get install -y sshpass

if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker vagrant
fi
sudo systemctl enable docker
sudo systemctl start docker

echo "Setup base completato. L'installazione di k3s sarà gestita dal Vagrantfile."