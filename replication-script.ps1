# Script will replicate the docker compose and .env file and create a backup folder, placing the copied files in that folder.

$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$backupFolder = Join-Path -Path $scriptPath -ChildPath "Replicated-Files $timestamp"

New-Item -ItemType Directory -Path $backupFolder -Force

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath '.env' ) -destination $backupFolder

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'docker-compose.yml' ) -destination $backupFolder


# Tested Locally and Verified as working