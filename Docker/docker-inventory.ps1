<#
.SYNOPSIS
    This script collects and exports Docker inventory data to a CSV file.

.DESCRIPTION
    The script checks if Docker is installed and then retrieves information about Docker containers, images, networks, and volumes.
    The collected data is exported to a specified CSV file.

.PARAMETER outputFile
    The path to the output CSV file. Default is ".\docker_data.csv".

.FUNCTION Test-Docker
    Checks if Docker is installed on the system. If not, it writes an error message and exits the script.

.FUNCTION get-docker-containers
    Retrieves information about Docker containers and appends it to the output CSV file.

.FUNCTION get-docker-images
    Retrieves information about Docker images and appends it to the output CSV file.

.FUNCTION get-docker-networks
    Retrieves information about Docker networks and appends it to the output CSV file.

.FUNCTION get-docker-volumes
    Retrieves information about Docker volumes and appends it to the output CSV file.

.EXAMPLE
    .\inventory-dev.ps1
    Runs the script and saves the Docker inventory data to the default CSV file ".\docker_data.csv".

.EXAMPLE
    .\inventory-dev.ps1 -outputFile "C:\path\to\output.csv"
    Runs the script and saves the Docker inventory data to the specified CSV file "C:\path\to\output.csv".    
#>


param (
    [string]$outputFile = ".\docker_data.csv"
)

if (-not (Test-Path $outputFile)) {
    @("Type,Name,Details") | Set-Content -Path $outputFile
}

function Test-Docker {
    if (-not(Get-Command "docker" -ErrorAction SilentlyContinue)) {
        Write-Error "Docker not installed"
        exit 1
    }
}

function get-docker-containers {
    try {
        docker ps --format "ID={{.ID}},Name={{.Names}},Image={{.Image}},Status={{.Status}},Ports={{.Ports}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation -Force
    } catch {
        Write-Error "Failed to retrieve Docker containers: $_"
    }
}

function get-docker-images {
    try {
        docker images --format "ID={{.ID}},Repository={{.Repository}},Tag={{.Tag}},Size={{.Size}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation -Force
    } catch {
        Write-Error "Failed to retrieve Docker images: $_"
    }
}

function get-docker-networks {
    try {
        docker network ls --format "ID={{.ID}},Name={{.Name}},Driver={{.Driver}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation -Force
    } catch {
        Write-Error "Failed to retrieve Docker networks: $_"
    }
}

function get-docker-volumes {
    try {
        docker volume ls --format "Name={{.Name}},Driver={{.Driver}},Scope={{.Scope}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation -Force
    } catch {
        Write-Error "Failed to retrieve Docker volumes: $_"
    }
}

Test-Docker
get-docker-containers
get-docker-images
get-docker-networks
get-docker-volumes

Write-Host "Inventory saved to $outputFile"