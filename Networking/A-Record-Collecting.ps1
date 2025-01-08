# Function to get A record for a URL
function Get-ARecord {
    param(
        [string]$url
    )
    try {
        $result = Resolve-DnsName -Name $url -Type A -ErrorAction Stop
        $result.IPAddress
    } catch {
        Write-Host "Failed to retrieve A record for $url : $_"
        return $null
    }
}

# Main script
$urls = @(
    "example.com",
    "google.com",
    "openai.com"
    # Add more URLs as needed
)

$results = @()

foreach ($url in $urls) {
    $ipAddress = Get-ARecord $url
    if ($ipAddress) {
        $results += "A record for $url : $ipAddress"
    }
}

$results | Out-File -FilePath "dns_results.txt"
Write-Host "Results written to dns_results.txt"
