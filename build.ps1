#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

# Get component data and set necessary variables
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Get buildnumber from github actions
if ($env:GITHUB_RUN_NUMBER -ne $null) {
    $component.build = $env:GITHUB_RUN_NUMBER
    Set-Content -Path "component.json" -Value $($component | ConvertTo-Json)
}

$buildImage="$($component.registry)/$($component.name):$($component.version)-$($component.build)-build"
$container=$component.name

# Remove build files
if (Test-Path "obj") {
    Remove-Item -Recurse -Force -Path "obj"
}

# Copy private keys to access git repo
if (-not (Test-Path -Path "docker/id_rsa")) {
    if ($env:GIT_PRIVATE_KEY -ne $null) {
        Set-Content -Path "docker/id_rsa" -Value $env:GIT_PRIVATE_KEY
    } else {
        Copy-Item -Path "~/.ssh/id_rsa" -Destination "docker"
    }
}

# Copy .npmrc to docker folder to use it inside container
if (Test-Path -Path "~/.npmrc") {
    Write-Host "Putting ~/.npmrc to docker folder..."
    Copy-Item -Path "~/.npmrc" -Destination "docker" 
} else {
    Write-Host "Missing ~/.npmrc file..."
    Set-Content -Path "docker/.npmrc" -Value ""
}

# Build docker image
docker build -f docker/Dockerfile.build -t $buildImage .

# Create and copy compiled files, then destroy
docker create --name $container $buildImage
docker cp "$($container):/app/obj" ./obj
docker rm $container

# Verify that obj folder created after build
if (!(Test-Path ./obj)) {
    Write-Host "obj folder doesn't exist in root dir. Build failed. Watch logs above."
    exit 1
}
