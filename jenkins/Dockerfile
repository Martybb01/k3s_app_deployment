FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release sudo && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get install -y -t $(lsb_release -cs)-backports podman

RUN echo -e 'unqualified-search-registries = ["docker.io"]\n\n[[registry]]\nlocation = "docker.io"\ninsecure = false\n\n[[registry]]\nlocation = "localhost:5000"\ninsecure = true' > /etc/containers/registries.conf
    
RUN usermod -aG sudo jenkins && \
        echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER jenkins