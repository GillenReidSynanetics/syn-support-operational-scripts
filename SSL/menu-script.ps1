<#
.SYNOPSIS
    A PowerShell script to display a menu and execute various operational tasks such as backup, validation, testing connections, and rebooting containers.

.DESCRIPTION
    This script provides a menu-driven interface to perform the following tasks:
    1. Backup important files and directories.
    2. Validate environment variables and backup files.
    3. Test endpoint connections. (Not tested yet)
    4. Reboot Docker containers. 
    5. Exit the script.

.PARAMETERS
    None.

.NOTES
    - The script sets the execution policy to bypass for the current process.
    - The script uses the `Read-Host` cmdlet to capture user input and execute the corresponding task.
    - The script performs file operations such as copying and validating files, and interacting with Docker containers.

.EXAMPLE
    To run the script, execute the following command in PowerShell:
    ```powershell
    .\menu-script.ps1
    ```

    Follow the on-screen instructions to select an option from the menu and perform the desired task.

#>
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Main menu display function
$mainmenu = {
    Write-Host "***************"
    Write-Host "* Menu *"
    Write-Host
    Write-Host "1. Backup Script"  # Option to run the backup script
    Write-Host "2. Validation Script"  # Option to run the validation script
    Write-Host "3. Test Connections (Not Tested Yet)"  # Option to test endpoint connections (Not tested yet)
    Write-Host "4. Reboot Container (Not tested yet)"  # Option to reboot the container
    Write-Host "5. Exit"  # Option to exit the script
    Write-Host "Select option and press enter"
}
& $mainmenu  # Display the menu

