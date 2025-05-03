# Add Docker to PATH
$env:Path += ";D:\Program Files\Docker\Docker\resources\bin"

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install Docker Desktop first."
    exit 1
}

# Check if Docker is running
try {
    docker info > $null 2>&1
} catch {
    Write-Host "Docker is not running. Please start Docker Desktop."
    exit 1
}

# Configure Docker to use D drive
$dockerConfig = @{
    "credsStore" = "wincred"
    "auths" = @{
        "https://index.docker.io/v1/" = @{
            "auth" = "c2FtZWVybXVqYWhpZDpTYW1lZXJANzc3Nw=="
        }
    }
    "HttpHeaders" = @{
        "User-Agent" = "Docker-Client/28.0.4 (windows)"
    }
    "stackOrchestrator" = "swarm"
    "experimental" = $false
    "features" = @{
        "buildkit" = $true
    }
    "data-root" = "D:\docker"
}

# Create Docker config directory if it doesn't exist
$dockerConfigDir = "$env:USERPROFILE\.docker"
if (-not (Test-Path $dockerConfigDir)) {
    New-Item -ItemType Directory -Path $dockerConfigDir | Out-Null
}

# Save Docker configuration
$dockerConfig | ConvertTo-Json | Set-Content "$dockerConfigDir\config.json"

# Configure Docker credential helper
$credHelperPath = "D:\Program Files\Docker\Docker\resources\bin\docker-credential-wincred.exe"
if (Test-Path $credHelperPath) {
    $env:DOCKER_CREDENTIAL_HELPER = "wincred"
}

Write-Host "Docker setup completed successfully!" 