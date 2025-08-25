pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "533267035494.dkr.ecr.ap-south-1.amazonaws.com/ai-webapp"
        K8S_DEPLOYMENT = "ai-webapp"
        K8S_NAMESPACE = "default"
        CLUSTER_NAME = "AI-webapp-cluster" // replace with your cluster name
    }

    stages {
        stage('Get Commit Hash') {
            steps {
                script {
                    def commitHash = sh(script: 'git rev-parse HEAD', returnStdout: true).trim().take(6)
                    echo "Commit Hash: ${commitHash}"
                    env.IMAGE_TAG = commitHash
                }
            }
        }

        stage('Build Builder Image') {
            steps {
                script {
                    builderImage = docker.build("ai-webapp-builder:${env.IMAGE_TAG}", "--target builder .")
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    builderImage.inside {
                        sh """
                          mkdir -p reports
                          pytest -v --maxfail=1 --disable-warnings --junitxml=reports/test-results.xml
                        """
                    }
                }
            }
            post {
                always {
                    junit 'reports/test-results.xml'
                }
            }
        }

        stage('Build Runtime Image') {
            steps {
                script {
                    runtimeImage = docker.build("ai-webapp:${env.IMAGE_TAG}", ".")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh """
                      aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                      docker tag ai-webapp:${env.IMAGE_TAG} ${ECR_REPO}:${env.IMAGE_TAG}
                      docker push ${ECR_REPO}:${env.IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy Kubernetes Resources') {
            steps {
                script {
                    sh """
                      # Update kubeconfig
                      aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

                      # Apply Kubernetes manifests (first-time creation or updates)
                      kubectl apply -f k8s/deployment.yaml --namespace=${K8S_NAMESPACE}
                      kubectl apply -f k8s/service.yaml --namespace=${K8S_NAMESPACE}
                      #kubectl apply -f k8s/configmap.yaml --namespace=${K8S_NAMESPACE}   # optional
                      #kubectl apply -f k8s/secrets.yaml --namespace=${K8S_NAMESPACE}    # optional

                      # Update only the image for rolling update
                      kubectl set image deployment/${K8S_DEPLOYMENT} ${K8S_DEPLOYMENT}=${ECR_REPO}:${env.IMAGE_TAG} --namespace=${K8S_NAMESPACE}
                      
                      # Wait for rollout to finish
                      kubectl rollout status deployment/${K8S_DEPLOYMENT} --namespace=${K8S_NAMESPACE}
                    """
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
