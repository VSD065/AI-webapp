pipeline {
    agent any

    tools {
        python "Python3"   // configure Python in Jenkins Global Tool Config
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
                    python -m pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
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
