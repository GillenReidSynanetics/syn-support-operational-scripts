# Script was originally designed for automatically restarting a service via scheduled tasks - can be adapted for any service


# Define the log file path
$logFilePath = "C:\[foldercreated]\*relevantnamingscheme*.txt"

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logMessage
}

# Log the start of the script
Log-Message "Script started."

# Stop the service
try {
    Stop-Service -Name #servicenamehere -Force -ErrorAction Stop
    Log-Message "Stopped."
} catch {
    Log-Message "Failed: $_"
}

# Start the Service
try {
    Start-Service -Name #servicenamehere -ErrorAction Stop
    Log-Message "Service Started."
} catch {
    Log-Message "Failed: $_"
}

# Log the end of the script
Log-Message "Script completed."