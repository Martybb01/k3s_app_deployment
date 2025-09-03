pipeline {
    agent any
    environment {
        REGISTRY = 'localhost:5000'
        IMAGE_NAME = 'flask-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        IMAGE_FULL = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        KANIKO_EXECUTOR = '/usr/local/bin/executor'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Container Image with Kaniko') {
            steps {
                script {
                    dir('flask-app') {
                        echo "Building container image with Kaniko..."

                        sh """
                            ${KANIKO_EXECUTOR} \
                                --context=. \
                                --dockerfile=Dockerfile \
                                --destination=${IMAGE_FULL} \
                                --insecure \
                                --skip-tls-verify
                        """
                    }
                }
            }
        }

        stage('Deploy to K3s') {
            steps {
                script {
                    dir('flask-app') {
                        echo "Deploying Flask app to K3s cluster..."
                        
                        sh """
                            kubectl patch deployment flask-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"flask-app","image":"${IMAGE_FULL}"}]}}}}' || \
                            kubectl apply -f app_deploy.yaml
                        """
                    }
                }
            }
        }
    }

    post {
        always {
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