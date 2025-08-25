pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "533267035494.dkr.ecr.ap-south-1.amazonaws.com/ai-webapp"
        IMAGE_TAG = "${BUILD_NUMBER}"
        K8S_DEPLOYMENT = "ai-webapp"   // name of your Deployment in EKS
        K8S_NAMESPACE = "default"      // change if you use another namespace
        CLUSTER_NAME = "your-eks-cluster-name" // <-- update this
    }

    stages {
        stage('Build Builder Image') {
            steps {
                script {
                    builderImage = docker.build("ai-webapp-builder:${BUILD_NUMBER}", "--target builder .")
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
                    runtimeImage = docker.build("ai-webapp:${BUILD_NUMBER}", ".")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh """
                      aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                      docker tag ai-webapp:${BUILD_NUMBER} ${ECR_REPO}:${BUILD_NUMBER}
                      docker tag ai-webapp:${BUILD_NUMBER} ${ECR_REPO}:latest
                      docker push ${ECR_REPO}:${BUILD_NUMBER}
                      docker push ${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                      # Update kubeconfig to point to your EKS cluster
                      aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

                      # Patch the Kubernetes deployment to use the new image
                      kubectl set image deployment/${K8S_DEPLOYMENT} \
                        ${K8S_DEPLOYMENT}=${ECR_REPO}:${IMAGE_TAG} \
                        --namespace=${K8S_NAMESPACE}

                      # Optionally wait until rollout finishes
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
