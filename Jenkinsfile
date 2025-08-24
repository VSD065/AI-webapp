pipeline {
    agent any   // Run on any Jenkins agent with Python/pytest available

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

        stage('Run Unit Tests') {
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
