pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'flask-app'
        DOCKER_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dir('flask-app') {
                        sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .'
                    }
                }
            }
        }

        stage('Import to K3s') {
            steps {
                script {
                    sh "docker save ${DOCKER_IMAGE}:${DOCKER_TAG} | k3s ctr images import -"
                }
            }
        }

         stage('Deploy to K3s') {
            steps {
                script {
                    dir('flask-app') {
                        echo "Deploying Flask app to K3s cluster..."
                        
                        sh "kubectl apply -f app_deploy.yaml"
                        
                        sh "kubectl rollout restart deployment/flask-app || echo 'Deployment not found, creating new one'"
                        
                        sh "kubectl rollout status deployment/flask-app --timeout=300s"
                    }
                }
            }
        }

        

        // stage('Test Image') {
        //     steps {
        //         script {
        //             sh "docker run --rm -d --name test-flask -p 5001:5000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
        //             sleep 5
        //             sh "curl -f http://localhost:5001 || exit 1"
        //             sh "docker stop test-flask"
        //         }
        //     }
        // }
    }

    post {
        always {
            cleanWs()
        }
    }
}