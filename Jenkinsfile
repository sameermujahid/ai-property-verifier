pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'sameermujahid/ai-property-verifier'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Docker') {
            steps {
                script {
                    echo "Setting up Docker environment..."
                    bat '''
                        echo === Setting up Docker Environment ===
                        set PATH=%PATH%;C:\\Program Files\\Docker\\Docker\\resources\\bin
                        
                        # Create Docker config directory
                        mkdir "%USERPROFILE%\\.docker" 2>nul
                        
                        # Create Docker config file
                        echo {
                        echo     "auths": {
                        echo         "https://index.docker.io/v1/": {
                        echo             "auth": "c2FtZWVybXVqYWhpZDpTYW1lZXJANzc3Nw=="
                        echo         }
                        echo     }
                        echo } > "%USERPROFILE%\\.docker\\config.json"
                        
                        # Set Docker context
                        docker context use desktop-linux
                        
                        # Test Docker
                        docker info
                    '''
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    bat '''
                        echo === Building Docker Image ===
                        docker build --no-cache --build-arg DOCKER_USERNAME=sameermujahid --build-arg DOCKER_PASSWORD=Sameer@7777 -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Running tests..."
                    bat '''
                        echo === Running Tests ===
                        docker run --rm %DOCKER_IMAGE%:%DOCKER_TAG% python -m pytest test_app.py
                    '''
                }
            }
        }
        
        stage('Push') {
            steps {
                script {
                    echo "Pushing Docker image..."
                    bat '''
                        echo === Pushing Docker Image ===
                        docker tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest
                        docker push %DOCKER_IMAGE%:%DOCKER_TAG%
                        docker push %DOCKER_IMAGE%:latest
                    '''
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying to Kubernetes..."
                    bat '''
                        echo === Deploying to Kubernetes ===
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} 