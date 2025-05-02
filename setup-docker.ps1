# Add Docker to PATH
$env:Path += ";C:\Program Files\Docker\Docker\resources\bin"

# Create Docker config directory
$dockerConfigDir = "$env:USERPROFILE\.docker"
if (-not (Test-Path $dockerConfigDir)) {
    New-Item -ItemType Directory -Path $dockerConfigDir
}

# Create Docker config file
$configContent = @"
{
    "auths": {
        "https://index.docker.io/v1/": {
            "auth": "c2FtZWVybXVqYWhpZDpTYW1lZXJANzc3Nw=="
        }
    }
}
"@
$configContent | Out-File -FilePath "$dockerConfigDir\config.json" -Encoding ASCII

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

# Verify Docker can pull images
docker pull python:3.9-slim 