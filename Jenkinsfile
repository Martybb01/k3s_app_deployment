pipeline {
    agent any
    environment {
        REGISTRY = 'localhost:5000'
        IMAGE_NAME = 'flask-app'
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
            - name: registry-config
              mountPath: /kaniko/.docker
            - name: vagrant-host
              mountPath: /vagrant
          volumes:
          - name: registry-config
            configMap:
              name: registry-config
          - name: vagrant-host
            hostPath:
              path: /vagrant
              type: Directory
          restartPolicy: Never
    """                   
                        writeFile file: 'kaniko-job.yaml', text: kanikoJob
                        
                        sh 'kubectl apply -f kaniko-job.yaml'
                        
                        sh 'kubectl wait --for=condition=complete job/kaniko-build-${BUILD_NUMBER} --timeout=300s'
                        
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
                            sed -i 's|image: .*|image: ${IMAGE_FULL}|g' app_deploy.yaml
                            
                            kubectl apply -f app_deploy.yaml
                            
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