<#
.SYNOPSIS
    This script performs a Google Custom Search and exports the results to a CSV file, then commits and pushes the CSV file to a GitHub repository.

.DESCRIPTION
    The script uses Google Custom Search API to search for "EVE Online third-party tools" and retrieves the search results.
    The results are then exported to a CSV file located in the specified local repository path.
    After exporting the results, the script stages the CSV file, commits it with a specified commit message, and pushes the changes to the main branch of the GitHub repository.

.PARAMETER localRepoPath
    The local path where the CSV file will be stored.

.PARAMETER csvFileName
    The name of the CSV file to be created.

.PARAMETER commitMessage
    The commit message to be used when committing the CSV file to the repository.

.PARAMETER apikey
    The API key for accessing the Google Custom Search API.

.PARAMETER cseid
    The Custom Search Engine ID for the Google Custom Search API.

.PARAMETER query
    The search query to be used with the Google Custom Search API.

.PARAMETER apiurl
    The URL for the Google Custom Search API request.

.PARAMETER response
    The response from the Google Custom Search API request.

.PARAMETER data
    The JSON data converted from the API response.

.PARAMETER searchResults
    The collection of search results extracted from the API response.

.PARAMETER csvPath
    The full path to the CSV file to be created.

.EXAMPLE
    .\web-crawler.ps1
    This example runs the script and performs the Google Custom Search, exports the results to a CSV file, and commits and pushes the CSV file to the GitHub repository.

.NOTES
    Ensure that you have the necessary permissions and API keys to access the Google Custom Search API.
    Make sure that Git is installed and configured on your system to commit and push changes to the GitHub repository.
#>


$localRepoPath = 'Beta/web-crawler.js'
$csvFileName = 'Beta/web-crawler.csv'
$commitMessage = 'Beta/web-crawler.js: Added web-crawler.js'

# Google Variables  

$apikey = 'AIzaSyD1J1Q1J1Q1J1Q1J1Q1J1Q1J1Q1J1Q1J1'
$cseid = '012345678901234567890:abcdefghijk'
$query = "EVE Online third-party tools"

$apiurl = "https://www.googleapis.com/customsearch/v1?key=$apikey&cx=$cseid&q=$query";


$response = Invoke-WebRequest -Uri $apiurl -UseBasicParsing;
$data = $response.Content | ConvertFrom-Json;

$searchResults = @();

foreach ($item in $data.items) {
    $searchResults += [PSCustomObject]@{
        title = $item.title
        Link = $item.link
        Snippet = $item.snippet
    }
}

# Export results to CSV
$csvPath = Join-Path -Path $localRepoPath -ChildPath $csvFileName
$searchResults | Export-Csv -Path $csvPath -NoTypeInformation -Force

# Add the CSV file to the repository
git add $csvFileName

# Commit the changes
git commit -m $commitMessage

# Push the changes to GitHub
git push origin main  # Adjust branch name if different