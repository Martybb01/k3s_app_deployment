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

        stage('Test Image') {
            steps {
                script {
                    sh "docker run --rm -d --name test-flask -p 5001:5000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sleep 5
                    sh "curl -f http://localhost:5001 || exit 1"
                    sh "docker stop test-flask"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}