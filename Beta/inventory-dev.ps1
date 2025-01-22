# The idea here is a local script to get a read out of the existing docker containers, images, networks and volumes.

$outputFile = ".\docker_data.csv"

@("Type,Name,Details") | Set-Content -Path $outputFile

function Test-Docker {
    if (-not(Get-Command "docker" -ErrorAction SilentlyContinue)) {
        Write-Error "Docker not installed"
        exit 1
    }
}

function get-docker-containers {
    docker ps --format "ID={{.ID}},Name={{.Names}},Image={{.Image}},Status={{.Status}},Ports={{.Ports}}" | ConvertFrom-Csv Export-Csv -Path $outputFile -Append -NoTypeInformation
}


function get-docker-images {
    docker images --format "ID={{.ID}},Repository={{.Repository}},Tag={{.Tag}},Size={{.Size}}" | ConvertFrom-Csv Export-Csv -Path $outputFile -Append -NoTypeInformation
    
}

function get-docker-networks {
    docker network ls --format "ID={{.ID}},Name={{.Name}},Driver={{.Driver}}" | ConvertFrom-Csv Export-Csv -Path $outputFile -Append -NoTypeInformation
    
}


function get-docker-volumes {
    docker volume ls --format "Name={{.Name}},Driver={{.Driver}},Scope={{.Scope}}" | ConvertFrom-Csv Export-Csv -Path $outputFile -Append -NoTypeInformation

}

$outputDirectory = Join-Path -Path $PWD -ChildPath "DockerInventory"
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

Write-Host "Inventory saved to $outputDirectory"