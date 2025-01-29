<#
.SYNOPSIS
    A simple web crawler script to discover third-party tools, plugins, utilities, and addons from a given starting URL.

.DESCRIPTION
    This script starts crawling from a specified URL and searches for links that match specific keywords such as "tool", "plugin", "utility", or "addon".
    It prevents infinite loops by limiting the crawling depth and tracks visited URLs to avoid duplicate crawling.
    The results are exported to a CSV file.

.PARAMETER startURL
    The initial URL from which the crawling begins. Replace with the desired starting URL.

.PARAMETER maxDepth
    The maximum depth to which the crawler will go to prevent infinite loops. Default is 2.

.PARAMETER visitedUrls
    A hashtable to keep track of visited URLs to avoid duplicate crawling.

.FUNCTION Get-URL
    Crawls a given URL, extracts links, and recursively crawls those links up to the specified depth.
    If a link matches the specified keywords, it is added to the results.

.PARAMETER url
    The URL to be crawled.

.PARAMETER depth
    The current depth of the crawling process.

.EXAMPLE
    .\cawler.ps1
    Starts the crawler from the specified start URL and exports the discovered third-party tools to a CSV file.

.NOTES
    Author: Your Name
    Date: YYYY-MM-DD
    Version: 1.0
#>
# Define the starting URL (seed URL)
$startURL = "https://www.bbc.com/"  # Replace with the desired starting URL

# Maximum depth to prevent infinite loops
$maxDepth = 2

# Track visited URLs to prevent duplicate crawling
$visitedUrls = @{}

# Function to crawl a URL
function Get-URL {
    param (
        [string]$url,
        [int]$depth
    )

    # Skip if the URL has already been visited or depth exceeded
    if ($visitedUrls[$url] -or $depth -gt $maxDepth) {
        return
    }

    # Mark URL as visited
    $visitedUrls[$url] = $true

    Write-Host "Crawling: $url (Depth: $depth)" -ForegroundColor Cyan

    try {
        # Fetch the web page
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop

        # Extract all links on the page
        $links = ($response.Links | Where-Object { $_.href -notmatch "^#" }).href

        foreach ($link in $links) {
            # Resolve relative URLs to absolute URLs
            $absoluteLink = ([uri]::new($url, $link)).AbsoluteUri

            # Filter for potential third-party tools
            if ($absoluteLink -match "tool|plugin|utility|addon") {
                Write-Output [PSCustomObject]@{
                    SourcePage = $url
                    ToolLink   = $absoluteLink
                }
            }

            # Recursively crawl the link (increment depth)
            Crawl-URL -url $absoluteLink -depth ($depth + 1)
        }
    } catch {
        Write-Host "Failed to access: $url" -ForegroundColor Red
    }
}

# Start the crawler
Write-Host "Starting crawler..." -ForegroundColor Green
$result = Get-URL -url $startURL -depth 0

# Export results to CSV
if ($result) {
    $result | Export-Csv -Path "ThirdPartyTools_Discovery.csv" -NoTypeInformation
    Write-Host "Results exported to ThirdPartyTools_Discovery.csv" -ForegroundColor Green
} else {
    Write-Host "No results found." -ForegroundColor Yellow
}
