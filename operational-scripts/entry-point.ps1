
param (
    [string]$entryPoint = "entry-point.ps1"
)

$entryPoint = "/operational-scripts/entry-point.ps1"

if (Test-Path $entryPoint) {
    Write-Host "Running Deployment"
    . $entryPoint
} else {
    Write-Host "Start Up Script Not Found"
}

