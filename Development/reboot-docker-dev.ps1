<#
.SYNOPSIS
    Script to reboot a Docker Compose project by stopping and removing containers, including orphan containers, and then starting the project again.

.DESCRIPTION
    This script prompts the user to enter the path to a Docker Compose project directory, validates the input, and navigates to the specified directory.
    It then confirms with the user before running the 'docker-compose down --remove-orphans' command to stop and remove the project, including orphan containers.
    If the user confirms, the script executes the Docker Compose down command with the --remove-orphans flag, followed by the Docker Compose up command to start the project again.
    Finally, the script returns to the original location.

.PARAMETER ProjectDir
    The path to the Docker Compose project directory entered by the user.

.NOTES
    - The script requires Docker Compose to be installed and available in the system's PATH.
    - The script should be run with appropriate permissions to manage Docker containers.

.EXAMPLE
    PS> .\reboot-docker.ps1
    Enter the path to the Docker Compose project directory: C:\path\to\project
    Are you sure you want to stop and remove the project, including orphan containers? (yes/no): yes
    Docker Compose project has been stopped, and orphan containers have been removed.
#>
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

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
    docker-compose down --remove-orphans
    docker-compose up -d 

    Write-Host "Docker Compose project has been stopped, and orphan containers have been removed."
} else {
    Write-Host "Operation cancelled by the user. No changes were made." -ForegroundColor Yellow
}

# Return to the original location
Set-Location -Path (Get-Location).Path
