pipeline {
    agent any
    
    stages {
        stage('Compile') {
            steps {
                script {
                    echo 'Running Compile Job'
                    build job: 'big_industry_compile', wait: true
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo 'Running Test Job'
                    build job: 'big_industry_testing', wait: true
                }
            }
        }
        
        stage('Package') {
            steps {
                script {
                    echo 'Running Package Job'
                    build job: 'big_industry_packing', wait: true
                }
            }
        }
    }
    
    post {
        always {
            echo 'All jobs have completed'
        }
    }
}