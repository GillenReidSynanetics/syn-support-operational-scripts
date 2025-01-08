# IP-Scanner Script

function Test-ConnectionRange {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Starting IP address")]
        [System.Net.IPAddress]$StartIP,

        [Parameter(Mandatory = $true, HelpMessage = "Ending IP address")]
        [System.Net.IPAddress]$EndIP,

        [Parameter(Mandatory = $false, HelpMessage = "Timeout in milliseconds (default: 500)")]
        [int]$Timeout = 500
    )

    $IPAddresses = @()
    $CurrentIP = $StartIP

    while ($CurrentIP -le $EndIP) {
        $IPAddresses += $CurrentIP.ToString()
        $CurrentIP = [System.Net.IPAddress]([System.Net.IPAddress]$CurrentIP).GetAddressBytes()
        $CurrentIP[3]++
        $CurrentIP = [System.Net.IPAddress]$CurrentIP
    }

    $Results = Test-Connection -ComputerName $IPAddresses -Count 1 -ErrorAction SilentlyContinue -Timeout $Timeout

    $ActiveHosts = $Results | Where-Object { $_.StatusCode -eq 0 } | Select-Object -ExpandProperty Address

    if ($ActiveHosts.Count -gt 0) {
        Write-Host "Active Hosts:"
        $ActiveHosts | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "No active hosts found in the specified range."
    }
}

# Get user input for the IP address range
$StartIP = Read-Host -Prompt "Enter the starting IP address"
$EndIP = Read-Host -Prompt "Enter the ending IP address"

# Optional: Get user input for the timeout value (in milliseconds)
$Timeout = Read-Host -Prompt "Enter the timeout value in milliseconds (default: 500, press Enter to use default)"

if ($Timeout -eq "") {
    $Timeout = 500 # Use default timeout if the user presses Enter
}

Test-ConnectionRange -StartIP $StartIP -EndIP $EndIP -Timeout $Timeout