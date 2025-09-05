#!/bin/bash

echo "Deploying Jenkins with Kaniko solution..."

echo "Waiting for all nodes to be ready..."
timeout=300
counter=0
while [ $counter -lt $timeout ]; do
    ready_nodes=$(sudo kubectl get nodes --no-headers | grep " Ready " | wc -l)
    if [ "$ready_nodes" -eq 3 ]; then
        echo "All 3 nodes are ready!"
        break
    fi
    echo "   Ready nodes: $ready_nodes/3... (waiting: ${counter}s)"
    sleep 10
    counter=$((counter + 10))
done

if [ $counter -eq $timeout ]; then
    echo "❌ Timeout: Not all nodes are ready"
    exit 1
fi

echo "Building Jenkins image with Kaniko..."
cd /vagrant/jenkins
docker build -f Dockerfile -t localhost:5000/jenkins-kaniko:latest .

echo "Pushing Jenkins image to registry..."
docker push localhost:5000/jenkins-kaniko:latest

echo "Deploying Jenkins with Kaniko..."
sudo kubectl apply -f /vagrant/jenkins/jenkins_storage.yaml
sleep 10
sudo kubectl apply -f /vagrant/jenkins/jenkins_deploy.yaml

echo "Waiting for Jenkins to be ready..."
sudo kubectl wait --for=condition=available --timeout=100s deployment/jenkins -n jenkins

echo "Jenkins deployed successfully!"
echo "Jenkins URL: http://$(sudo kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'):30808"