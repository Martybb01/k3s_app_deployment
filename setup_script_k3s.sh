#!/bin/bash

# 1. Update del sistema
sudo apt-get update -y
sudo apt-get install -y curl

# 2. Disabilita swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 3. Installa jq per manipolare JSON
sudo apt-get install -y jq sshpass

if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker vagrant
fi
sudo systemctl enable docker
sudo systemctl start docker

# 4. Ottieni l'IP locale per la configurazione
local_ip="$(ip --json addr show eth1 | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')"

echo "Setup base completato. L'installazione di k3s sarà gestita dal Vagrantfile."
echo "IP locale rilevato: $local_ip"