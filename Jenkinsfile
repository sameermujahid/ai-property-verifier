pipeline {
    agent {
        label 'windows'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        retry(3)
        disableConcurrentBuilds()
    }
    
    environment {
        DOCKER_IMAGE = 'sameermujahid/ai-property-verifier'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PYTHON_VERSION = '3.9.22'
        FLASK_VERSION = '2.0.1'
        WERKZEUG_VERSION = '2.0.1'
        DOCKER_REGISTRY = 'https://index.docker.io/v1/'
    }
    
    stages {
        stage('Pre-Check') {
            steps {
                script {
                    echo "=== Pre-Check Stage ==="
                    bat '''
                        @echo off
                        echo Checking system requirements...
                        where docker >nul 2>&1
                        if %ERRORLEVEL% neq 0 (
                            echo ERROR: Docker not found in PATH
                            exit /b 1
                        )
                        
                        echo Checking Docker daemon...
                        docker info >nul 2>&1
                        if %ERRORLEVEL% neq 0 (
                            echo ERROR: Docker daemon not running
                            exit /b 1
                        )
                        
                        echo Checking available disk space...
                        for /f "tokens=3" %%a in ('dir /s /a /-c C:\\ 2^>nul ^| find "bytes free"') do set FREE=%%a
                        if %FREE% LSS 1073741824 (
                            echo ERROR: Less than 1GB free disk space
                            exit /b 1
                        )
                    '''
                }
            }
        }
        
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/sameermujahid/ai-property-verifier.git',
                        credentialsId: 'github-credentials'
                    ]],
                    extensions: [
                        [$class: 'CleanBeforeCheckout'],
                        [$class: 'CloneOption', depth: 1, noTags: false, reference: '', shallow: true]
                    ]
                ])
            }
        }
        
        stage('Setup Docker') {
            steps {
                script {
                    echo "=== Docker Setup Stage ==="
                    bat '''
                        @echo off
                        setlocal EnableDelayedExpansion
                        
                        :: Create secure Docker config
                        echo Creating Docker configuration...
                        mkdir "%USERPROFILE%\\.docker" 2>nul
                        
                        :: Generate secure Docker config with credentials
                        echo { > "%USERPROFILE%\\.docker\\config.json"
                        echo     "auths": { >> "%USERPROFILE%\\.docker\\config.json"
                        echo         "%DOCKER_REGISTRY%": { >> "%USERPROFILE%\\.docker\\config.json"
                        echo             "auth": "c2FtZWVybXVqYWhpZDpTYW1lZXJANzc3Nw==" >> "%USERPROFILE%\\.docker\\config.json"
                        echo         } >> "%USERPROFILE%\\.docker\\config.json"
                        echo     }, >> "%USERPROFILE%\\.docker\\config.json"
                        echo     "credsStore": "wincred" >> "%USERPROFILE%\\.docker\\config.json"
                        echo } >> "%USERPROFILE%\\.docker\\config.json"
                        
                        :: Set Docker context
                        docker context use desktop-linux
                        
                        :: Clean up Docker resources
                        echo Cleaning up Docker resources...
                        docker system prune -f --volumes --all
                        docker builder prune -f --all
                        
                        :: Verify Docker setup
                        echo Verifying Docker setup...
                        docker info
                        if %ERRORLEVEL% neq 0 (
                            echo ERROR: Docker setup verification failed
                            exit /b 1
                        )
                    '''
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "=== Build Stage ==="
                    bat '''
                        @echo off
                        setlocal EnableDelayedExpansion
                        
                        :: Build with security scanning
                        echo Building Docker image with security scanning...
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" build ^
                            --no-cache ^
                            --build-arg PYTHON_VERSION=%PYTHON_VERSION% ^
                            --build-arg FLASK_VERSION=%FLASK_VERSION% ^
                            --build-arg WERKZEUG_VERSION=%WERKZEUG_VERSION% ^
                            --security-opt=no-new-privileges ^
                            --label "org.opencontainers.image.created=%DATE% %TIME%" ^
                            --label "org.opencontainers.image.revision=%BUILD_NUMBER%" ^
                            --label "org.opencontainers.image.version=%DOCKER_TAG%" ^
                            -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                        
                        :: Verify image
                        echo Verifying built image...
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" inspect %DOCKER_IMAGE%:%DOCKER_TAG%
                        if %ERRORLEVEL% neq 0 (
                            echo ERROR: Image verification failed
                            exit /b 1
                        )
                    '''
                }
            }
        }
        
        stage('Verify Dependencies') {
            steps {
                script {
                    echo "=== Dependency Verification Stage ==="
                    bat '''
                        @echo off
                        echo Verifying Python and package versions...
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" run --rm %DOCKER_IMAGE%:%DOCKER_TAG% python -c ^
                            "import sys; print(f'Python version: {sys.version}'); ^
                            import flask; print(f'Flask version: {flask.__version__}'); ^
                            import werkzeug; print(f'Werkzeug version: {werkzeug.__version__}'); ^
                            import pip; print('\\nInstalled packages:'); ^
                            [print(f'{pkg.key}=={pkg.version}') for pkg in pip.get_installed_distributions()]"
                    '''
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    echo "=== Security Scanning Stage ==="
                    bat '''
                        @echo off
                        echo Running security scan...
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" scan %DOCKER_IMAGE%:%DOCKER_TAG%
                    '''
                }
            }
        }
        
        stage('Run Application') {
            steps {
                script {
                    echo "=== Application Run Stage ==="
                    bat '''
                        @echo off
                        echo Starting application...
                        "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" run ^
                            --rm ^
                            -p 8000:8000 ^
                            --name ai-property-verifier-%BUILD_NUMBER% ^
                            --memory=512m ^
                            --cpus=1 ^
                            --health-cmd="curl -f http://localhost:8000/health || exit 1" ^
                            --health-interval=30s ^
                            --health-timeout=10s ^
                            --health-retries=3 ^
                            %DOCKER_IMAGE%:%DOCKER_TAG% python app.py
                    '''
                }
            }
        }
        
        stage('Push') {
            steps {
                script {
                    echo "=== Push Stage ==="
                    bat '''
                        @echo off
                        echo Tagging and pushing images...
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
                    echo "=== Deployment Stage ==="
                    bat '''
                        @echo off
                        echo Deploying to Kubernetes...
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        echo Waiting for deployment to be ready...
                        kubectl rollout status deployment/ai-property-verifier --timeout=300s
                    '''
                }
            }
        }
    }
    
    post {
        always {
            node('windows') {
                script {
                    echo "=== Cleanup Stage ==="
                    bat '''
                        @echo off
                        echo Cleaning up resources...
                        docker system prune -f --volumes --all
                        docker builder prune -f --all
                    '''
                    cleanWs()
                }
            }
        }
        success {
            node('windows') {
                script {
                    echo "=== Success Notification ==="
                    emailext (
                        subject: "SUCCESS: Pipeline '${env.JOB_NAME}' [${env.BUILD_NUMBER}]",
                        body: """Pipeline completed successfully!
                        Job: ${env.JOB_NAME}
                        Build Number: ${env.BUILD_NUMBER}
                        Build URL: ${env.BUILD_URL}
                        """,
                        recipientProviders: [[$class: 'DevelopersRecipientProvider']]
                    )
                }
            }
        }
        failure {
            node('windows') {
                script {
                    echo "=== Failure Analysis ==="
                    bat '''
                        @echo off
                        echo Collecting debug information...
                        docker images
                        docker ps -a
                        docker logs ai-property-verifier-%BUILD_NUMBER% 2>&1
                    '''
                    emailext (
                        subject: "FAILED: Pipeline '${env.JOB_NAME}' [${env.BUILD_NUMBER}]",
                        body: """Pipeline failed!
                        Job: ${env.JOB_NAME}
                        Build Number: ${env.BUILD_NUMBER}
                        Build URL: ${env.BUILD_URL}
                        Stage: ${currentBuild.currentResult}
                        """,
                        recipientProviders: [[$class: 'DevelopersRecipientProvider']]
                    )
                }
            }
        }
        unstable {
            echo "Pipeline marked as unstable"
        }
    }
}
