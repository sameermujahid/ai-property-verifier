# Add Docker to PATH
$env:Path += ";C:\Program Files\Docker\Docker\resources\bin"

# Create Docker config directory if it doesn't exist
$dockerConfigDir = "$env:USERPROFILE\.docker"
if (-not (Test-Path $dockerConfigDir)) {
    New-Item -ItemType Directory -Path $dockerConfigDir
}

# Copy config file
Copy-Item -Path ".\config.json" -Destination "$dockerConfigDir\config.json" -Force

# Install Docker credential helper
$credHelperPath = "C:\Program Files\Docker\Docker\resources\bin\docker-credential-wincred.exe"
if (-not (Test-Path $credHelperPath)) {
    Write-Host "Downloading Docker credential helper..."
    Invoke-WebRequest -Uri "https://github.com/docker/docker-credential-helpers/releases/download/v0.7.0/docker-credential-wincred-v0.7.0-amd64.exe" -OutFile $credHelperPath
}

# Set Docker context
docker context use desktop-linux

# Test Docker
docker info
docker login -u sameermujahid -p Sameer@7777 