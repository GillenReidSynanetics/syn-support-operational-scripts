# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# App name to detect
$AppName = "(APP-NAME-GOES-HERE)"

# Check for installed applications matching the name
$appExists = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -like "*$AppName*" }

if ($appExists) {
    # App found, return exit code 0 for Intune to recognize as "installed"
    Write-Host "Application '$AppName' found."
    exit 0 
} else {
    # App not found, return exit code 1 for Intune to recognize as "not installed"
    Write-Host "Application '$AppName' not found."
    exit 1
}
