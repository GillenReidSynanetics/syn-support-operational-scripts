<#
.SYNOPSIS
  Creates a backup of existing certificates and Docker environment files.

.DESCRIPTION
  This script sets the execution policy to RemoteSigned, creates a timestamped backup folder, 
  and copies the .env file, docker-compose.yml file, and the 'jwt' and 'ssl' directories 
  into the backup folder.

.PARAMETER None
  This script does not take any parameters.

.OUTPUTS
  None

.NOTES
  The script creates a backup folder with a timestamp in its name and copies the specified files 
  and directories into it. The backup folder is located in the same directory as the script.

.EXAMPLE
  To run the script, execute the following command in PowerShell:
  .\replication-script.ps1

  This will create a backup folder and copy the necessary files and directories into it.

#>


Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

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