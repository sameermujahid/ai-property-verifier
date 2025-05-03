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
                        echo Start Time: %TIME%
                        
                        :: Add Docker to PATH
                        set PATH=%PATH%;D:\\Program Files\\Docker\\Docker\\resources\\bin
                        
                        :: Check if Docker is running
                        echo Checking Docker status...
                        docker info > nul 2>&1
                        if errorlevel 1 (
                            echo Docker is not running. Starting Docker Desktop...
                            start "" "D:\\Program Files\\Docker\\Docker\\Docker Desktop.exe"
                            timeout /t 30 /nobreak
                        )
                        
                        :: Clean up Docker resources
                        echo Cleaning up Docker resources...
                        docker system prune -f
                        
                        :: Set Docker context to default
                        echo Setting Docker context...
                        docker context use default
                        
                        :: Verify Docker is working
                        echo Verifying Docker setup...
                        docker info
                        echo End Time: %TIME%
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
                        echo Start Time: %TIME%
                        "D:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" build --no-cache --rm -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                        echo End Time: %TIME%
                    '''
                }
            }
        }
        
        // stage('Test') {
        //     steps {
        //         script {
        //             echo "Running tests..."
        //             bat '''
        //                 @echo off
        //                 echo === Running Tests ===
        //                 echo Start Time: %TIME%
        //                 "D:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" run --rm %DOCKER_IMAGE%:%DOCKER_TAG% python -m pytest test_app.py -v
        //                 echo End Time: %TIME%
        //             '''
        //         }
        //     }
        // }
        
        stage('Push') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                            bat '''
                                @echo off
                                echo === Pushing Docker Image ===
                                echo Start Time: %TIME%
                                
                                :: Verify Docker is still running
                                docker info > nul 2>&1
                                if errorlevel 1 (
                                    echo Docker is not running. Restarting Docker Desktop...
                                    start "" "D:\\Program Files\\Docker\\Docker\\Docker Desktop.exe"
                                    timeout /t 30 /nobreak
                                )
                                
                                :: Login to Docker Hub
                                echo Logging in to Docker Hub...
                                "D:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" login -u %DOCKER_USERNAME% -p %DOCKER_PASSWORD%
                                if errorlevel 1 (
                                    echo Failed to login to Docker Hub
                                    exit /b 1
                                )
                                
                                :: Tag and push images
                                echo Tagging images...
                                "D:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest
                                
                                echo Pushing images...
                                "D:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" push %DOCKER_IMAGE%:%DOCKER_TAG%
                                "D:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" push %DOCKER_IMAGE%:latest
                                
                                echo End Time: %TIME%
                            '''
                        }
                    } catch (Exception e) {
                        echo "Error during Docker Hub push: ${e.message}"
                        echo "Please ensure Docker Hub credentials are properly configured in Jenkins"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                expression { currentBuild.result == 'SUCCESS' || currentBuild.result == 'UNSTABLE' }
            }
            steps {
                script {
                    echo "Deploying to Kubernetes..."
                    bat '''
                        @echo off
                        echo === Deploying to Kubernetes ===
                        echo Start Time: %TIME%
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        echo End Time: %TIME%
                    '''
                }
            }
        }
    }
    
    post {
        always {
            bat '''
                @echo off
                echo === Cleaning up Docker resources ===
                :: Verify Docker is still running before cleanup
                docker info > nul 2>&1
                if not errorlevel 1 (
                    "D:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" system prune -f
                )
            '''
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        unstable {
            echo 'Pipeline completed with warnings!'
        }
    }
}
