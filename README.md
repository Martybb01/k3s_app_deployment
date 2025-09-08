## k3s_app_deployment

Lab environment to deploy a simple Flask app on a local 3-node K3s cluster with a Jenkins CI/CD pipeline. The pipeline builds the image with Kaniko (Kubernetes Job), publishes it, and updates the deployment on K3s.

### Architecture
- **Compute**: 3 Vagrant/VirtualBox VMs
  - **master-node**: K3s control-plane + local Docker registry on `localhost:5000`
  - **worker-node01**, **worker-node02**: K3s agents
- **Cluster**: K3s with flannel networking (iface `eth1`) and `NodePort` for external access
- **Registry**: Local Docker registry on master, used by Jenkins and Kaniko
- **Jenkins**: deployed in namespace `jenkins`, persistent storage via hostPath, `NodePort 30808`
- **App**: Flask (Python) deployed in `default` namespace, `NodePort 30420`

### Technologies
- **Vagrant + VirtualBox**: local VM provisioning
- **K3s**: lightweight Kubernetes for dev
- **Docker/Containerd**: image build and runtime
- **Local Docker registry**: `registry:2` on port 5000 on the master
- **Jenkins**: CI/CD pipeline orchestration
- **Kaniko**: container builds inside Kubernetes without Docker daemon
- **Flask (Python 3.10)**: sample application

### Main components
- `Vagrantfile`: creates and configures the 3 VMs, installs K3s, configures the local registry, distributes kubeconfig to workers, and triggers the Jenkins deployment.
- `setup_script_k3s.sh`: OS prerequisites (swap off, Docker, sshpass, etc.).
- `jenkins/`:
  - `Dockerfile`: Jenkins image with `kubectl` installed.
  - `jenkins_storage.yaml`: Namespace, PV and PVC for Jenkins.
  - `jenkins_deploy.yaml`: Deployment, ServiceAccount, RBAC, NodePort Service, and ConfigMap for Kaniko.
  - `deploy-kaniko-jenkins.sh`: builds the Jenkins image in `localhost:5000` and deploys it on K3s.
- `flask-app/`:
  - `Dockerfile`: Flask app image.
  - `app.py`: basic endpoint, shows version and hostname.
  - `app_deploy.yaml`: Deployment (2 replicas) + NodePort Service.
- `Jenkinsfile`: declarative pipeline that:
  1) checks out the repo
  2) creates a Kaniko Kubernetes Job to build the image from `/vagrant/flask-app`
  3) updates `flask-app/app_deploy.yaml` with image `${IMAGE_NAME}:${BUILD_NUMBER}` and applies the deploy

### How it works
1. Vagrant creates the VMs and installs K3s (master + 2 workers) on the private network 192.168.56.0/24.
2. A local registry starts on the master at `localhost:5000`; K3s is configured to trust this insecure registry.
3. The image `localhost:5000/jenkins-kaniko:latest` is built and pushed, and Jenkins is deployed.
4. Jenkins runs the pipeline:
   - A Kaniko Job in the `jenkins` namespace builds the app image from `/vagrant/flask-app` and pushes it to DockerHub.
   - The `flask-app` deployment is updated with the new tag and rolled out on K3s.

### Prerequisites
- Host with VirtualBox and Vagrant installed
- Port 5000 available on the master (used by the registry)

### Quick setup
1) Bring up the environment
```bash
cd k3s_app_deployment
vagrant up
```

2) Access Jenkins
- URL: `http://<cluster_node_IP>:30808`
- `<cluster_node_IP>` is a cluster InternalIP (e.g., `192.168.56.10`).

3) Access the Flask app
- URL: `http://<cluster_node_IP>:30420`

### Notes on registry and images
- Jenkins and Kaniko are configured to push:
  - `localhost:5000/jenkins-kaniko:latest` (Jenkins image)
  - `${IMAGE_NAME}:${IMAGE_TAG}` (Flask app image)
- The K3s `registries.yaml` allows the use of the local insecure registry.

### Useful commands
```bash
# Access the VMs
vagrant ssh master
vagrant ssh node01
vagrant ssh node02

# Cluster status
kubectl get nodes -o wide | cat
kubectl get pods -A | cat

# Jenkins
kubectl -n jenkins get all | cat

# Flask app
kubectl get deploy,svc
kubectl rollout status deployment/flask-app
```

### Clean up
```bash
vagrant destroy -f
```
