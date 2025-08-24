pipeline {
    agent {
        docker {
            image 'python:3.11'   // Use official Python image
            args '-u root:root'   // Run as root (optional, for installing deps)
        }
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

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    mkdir -p reports
                    pytest -v --maxfail=1 --disable-warnings --junitxml=reports/test-results.xml
                '''
            }
            post {
                always {
                    junit 'reports/test-results.xml'
                }
            }
        }
    }
}
