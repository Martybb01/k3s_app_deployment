Vagrant.configure("2") do |config|

  # Configurazione comune per tutti i nodi
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update -y
    echo "192.168.56.10 master-node" | sudo tee /etc/hosts
    echo "192.168.56.11 worker-node01" | sudo tee -a /etc/hosts
    echo "192.168.56.12 worker-node02" | sudo tee -a /etc/hosts
  SHELL

  config.vm.synced_folder ".", "/vagrant"

  # Master Node (k3s server)
  config.vm.define "master" do |master|
    master.vm.box = "bento/ubuntu-22.04"
    master.vm.hostname = "master-node"
    master.vm.network "private_network", ip: "192.168.56.10"
    
    master.vm.provision "shell", path: "setup_script_k3s.sh", privileged: true
    
    master.vm.provision "shell", inline: <<-SHELL
      
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.10 --flannel-iface=eth1" sh -
      
      sudo systemctl enable k3s
      sudo systemctl start k3s
      
      sudo mkdir -p /home/vagrant/.kube 2>/dev/null || true
      sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config 2>/dev/null || true
      sudo chown vagrant:vagrant /home/vagrant/.kube/config 2>/dev/null || true
      sudo chmod 600 /home/vagrant/.kube/config

      sudo mkdir -p /opt/jenkins-data
      sudo chown vagrant:vagrant /opt/jenkins-data
      sudo chmod 755 /opt/jenkins-data
      
      sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
      
      echo "Master node configurato! Token salvato in /vagrant/node-token"
    SHELL

    
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
  end


  (1..2).each do |i|
    config.vm.define "node0#{i}" do |node|
      node.vm.box = "bento/ubuntu-22.04"
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network "private_network", ip: "192.168.56.1#{i}"
      
      node.vm.provision "shell", path: "setup_script_k3s.sh", privileged: true
      
      node.vm.provision "shell", inline: <<-SHELL
        while [ ! -f /vagrant/node-token ]; do
          echo "Aspettando il token dal master node..."
          sleep 5
        done
        
        K3S_TOKEN=$(cat /vagrant/node-token)
        
        curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.10:6443 K3S_TOKEN=$K3S_TOKEN INSTALL_K3S_EXEC="--node-ip=192.168.56.1#{i} --flannel-iface=eth1" sh -
        
        sudo systemctl enable k3s-agent
        sudo systemctl start k3s-agent
        
        sudo mkdir -p /opt/jenkins-data
        sudo chown vagrant:vagrant /opt/jenkins-data
        sudo chmod 755 /opt/jenkins-data
        
        echo "Worker node0#{i} configurato e connesso al cluster!"
      SHELL
      
      if i == 2
        node.vm.provision "shell", inline: <<-SHELL
          if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
            sudo -u vagrant ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -N ""
          fi
          sudo -u vagrant sshpass -p 'vagrant' ssh-copy-id -o StrictHostKeyChecking=no vagrant@192.168.56.10

          if sudo -u vagrant ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 vagrant@192.168.56.10 "echo 'SSH connection successful'"; then
            echo "✅ Connessione SSH al master riuscita!"
            sleep 30
            sudo -u vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "cd /vagrant && bash jenkins/deploy-jenkins.sh"
          else
            echo "Connessione SSH al master fallita"
          fi
        SHELL
      end
      
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 1
      end
    end
  end
end