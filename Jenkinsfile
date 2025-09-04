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
                    dir('flask-app') { 
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
            - --context=dir://
            - --dockerfile=Dockerfile
            - --destination=${IMAGE_FULL}
            - --insecure
            - --skip-tls-verify
            - --cleanup
            volumeMounts:
            - name: kaniko-docker-config
              mountPath: /kaniko/.docker
            - name: workspace
              mountPath: /workspace
          volumes:
          - name: kaniko-docker-config
            configMap:
              name: kaniko-docker-config
          - name: workspace
            persistentVolumeClaim:
              claimName: jenkins-pvc
          restartPolicy: Never
    """
                        
                        // Write job to file
                        writeFile file: 'kaniko-job.yaml', text: kanikoJob
                        
                        // Apply the job
                        sh 'kubectl apply -f kaniko-job.yaml'
                        
                        // Wait for completion
                        sh 'kubectl wait --for=condition=complete job/kaniko-build-${BUILD_NUMBER} --timeout=300s'
                        
                        // Check logs
                        sh 'kubectl logs job/kaniko-build-${BUILD_NUMBER}'
                        
                        // Cleanup
                        sh 'kubectl delete job kaniko-build-${BUILD_NUMBER}'
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
                            kubectl set image deployment/flask-app flask-app=${IMAGE_FULL}
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

// pipeline {
//     agent any
//     environment {
//         REGISTRY = 'localhost:5000'
//         IMAGE_NAME = 'flask-app'
//         IMAGE_TAG = "${BUILD_NUMBER}"
//         IMAGE_FULL = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
//     }

//     stages {
//         stage('Checkout') {
//             steps {
//                 checkout scm
//             }
//         }

//         stage('Build Container Image with Kaniko') {
//             steps {
//                 script {
//                     // Use Kubernetes plugin to run Kaniko in a separate pod
//                     podTemplate(
//                         yaml: """
// apiVersion: v1
// kind: Pod
// spec:
//   initContainers:
//   - name: busybox-share-init
//     image: busybox:musl
//     command:
//     - sh
//     args:
//     - -c
//     - "cp -a /bin/* /busybox"
//     volumeMounts:
//     - name: busybox
//       mountPath: /busybox
//   containers:
//   - name: kaniko
//     image: gcr.io/kaniko-project/executor:latest
//     command:
//     - sleep
//     args:
//     - infinity
//     env:
//     - name: PATH
//       value: /usr/local/bin:/kaniko:/busybox
//     workingDir: /home/jenkins/agent
//     volumeMounts:
//     - name: busybox
//       mountPath: /busybox
//       readOnly: true
//     - name: kaniko-docker-config
//       mountPath: /kaniko/.docker
//     resources:
//       limits:
//         memory: "1Gi"
//         cpu: "500m"
//       requests:
//         memory: "256Mi"
//         cpu: "100m"
//   volumes:
//   - name: busybox
//     emptyDir: {}
//   - name: kaniko-docker-config
//     configMap:
//       name: kaniko-docker-config
// """
//                     ) {
//                         node(POD_LABEL) {
//                             container('kaniko') {
//                                 dir('flask-app') {
//                                     echo "Building container image with Kaniko..."
                                    
//                                     sh """
//                                         /kaniko/executor \
//                                             --context=. \
//                                             --dockerfile=Dockerfile \
//                                             --destination=${IMAGE_FULL} \
//                                             --insecure \
//                                             --skip-tls-verify \
//                                             --cleanup
//                                     """
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Deploy to K3s') {
//             steps {
//                 script {
//                     dir('flask-app') {
//                         echo "Deploying Flask app to K3s cluster..."
                        
//                         sh """
//                             kubectl patch deployment flask-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"flask-app","image":"${IMAGE_FULL}"}]}}}}' || \
//                             kubectl apply -f app_deploy.yaml
//                         """
//                     }
//                 }
//             }
//         }
//     }

//     post {
//         always {
//             cleanWs()
//         }
//         success {
//             echo "Pipeline completed successfully!"
//             echo "App deployed with image: ${IMAGE_FULL}"
//         }
//         failure {
//             echo "Pipeline failed!"
//         }
//     }
// }