pipeline {
    agent any
    environment {
        CI = 'true'
        GITHUB_API_URL = 'https://api.github.com/repos/samiracho/devopstask'
        SHORT_COMMIT = "${GIT_COMMIT[0..7]}"
    }
    stages {
        stage('Prepare') {
            steps {
                sh 'git config --local credential.helper "!p() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; p"'
            }
        }
        stage('Build') {
            steps {
                sh 'make build-app'
            }
        }
        stage('Test') {
            steps {
                sh 'echo run tests, sonarqube, veracode etc'
            }
        }
        stage('Deploy for development') {
            when {
                branch 'develop' 
            }
            steps {
                sh 'ENV=develop make down-app'
                sh 'ENV=develop TAG=${SHORT_COMMIT} make up-app'
                echo "API available at http://${env.JENKINS_HOSTNAME}:9000/jokes"
            }
        }
        stage('Deploy for staging') {
            when {
                branch 'release'  
            }
            steps {
                sh 'ENV=staging make down-app'
                sh 'ENV=staging TAG=${SHORT_COMMIT} make up-app'
                echo "API available at http://${env.JENKINS_HOSTNAME}:9001/jokes"
            }
        }
        stage('Deploy for production') {
            when {
                branch 'main'  
            }
            steps {
                sh "ENV=production make down-app"
                sh "ENV=production TAG=${SHORT_COMMIT} make up-app"
                sh 'echo API available at http://$JENKINS_HOSTNAME:9002/jokes'

                withCredentials([usernamePassword(credentialsId: 'github-user-password', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh './tag.sh'
                }              
            }
        }
    }
}
