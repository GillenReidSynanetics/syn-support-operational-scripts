# Prompt the user to enter the Docker Compose project name or directory
$ProjectDir = Read-Host "Enter the path to the Docker Compose project directory"

# Validate the user input
if (-not (Test-Path $ProjectDir)) {
    Write-Host "The specified directory does not exist. Exiting the script." -ForegroundColor Red
    exit
}

# Navigate to the project directory
Set-Location -Path $ProjectDir

# Confirm with the user before running the 'docker compose down --remove-orphans' command
$Confirmation = Read-Host "Are you sure you want to stop and remove the project, including orphan containers? (yes/no)"
if ($Confirmation -eq "yes") {
    # Execute the Docker Compose down command with the --remove-orphans flag
    docker compose down --remove-orphans

    Write-Host "Docker Compose project has been stopped, and orphan containers have been removed."
} else {
    Write-Host "Operation cancelled by the user. No changes were made." -ForegroundColor Yellow
}

# Return to the original location
Set-Location -Path (Get-Location).Path
