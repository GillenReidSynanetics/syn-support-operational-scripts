<#
    Script Name: Backup Script for Configuration Files and Certificates
    Author: Gillen Reid

    Description:
    This script creates a timestamped backup folder in the same directory as the script.
    It replicates the following items:
      - The `.env` file
      - The `docker-compose.yml` file
      - The entire contents of the `jwt` folder
      - The entire contents of the `ssl` folder

    The files and folders are copied to a new folder named "BackupFolder <timestamp>",
    where <timestamp> is the current date and time in "yyyyMMdd_HHmmss" format.

    Usage:
    Run this script in a PowerShell environment. Ensure it has access to the files
    and folders you want to back up. The resulting backup folder will be created
    in the same directory as the script.

    Notes:
    - Existing backup folders are not overwritten.
    - Ensure you have sufficient permissions to read the source files and write
      to the destination folder.

#>


$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$backupFolder = Join-Path -Path $scriptPath -ChildPath "BackupFolder $timestamp"

New-Item -ItemType Directory -Path $backupFolder -Force

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath '.env' ) -destination $backupFolder

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'docker-compose.yml' ) -destination $backupFolder

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'jwt' ) -destination $backupFolder -Recurse

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'ssl' ) -destination $backupFolder -Recurse

Write-Host "Backup of Existing Certificates complete and docker .env and compose file, inspect in $backupFolder"

# Tested Locally and Verified as working