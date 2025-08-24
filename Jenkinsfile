pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "533267035494.dkr.ecr.ap-south-1.amazonaws.com/ai-webapp"
    }

    stages {
        stage('Build Builder Image') {
            steps {
                script {
                    // Build the builder image for testing
                    builderImage = docker.build("ai-webapp-builder:${BUILD_NUMBER}", "--target builder .")
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    // Run tests inside builder image (pytest is available there)
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
                    // Build slim runtime image (no pytest)
                    runtimeImage = docker.build("ai-webapp:${BUILD_NUMBER}", ".")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}"
                    sh "docker tag ai-webapp:${BUILD_NUMBER} ${ECR_REPO}:${BUILD_NUMBER}"
                    sh "docker tag ai-webapp:${BUILD_NUMBER} ${ECR_REPO}:latest"
                    sh "docker push ${ECR_REPO}:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REPO}:latest"
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
