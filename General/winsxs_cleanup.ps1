<#
.SYNOPSIS
    Script to clean up the WinSxS folder and perform system maintenance tasks.

.DESCRIPTION
    This script performs a series of maintenance tasks to clean up the WinSxS folder and other temporary files on a Windows system. 
    It logs all actions to a specified log file and restarts the computer to apply changes.

.PARAMETER logFile
    The path to the log file where all actions will be logged.

.FUNCTIONS
    logmessage
        Logs a message with a timestamp to the log file.

.EXAMPLE
    .\winsxs_cleanup.ps1
    Runs the script to clean up the WinSxS folder and perform system maintenance tasks.

#>
$logFile = "C:\Windows\Logs\winsxs_cleanup.log"

function logmessage {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logentry = "$timestamp - $message"
    Write-Output $logentry | Tee-Object -FilePath $logFile -Append
}

logmessage "Starting winsxs cleanup"
logmessage "Checking current WinSxS size..."
dism /online /cleanup-image /analyzecomponentstore | Tee-Object -FilePath $logFile -Append
logmessage "Running StartComponentCleanup..."
Dism.exe /online /Cleanup-Image /StartComponentCleanup | Tee-Object -FilePath $logFile -Append
logmessage "Running StartComponentCleanup with ResetBase..."
Dism.exe /online /Cleanup-Image /SPSuperseded | Tee-Object -FilePath $logFile -Append
dism /online /cleanup-image /startcomponentcleanup /SPSuperseded | Tee-Object -FilePath $logFile -Append
cleanmgr.exe /sagerun:1 | Tee-Object -FilePath $logFile -Append
logmessage "deleting cbs logs..."
Remove-Item -Path "C:\Windows\Logs\CBS\*" -Force | Tee-Object -FilePath $logFile -Append
Remove-Item -Path "C:\Windows\Temp*" -Force -Recurse | Tee-Object -FilePath $logFile -Append
logmessage "removing unused features"
dism /online /get-features | ForEach-Object {
    if ($_ -match "disabled") {
         $featureName = ($_ -split ": ")[0]
        logmessage "Removing $featureName..."
        dism /online /disable-feature /featurename:$_.FeatureName | Tee-Object -FilePath $logFile -Append
    }
}
# Check WinSxS folder size after cleanup
logmessage "Checking WinSxS size after cleanup..."
Dism /Online /Cleanup-Image /AnalyzeComponentStore | Tee-Object -FilePath $logFile -Append
# Restart computer to apply changes
logmessage "Restarting computer to apply changes..."
logmessage "Checking WinSxS size after cleanup..."
logmessage "Restarting computer to apply changes..."
