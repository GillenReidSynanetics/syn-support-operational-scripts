<#
.SYNOPSIS
    This script creates firewall rules for Portainer ports and logs the actions.

.DESCRIPTION
    The script defines a set of ports required for Portainer communication and UI access.
    It creates inbound firewall rules for these ports, logs the actions to a specified log file,
    and validates the creation of the firewall rules.

.PARAMETER ports
    An array of hashtables defining the ports, protocols, and names for the firewall rules.

.PARAMETER logFilePath
    The path to the log file where the firewall rule creation details will be recorded.

.NOTES
    Author: GillenReidSynanetics
    FilePath: /GillenReidSynanetics/syn-support-operational-scripts/Beta/portainer-setup.ps1

.EXAMPLE
    .\portainer.ps1
    This will execute the script, create the firewall rules for the defined ports, log the actions,
    and validate the creation of the firewall rules.
#>
# Define the ports to open
$LogFilePath = Split-Path -Path $LogFilePath -Parent

$ports = @(
    @{Port = 8000; Protocol = "TCP"; Name = "Portainer Agent Communication Port (TCP 8000)"},
    @{Port = 9443; Protocol = "TCP"; Name = "Portainer UI Secure Access (TCP 9443)"},
    @{Port = 9001; Protocol = "TCP"; Name = "Portainer Agent Communication (TCP 9001)"}
)

# Loop through each port and create a firewall rule
foreach ($port in $ports) {
    Write-Output "Creating firewall rule for port $($port.Port) ($($port.Name))..."
    New-NetFirewallRule -DisplayName $port.Name `
                         -Direction Inbound `
                         -Protocol $port.Protocol `
                         -LocalPort $port.Port `
                         -Action Allow `
                         -Profile Any
}

# Ensure the log file is created
if (-not (Test-Path -Path $logFilePath)) {
    Write-Output "Creating log file at $logFilePath"
    New-Item -Path $logFilePath -ItemType File -Force
} else {
    Write-Output "Log file already exists at $logFilePath"
}

foreach ($port in $ports) {
    $rule = Get-NetFirewallRule -DisplayName $port.Name 
    if ($null -ne $rule) {
        Write-Output "Validation successful: Firewall rule for port $($port.Port) ($($port.Name)) exists."
    } else {
        Write-Output "Validation failed: Firewall rule for port $($port.Port) ($($port.Name)) does not exist."
    }
}

Write-Output "Portainer firewall rules created for the following ports:"
# Print the list of ports with readable details
foreach ($port in $ports) {
    Write-Output " - Port: $($port.Port), Protocol: $($port.Protocol), Name: $($port.Name)"
}

# Write the log file output
Write-Output "Writing firewall rules to log file: $logFilePath"
foreach ($port in $ports) {
    $logEntry = "Port: $($port.Port), Protocol: $($port.Protocol), Name: $($port.Name)"
    Add-Content -Path $logFilePath -Value $logEntry
}

Write-Output "Log file created at $logFilePath"

Write-Output "Log file updated at $logFilePath"

# Pause the script to allow the user to read the output
Read-Host -Prompt "Press Enter to exit"