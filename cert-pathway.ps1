# The script will read the local .env file for the certificate pathways and test the local folder structure to ensure they cross match against whats in the .env file.


$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path 
$envFilePath = Join-Path -Path $scriptDirectory -ChildPath ".env"

if (-not (Test-Path -Path $envFilePath)) {

    Write-Error "File not found $envFilePath"
    exit 1
}

$envVariables = Get-Content $envFilePath | Where-Object { $_ -match "=" }

$potentialPaths = @()

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

if ($potentialPaths.Count -eq 0) {
    Write-Host "No file paths found in the .env file."
    exit 0
}

foreach ($path in $potentialPaths) {
    $exists = Test-Path -Path $path.Value
    if ($exists) {
        Write-Host "Path for '$($path.Key)' exists: $($path.Value)"
    } else {
        Write-Warning "Path for '$($path.Key)' does NOT exist: $($path.Value)"
    }
}