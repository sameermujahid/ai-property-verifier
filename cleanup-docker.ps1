# Stop all Docker processes
Write-Host "Stopping Docker processes..."
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "com.docker.service" -Force

# Reset WSL
Write-Host "Resetting WSL..."
wsl --shutdown
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# Clean up Docker data
Write-Host "Cleaning up Docker data..."
Remove-Item -Path "D:\docker" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path "D:\docker" -ItemType Directory -Force

# Reset Docker configuration
Write-Host "Resetting Docker configuration..."
$dockerConfigDir = "$env:USERPROFILE\.docker"
if (Test-Path $dockerConfigDir) {
    Remove-Item -Path $dockerConfigDir -Recurse -Force
}
New-Item -Path $dockerConfigDir -ItemType Directory -Force

# Start Docker service
Write-Host "Starting Docker service..."
Start-Service -Name "com.docker.service"
Start-Process "D:\Program Files\Docker\Docker\Docker Desktop.exe"

# Wait for Docker to be ready
Write-Host "Waiting for Docker to be ready..."
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        docker info > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker is ready!"
            break
        }
    } catch {
        # Ignore errors
    }
    $attempt++
    Start-Sleep -Seconds 2
}

if ($attempt -eq $maxAttempts) {
    Write-Host "Docker failed to start within the timeout period"
    exit 1
}

Write-Host "Docker cleanup and reset completed successfully!" 