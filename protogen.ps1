#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

# Get component data and set necessary variables
$component = Get-Content -Path "component.json" | ConvertFrom-Json
$protosImage="$($component.registry)/$($component.name):$($component.version)-$($component.build)-protos"
$container=$component.name

# Remove documentation files
if (Test-Path "src/protos") {
    Remove-Item -Recurse -Force -Path "src/protos/*.js"
    Remove-Item -Recurse -Force -Path "src/protos/*.ts"
}

# Build docker image
docker build -f docker/Dockerfile.protos -t $protosImage .

# Create and copy compiled files, then destroy
docker create --name $container $protosImage
docker cp "$($container):/app/src/protos" ./src/protos
docker rm $container
