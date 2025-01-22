# The idea here is a local script to get a read out of the existing docker containers, images, networks and volumes.


function Test-Docker {
    if (-not(Get-Command "docker" -ErrorAction SilentlyContinue)) {
        Write-Error "Docker not installed"
        exit 1
    }
}

function get-docker-containers {
    docker ps --format "ID={{.ID}},Name={{.Names}},Image={{.Image}},Status={{.Status}},Ports={{.Ports}}" | ConvertFrom-Csv
}


function get-docker-images {
    docker images --format "ID={{.ID}},Repository={{.Repository}},Tag={{.Tag}},Size={{.Size}}" | ConvertFrom-Csv
    
}

function get-docker-networks {
    docker network ls --format "ID={{.ID}},Name={{.Name}},Driver={{.Driver}}" | ConvertFrom-Csv
    
}


function get-docker-volumes {
    docker volume ls --format "Name={{.Name}},Driver={{.Driver}},Scope={{.Scope}}" | ConvertFrom-Csv

}

$outputDirectory = Join-Path -Path $PWD -ChildPath "DockerInventory"
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

get-docker-volumes | Export-Csv -Path (Join-Path -Path $outputDirectory -ChildPath "volumes.csv") -NoTypeInformation
get-docker-networks |  Export-Csv -Path (Join-Path -Path $outputDirectory -ChildPath "networks.csv") -NoTypeInformation
get-docker-images | Export-Csv -Path (Join-Path -Path $outputDirectory -ChildPath "images.csv") -NoTypeInformation
get-docker-containers | Export-Csv -Path (Join-Path -Path $outputDirectory -ChildPath "containers.csv") -NoTypeInformation

Write-Host "Inventory saved to $outputDirectory"