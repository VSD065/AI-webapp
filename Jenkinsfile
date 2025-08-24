pipeline {
    agent any   // Any Jenkins node with Docker installed

    environment {
        IMAGE_NAME = "vsd065/ai-webapp"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'git@github.com:VSD065/AI-webapp.git',
                        credentialsId: 'Github2Jenkins'
                    ]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Use commit hash as image tag
                    def commitHash = sh(script: 'git rev-parse HEAD', returnStdout: true).trim().take(6)
                    echo "Commit Hash: ${commitHash}"
                    env.IMAGE_TAG = commitHash

                    // Build Docker image from Dockerfile
                    dockerImage = docker.build("${IMAGE_NAME}:${env.IMAGE_TAG}")
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    dockerImage.inside {
                        sh '''
                            mkdir -p reports
                            pytest -v --maxfail=1 --disable-warnings --junitxml=reports/test-results.xml
                        '''
                    }
                }
            }
            post {
                always {
                    junit 'reports/test-results.xml'
                }
            }
        }
    }
}
