pipeline {
    agent any

    tools {
        maven 'maven-3.9.9'
    }

    environment {
        DOCKER_CREDENTIALS = 'docker'  // your Docker Hub credentials ID in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                // Update branch to 'main' if that's your default branch
                git branch: 'main',
                    url: 'https://github.com/Kan6380/spring-boot-mongo-docker-kkfunda.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    withSonarQubeEnv('sonarQube') {
                        sh """
                        mvn verify \
                          org.sonarsource.scanner.maven:sonar-maven-plugin:3.10.0.2594:sonar \
                          -Dsonar.projectKey=spring-boot-mongo \
                          -Dsonar.projectName="Spring Boot Mongo Project"
                        """
                    }
                }
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: env.DOCKER_CREDENTIALS) {
                        sh 'docker build --no-cache -t sri6380/mongospring:latest .'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: env.DOCKER_CREDENTIALS) {
                        sh 'docker push sri6380/mongospring:latest'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
