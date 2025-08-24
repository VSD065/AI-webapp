pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ai-webapp"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        ECR_URI = "533267035494.dkr.ecr.ap-south-1.amazonaws.com/ai-webapp"
        AWS_REGION = "ap-south-1"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                mkdir -p reports
                pytest -v --maxfail=1 --disable-warnings --junitxml=reports/test-results.xml
                '''
                junit 'reports/test-results.xml'
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Login to AWS ECR
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
                    docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
                    docker push ${ECR_URI}:${IMAGE_TAG}
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
