#!/bin/bash

echo "Configurazione kubectl sui worker nodes"

vagrant ssh master -c "
  sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s-config/config
  sudo sed -i 's/127.0.0.1:6443/192.168.56.10:6443/g' /vagrant/k3s-config/config
  sudo chmod 644 /vagrant/k3s-config/config
  echo 'Kubeconfig copiato dal master'
"

for node in node01 node02; do
  echo "Configurando kubectl su $node..."
  vagrant ssh $node -c "
    sudo mkdir -p /home/vagrant/.kube /root/.kube
    sudo cp /vagrant/k3s-config/config /home/vagrant/.kube/config
    sudo cp /vagrant/k3s-config/config /root/.kube/config
    sudo chown vagrant:vagrant /home/vagrant/.kube/config
    sudo chmod 600 /home/vagrant/.kube/config /root/.kube/config
    echo 'kubectl configurato su $node'
  "
done

echo "kubectl configurato su tutti i nodi!"