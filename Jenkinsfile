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
                        @echo off
                        echo === Setting up Docker Environment ===
                        
                        :: Add Docker to PATH
                        set PATH=%PATH%;C:\\Program Files\\Docker\\Docker\\resources\\bin
                        
                        :: Create Docker config directory
                        mkdir "%USERPROFILE%\\.docker" 2>nul
                        
                        :: Create Docker config file
                        echo { > "%USERPROFILE%\\.docker\\config.json"
                        echo     "auths": { >> "%USERPROFILE%\\.docker\\config.json"
                        echo         "https://index.docker.io/v1/": { >> "%USERPROFILE%\\.docker\\config.json"
                        echo             "auth": "c2FtZWVybXVqYWhpZDpTYW1lZXJANzc3Nw==" >> "%USERPROFILE%\\.docker\\config.json"
                        echo         } >> "%USERPROFILE%\\.docker\\config.json"
                        echo     } >> "%USERPROFILE%\\.docker\\config.json"
                        echo } >> "%USERPROFILE%\\.docker\\config.json"
                        
                        :: Set Docker context
                        docker context use desktop-linux
                        
                        :: Clean up Docker
                        docker system prune -f
                        
                        :: Test Docker
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
                        @echo off
                        echo === Building Docker Image ===
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" build --no-cache --build-arg FLASK_VERSION=2.0.1 --build-arg WERKZEUG_VERSION=2.0.1 --build-arg PYTHON_VERSION=3.9.22 -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Running application..."
                    bat '''
                        @echo off
                        echo === Running Application ===
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" run --rm %DOCKER_IMAGE%:%DOCKER_TAG% python -c "import flask; import werkzeug; print(f'Flask version: {flask.__version__}'); print(f'Werkzeug version: {werkzeug.__version__}')"
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" run --rm %DOCKER_IMAGE%:%DOCKER_TAG% python app.py
                    '''
                }
            }
        }
        
        stage('Push') {
            steps {
                script {
                    echo "Pushing Docker image..."
                    bat '''
                        @echo off
                        echo === Pushing Docker Image ===
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" push %DOCKER_IMAGE%:%DOCKER_TAG%
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" push %DOCKER_IMAGE%:latest
                    '''
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying to Kubernetes..."
                    bat '''
                        @echo off
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
            script {
                bat '''
                    @echo off
                    echo === Cleaning up Docker ===
                    docker system prune -f
                '''
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
