pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-id')
        GITHUB_CREDENTIALS = credentials('github-token')
           GOOGLE_CREDENTIALS = credentials('node-services-account')
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
                            snykInstallation: 'Snyk', // Snyk'in doğru şekilde yüklendiğinden emin ol
                            snykTokenId: 'snyk-api-token' // Bu ID'nin Jenkins'te doğru şekilde tanımlandığından emin ol
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
                    
                    sh '. /etc/profile'
                    sh 'docker build -t ilkemymn/node-expres:latest -f Dockerfile .'
                    
                }
            }
        }

        stage('Image Scan and Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-id', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                        docker.withRegistry('https://index.docker.io/v1/', 'docker-id') {
                            sh '. /etc/profile'
                            sh 'docker push ilkemymn/node-expres:latest'
                           
                        }
                    }
                   // sh 'cd /var/lib/jenkins/workspace/node-user@tmp'
                    sh 'rm -rf ~/.cache/grype'
                    sh 'grype ilkemymn/node-expres:latest'
                }
            }
        }

       stage('Deploy to test cluster') {
            steps {
                // GKE kümesine dağıtım yapın
                script {
                    
                    sh 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" '
                   
                    sh "gcloud auth activate-service-account --key-file=$vernal-segment-430514-t2"
                    sh "gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project vernal-segment-430514-t2"
                    sh 'sed -i "s/latest/${BUILD_NUMBER}/g"  /home/ilkemymn/deployment.yaml'
                    sh 'kubectl apply -f  /home/ilkemymn/deployment.yaml'
                    
                }
            }
        }
    /*
        stage('Test') {
            steps {
                sh 'npm start &'
                sh 'sleep 10'
                sh 'node selenium-test.js'
            }
        }*/
    }


    
}