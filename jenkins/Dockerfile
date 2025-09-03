FROM jenkins/jenkins:lts

USER root

# Install kubectl
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Kaniko executor
RUN curl -L https://github.com/GoogleContainerTools/kaniko/releases/latest/download/executor -o /usr/local/bin/executor && \
    chmod +x /usr/local/bin/executor

# Install jq for JSON processing
RUN apt-get install -y jq

# Create kaniko config directory
RUN mkdir -p /kaniko/.docker && \
    chown -R jenkins:jenkins /kaniko

USER jenkins

# Set environment variables for Kaniko
ENV DOCKER_CONFIG=/kaniko/.docker
ENV KANIKO_DOCKER_CONFIG=/kaniko/.docker