# Read user input and execute the corresponding script
switch (Read-Host) {
    1 {
        Write-Host "Running Backup Script..."

        # Get the script's directory path
        $scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

        # Generate a timestamp for the backup folder
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

        # Define the backup folder path
        $backupFolder = Join-Path -Path $scriptPath -ChildPath "BackupFolder $timestamp"

        # Create the backup folder with error handling
        try {
            New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
            Write-Host "Backup folder created at: $backupFolder"
        } catch {
            Write-Error "Failed to create backup folder: $backupFolder. Error: $_"
            exit 1
        }

        # Copy important files to the backup folder
        if (Test-Path -Path (Join-Path -Path $scriptPath -ChildPath '.env')) {
            Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath '.env') -Destination $backupFolder
        } else {
            Write-Warning "No .env file found in the script directory."
        }
        if (Test-Path -Path (Join-Path -Path $scriptPath -ChildPath 'docker-compose.yml')) {
            Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'docker-compose.yml') -Destination $backupFolder
        } else {
            Write-Warning "No docker-compose.yml file found in the script directory."
        }
        
        if (Test-Path -Path (Join-Path -Path $scriptPath -ChildPath 'jwt')) {
            Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'jwt') -Destination $backupFolder -Recurse
        } else {
            Write-Warning "No jwt directory found in the script directory."
        }
        
        if (Test-Path -Path (Join-Path -Path $scriptPath -ChildPath 'ssl')) {
            Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'ssl') -Destination $backupFolder -Recurse
        } else {
            Write-Warning "No ssl directory found in the script directory."
        }
        # Notify the user of backup completion
        Write-Host "Backup of existing certificates, docker .env, and compose file complete. Inspect in $backupFolder"
    }
    2 {
        Write-Host "Running Validation Script..."

        # Get the directory where the script is located
        $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

        # Define file paths for .env, backups, and report.json
        $envFilePath = Join-Path -Path $scriptDirectory -ChildPath ".env"
        $backupDirectory = Join-Path -Path $scriptDirectory -ChildPath "backups"
        $dateSuffix = Get-Date -Format "yyyyMMdd_HHmmss"
        $reportFilePath = Join-Path -Path $scriptDirectory -ChildPath "report.json"

        # Check if .env file exists
        if (-not (Test-Path -Path $envFilePath)) {
            Write-Error "The .env file does not exist in the script directory."
            exit 1
        }

        # Check if backup directory exists, if not create it
        if (-not (Test-Path -Path $backupDirectory)) {
            try {
            New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
            Write-Host "Created backup directory: $backupDirectory"
            } catch {
            Write-Error "Failed to create backup directory: $backupDirectory. Error: $_"
            exit 1
            }
        }

        $report = @()  # Initialize an empty report array

        # Check if the .env file exists
        if (-not (Test-Path -Path $envFilePath)) {
            Write-Error "File not found: $envFilePath"
            exit 1
        }

        # Read and filter environment variables containing '='
        $envVariables = Get-Content $envFilePath | Where-Object { $_ -match "=" }

        $potentialPaths = @()  # Initialize an array for file paths

        # Extract file paths from the environment variables
        foreach ($line in $envVariables) {
            if ($line -match "=(file://|/.+|\\.+)") {
                $key, $value = $line -split "=", 2
                $value = $value.Trim('"', "'")
                $potentialPaths += [PSCustomObject]@{
                    Key   = $key
                    Value = $value -replace "file://", ""
                }
            }
        }

        # Check if no file paths were found
        if ($potentialPaths.Count -eq 0) {
            Write-Host "No file paths found in the .env file."
            exit 0
        }

        # Validate each file path and perform backups
        foreach ($path in $potentialPaths) {
            $exists = Test-Path -Path $path.Value
            if ($exists) {
                Write-Host "Path for '$($path.Key)' exists: $($path.Value)"

                # Backup the file
                $backupSubDirectory = Join-Path -Path $backupDirectory -ChildPath (Split-Path -Parent $path.Value)
                $backupFilePath = Join-Path -Path $backupSubDirectory -ChildPath ("$(Split-Path $path.Value -Leaf)-$dateSuffix")

                # Create backup directory if it doesn't exist
                if (-not (Test-Path -Path $backupSubDirectory)) {
                    New-Item -ItemType Directory -Path $backupSubDirectory | Out-Null
                    Write-Host "Created backup subdirectory: $backupSubDirectory"
                }

                # Copy the file to the backup directory
                Copy-Item -Path $path.Value -Destination $backupFilePath -Force
                Write-Host "Replicated '$($path.Value)' to '$backupFilePath'"

                # Validate file types (e.g., .pem, .crt, .key)
                $extension = [System.IO.Path]::GetExtension($path.Value).ToLower()
                try {
                    switch ($extension) {
                        ".pem" {
                            # Validate .pem certificate expiration
                            $certContent = Get-Content -Path $path.Value -Raw
                            $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                            $cert.Import([System.Text.Encoding]::UTF8.GetBytes($certContent))
                            $expirationDate = $cert.NotAfter
                            $now = Get-Date
                            Write-Host "Certificate '$($path.Key)' expires on: $expirationDate"
                            if ($expirationDate -lt $now) {
                                Write-Warning "Certificate '$($path.Key)' is expired!"
                            } elseif ($expirationDate -le $now.AddDays(60)) {
                                Write-Warning "Certificate '$($path.Key)' is expiring in 60 days!"
                            } else {
                                Write-Host "Certificate '$($path.Key)' validated and is valid." -ForegroundColor Green
                            }
                        }
                        ".crt" {
                            # Similar validation for .crt certificates
                        }
                        ".key" {
                            Write-Host "Skipping private key '$($path.Value)' as it does not have an expiry date."
                        }
                        default {
                            Write-Host "File type not explicitly validated: $($path.Value)"
                        }
                    }
                } catch {
                    Write-Warning "Failed to validate file '$($path.Value)'. Error: $_"
                }
            } else {
                Write-Warning "Path for '$($path.Key)' does NOT exist: $($path.Value)"
            }
        }

        # Export the validation report to a JSON file
        $report | ConvertTo-Json -Depth 2 | Set-Content -Path $reportFilePath
        Write-Host "Report exported to $reportFilePath"

        Write-Host "Task complete - Please press enter to close"
        Read-Host
    }
#     3 {
#         Write-Host "Testing End Points"
#         $fhirstoreheartbeat = @("")  # Define FHIR endpoints here

#         foreach ($store in $fhirstoreheartbeat) {
#             try {
#                 $response = Invoke-RestMethod -Uri "$store/metadata" -Method Get
#                 Write-Output "Connecting"
#             } catch {
#                 Write-Error "Not Connecting"
#             }
#         }
#     }
# 4 {
    # Write-Host "Rebooting Container"
    # $scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

    # # Prompt the user to enter the Docker Compose project name or directory
    # $ProjectDir = Read-Host "Enter the path to the Docker Compose project directory"
    
    # # Validate the user input
    # if (-not (Test-Path $ProjectDir)) {
    #     Write-Host "The specified directory does not exist. Exiting the script." -ForegroundColor Red
    #     exit
    # }
    
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
    # (No action needed as the script will exit after this point)
}
5 {
        Write-Host "Exiting..."
        exit
    }
    default {
        Write-Host "Invalid option. Please select 1, 2, 3, or 4."
    }
}

