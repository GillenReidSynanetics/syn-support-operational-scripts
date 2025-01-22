<#
.SYNOPSIS
    Script to gather Docker inventory information and save it to a CSV file.

.DESCRIPTION
    This script checks if Docker is installed and then gathers information about Docker containers, images, networks, and volumes.
    The collected data is saved to a CSV file specified by the $outputFile variable.

.PARAMETER $outputFile
    The path to the CSV file where the Docker inventory data will be saved.

.FUNCTION Test-Docker
    Checks if Docker is installed on the system. If Docker is not installed, it writes an error message and exits the script.

.FUNCTION get-docker-containers
    Retrieves information about running Docker containers and appends it to the CSV file.

.FUNCTION get-docker-images
    Retrieves information about Docker images and appends it to the CSV file.

.FUNCTION get-docker-networks
    Retrieves information about Docker networks and appends it to the CSV file.

.FUNCTION get-docker-volumes
    Retrieves information about Docker volumes and appends it to the CSV file.

.NOTES
    Author: Gillen Reid
    Date: 2023-10-05
    Version: 1.0

.EXAMPLE
    .\inventory-dev.ps1
    This will run the script and save the Docker inventory information to the specified CSV file.
#>


$outputFile = ".\docker_data.csv"

@("Type,Name,Details") | Set-Content -Path $outputFile

function Test-Docker {
    if (-not(Get-Command "docker" -ErrorAction SilentlyContinue)) {
        Write-Error "Docker not installed"
        exit 1
    }
}

function get-docker-containers {
    docker ps --format "ID={{.ID}},Name={{.Names}},Image={{.Image}},Status={{.Status}},Ports={{.Ports}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation
}


function get-docker-images {
    docker images --format "ID={{.ID}},Repository={{.Repository}},Tag={{.Tag}},Size={{.Size}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation
    
}

function get-docker-networks {
    docker network ls --format "ID={{.ID}},Name={{.Name}},Driver={{.Driver}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation
    
}


function get-docker-volumes {
    docker volume ls --format "Name={{.Name}},Driver={{.Driver}},Scope={{.Scope}}" | ConvertFrom-Csv | Export-Csv -Path $outputFile -Append -NoTypeInformation

}

Write-Host "Inventory saved to $outputFile"