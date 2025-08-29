pipeline {
    agent any
    environment {
        REGISTRY = 'localhost:5000'
        IMAGE_NAME = 'flask-app'
        IMAGE_TAG = 'latest'
        IMAGE_FULL = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Container Image') {
            steps {
                script {
                    dir('flask-app') {
                        echo "Building container image with Podman..."

                        sh "podman build -t ${IMAGE_FULL} ."
                    }
                }
            }
        }

        stage('Push to Local Registry') {
            steps {
                script {
                    echo "Pushing image to local registry..."
                    
                    sh "podman push ${IMAGE_FULL} --tls-verify=false"
                    
                    echo "Image pushed successfully to ${REGISTRY}"
                }
            }
        }

        stage('Deploy to K3s') {
            steps {
                script {
                    dir('flask-app') {
                        echo "Deploying Flask app to K3s cluster..."
                        
                        sh "kubectl apply -f app_deploy.yaml"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                sh "podman rmi ${IMAGE_FULL} || true"
            }
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
            echo "App deployed with image: ${IMAGE_FULL}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}