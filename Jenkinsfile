pipeline {
    agent any

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
    }
}

