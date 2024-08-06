pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-id')
        GITHUB_CREDENTIALS = credentials('github-token')
        SNYK_API = credentials('snyk-api')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-token',
                    url: 'https://github.com/ilkymn/node-user.git'
            }
        }
        stage('Code Scan') {
            steps {
                script {
                    try {
                        snykSecurity(
                            organization: 'ilkymn',
                            projectName: 'node-user',
                            snykInstallation: 'Snyk', // Snyk'in doğru şekilde yüklendiğinden emin ol
                            snykTokenId: 'snyk-api' // Bu ID'nin Jenkins'te doğru şekilde tanımlandığından emin ol
                        )
                    } catch (Exception e) {
                        echo "Snyk taraması başarısız oldu: ${e.getMessage()}"
                    }
                }
            }
        }




        stage('Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-id', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh 'docker login -u $DOCKERHUB_USER -p $DOCKERHUB_PASS'
                    sh 'docker build -t ilkemymn/node-expres:latest .'
                }
            }
        }

        stage('Image Scan and Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-id', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                        docker.withRegistry('https://index.docker.io/v1/', 'docker-id') {
                            sh 'docker push ilkemymn/node-expres:latest'
                        }
                    }
                    sh 'grype ilkemymn/node-expres:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
            }
        }

        stage('Test') {
            steps {
                sh 'npm start &'
                sh 'sleep 10'
                sh 'node selenium-test.js'
            }
        }
    }

    post {
        always {
            echo 'I will always run'
        }
    }
}