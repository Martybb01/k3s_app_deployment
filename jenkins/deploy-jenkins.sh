#!/bin/bash

echo "Auto-Deploy Jenkins su cluster K3s"
echo "====================================="

echo "Aspettando che tutti i nodi siano pronti..."
timeout=300
counter=0
while [ $counter -lt $timeout ]; do
    ready_nodes=$(sudo kubectl get nodes --no-headers | grep " Ready " | wc -l)
    if [ "$ready_nodes" -eq 3 ]; then
        echo "✅ Tutti e 3 i nodi sono pronti!"
        break
    fi
    echo "   Nodi pronti: $ready_nodes/3... (attesa: ${counter}s)"
    sleep 10
    counter=$((counter + 10))
done

if [ $counter -eq $timeout ]; then
    echo "❌ Timeout: Non tutti i nodi sono diventati pronti"
    exit 1
fi

echo 'Building Jenkins custom image'
cd /vagrant/jenkins
sudo docker build -t jenkins-custom:latest .

echo "Loading Jenkins image in K3s..."
sudo docker save jenkins-custom:latest | sudo k3s ctr images import -

echo "Deploying Jenkins storage..."
sudo kubectl apply -f /vagrant/jenkins/jenkins_storage.yaml

echo "Aspettando binding PVC..."
sleep 10

echo "Deploying Jenkins..."
sudo kubectl apply -f /vagrant/jenkins/jenkins_deploy.yaml

echo "Aspettando che Jenkins sia pronto..."
sleep 60

echo ""
echo "✅ Jenkins deployato con successo!"
echo ""