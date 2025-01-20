$mainmenu = {
    Write-Host  "***************"
    Write-Host  "* Menu *"
    Write-Host  
    Write-Host  "1. Backup Script"
    Write-Host  "2. Validation Script"
    Write-Host  "3. Exit"
    Write-Host  "Select option and press enter"
    }
    $mainmenu

    switch (Read-Host) {
        1 {
            Write-Host "Running Backup Script..."
$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$backupFolder = Join-Path -Path $scriptPath -ChildPath "BackupFolder $timestamp"

New-Item -ItemType Directory -Path $backupFolder -Force

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath '.env' ) -destination $backupFolder

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'docker-compose.yml' ) -destination $backupFolder

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'jwt' ) -destination $backupFolder -Recurse

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'ssl' ) -destination $backupFolder -Recurse

Write-Host "Backup of Existing Certificates complete and docker .env and compose file, inspect in $backupFolder"
        }
        2 {
            Write-Host "Running Validation Script..."
            $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
            $envFilePath = Join-Path -Path $scriptDirectory -ChildPath ".env"
            $backupDirectory = Join-Path -Path $scriptDirectory -ChildPath "backups"
            $dateSuffix = Get-Date -Format "yyyyMMdd-HHmmss"
            $reportFilePath = Join-Path -Path $scriptDirectory -ChildPath "report.json"
            
            $report = @()
            
            # Reports back confirming it can't find .env
            if (-not (Test-Path -Path $envFilePath)) {
                Write-Error "File not found $envFilePath"
                exit 1
            }
            
            $envVariables = Get-Content $envFilePath | Where-Object { $_ -match "=" }
            
            $potentialPaths = @()
            
            # Checks pathways for all files mentioned in pathways on .env
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
            
            # Reports back it hasn't found any pathways (most likely have the script in the wrong location)
            if ($potentialPaths.Count -eq 0) {
                Write-Host "No file paths found in the .env file."
                exit 0
            }
            
            # Reporting back on results.
            foreach ($path in $potentialPaths) {
                $exists = Test-Path -Path $path.Value
                if ($exists) {
                    Write-Host "Path for '$($path.Key)' exists: $($path.Value)"
            
                    # Replication before validation
                    $backupSubDirectory = Join-Path -Path $backupDirectory -ChildPath (Split-Path -Parent $path.Value)
                    $backupFilePath = Join-Path -Path $backupSubDirectory -ChildPath ("$(Split-Path $path.Value -Leaf)-$dateSuffix")
            
                    # Create backup directory
                    if (-not (Test-Path -Path $backupSubDirectory)) {
                        New-Item -ItemType Directory -Path $backupSubDirectory | Out-Null
                        Write-Host "Created backup SubDirectory $backupSubdirectory"
                    }
                    
                    # Copy files to backup directory
                    Copy-Item -Path $path.Value -Destination $backupFilePath -Force
                    Write-Host "Replicated '$($path.Value)' to '$backupFilePath'"
            
            
                    # File extension validation (dev)
                    $extension = [System.IO.Path]::GetExtension($path.Value).ToLower()
                    try {
                        switch ($extension) {
                            ".pem" {
                                # Validate .pem certificate expiry dates
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
                                # Validate .crt certificate expiry dates
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
                            ".key" {
                                Write-Host "Skipping private key '$($path.Value)' as it does not have an expiry date."
                            }
                            default {
                                Write-Host "File type not explicitly validated: $($path.Value)"
                            }
                        } # End switch
                    } catch {
                        Write-Warning "Failed to validate file '$($path.Value)'. Error: $_"
                    }
                } else {
                    Write-Warning "Path for '$($path.Key)' does NOT exist: $($path.Value)"
                }
            } # End foreach
            
            $report | ConvertTo-Json -Depth 2 | Set-Content -Path $reportFilePath
            Write-Host "Report Exported to $reportFilePath"
            
            Write-Host "Task complete - Please press enter to close"
            Read-Host
        }
        3 {
            Write-Host "Exiting..."
            exit
        }
        default {
            Write-Host "Invalid option. Please select 1, 2, or 3."
        }
    }


