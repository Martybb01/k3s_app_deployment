pipeline {
    agent any
    environment {
        REGISTRY = 'docker.io'
        IMAGE_NAME = 'marboccu/flask-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        IMAGE_FULL = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build with Kaniko Job') {
            steps {
                script {
                        def kanikoJob = """
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: kaniko-build-${BUILD_NUMBER}
      namespace: jenkins
    spec:
      template:
        spec:
          serviceAccountName: jenkins
          containers:
          - name: kaniko
            image: gcr.io/kaniko-project/executor:latest
            args:
            - --context=dir:///vagrant/flask-app
            - --dockerfile=Dockerfile
            - --destination=${IMAGE_FULL}
            - --insecure
            - --skip-tls-verify
            - --cleanup
            volumeMounts:
            - name: kaniko-docker-config
              mountPath: /kaniko/.docker
            - name: vagrant-host
              mountPath: /vagrant
          volumes:
          - name: kaniko-docker-config
            configMap:
              name: kaniko-docker-config
          - name: vagrant-host
            hostPath:
              path: /vagrant
              type: Directory
          restartPolicy: Never
    """
                        
                        // Write job to file
                        writeFile file: 'kaniko-job.yaml', text: kanikoJob
                        
                        // Apply the job
                        sh 'kubectl apply -f kaniko-job.yaml'
                        
                        // Wait for completion
                        sh 'kubectl wait --for=condition=complete job/kaniko-build-${BUILD_NUMBER} --timeout=300s'
                        
                        // Cleanup
                        sh 'kubectl delete job kaniko-build-${BUILD_NUMBER}'
                }
            }
        }

        stage('Deploy to K3s') {
            steps {
                script {
                    dir('flask-app') {
                        echo "Deploying Flask app to K3s cluster..."
                        
                        sh """
                            # Sostituisci l'immagine nel file YAML
                            sed -i 's|image: .*|image: ${IMAGE_FULL}|g' app_deploy.yaml
                            
                            # Applica il deployment
                            kubectl apply -f app_deploy.yaml
                            
                            # Attendi che il deployment sia pronto
                            kubectl rollout status deployment/flask-app
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
    }
}