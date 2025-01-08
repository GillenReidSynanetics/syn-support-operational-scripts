# Script runs a system clean up performing core clean up tasks.

param (
    [string]$LogFilePath = "C:\Temp\CleanupLog.txt"
)

$logDir = Split-Path -Path $LogFilePath -Parent
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

function LogMessage {
    param (
        [string]$Message
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogLine = "$Timestamp - $Message"
    $LogLine | Out-File -FilePath $LogFilePath -Append
}

function DeleteFiles {
    param (
        [string]$Path
    )

    if (Test-Path $Path) {
        try {
            Get-ChildItem $Path -Recurse | Remove-Item -Force -ErrorAction Stop
            LogMessage "Deleted files from $Path"
        }
        catch {
            LogMessage "Error deleting files from $Path - $_"
        }
    }
    else {
        LogMessage "Path not found: $Path"
    }
}

function DeleteUserProfileFiles {
    $UserProfilePaths = Get-ChildItem "$env:SystemDrive\Users" -Directory
    foreach ($UserProfilePath in $UserProfilePaths) {
        $ProfilePath = $UserProfilePath.FullName

        # Clear Recent folder
        DeleteFiles "$ProfilePath\Recent"

        # Clear Cookies folder
        DeleteFiles "$ProfilePath\Cookies"

        # Clear Temp folder
        DeleteFiles "$ProfilePath\AppData\Local\Temp"

        # Clear Temporary Internet Files (Windows XP-7)
        DeleteFiles "$ProfilePath\Local Settings\Temporary Internet Files"

        # Clear Temporary Internet Files (Windows 8-10)
        DeleteFiles "$ProfilePath\AppData\Microsoft\Windows\INetCache"

        # Clear Temporary Internet Files (Windows 8-10 Low)
        DeleteFiles "$ProfilePath\AppData\Local\Microsoft\Windows\Temporary Internet Files\Low"

        # Clear Internet Explorer Cache Storage
        DeleteFiles "$ProfilePath\AppData\Local\Microsoft\Internet Explorer\CacheStorage"

        # Clear Internet Explorer Image Storage
        DeleteFiles "$ProfilePath\AppData\Local\Microsoft\Internet Explorer\imagestore"

        # Clear Microsoft Edge
        DeleteFiles "$ProfilePath\AppData\Local\MicrosoftEdge\User\Default"

        # Clear Google Chrome
        DeleteFiles "$ProfilePath\AppData\Local\Google\Chrome\User Data\Default\Cache"

        # Clear Mozilla Firefox
        $FirefoxProfiles = Get-ChildItem "$ProfilePath\AppData\Local\Mozilla\Firefox\Profiles" -Directory
        foreach ($FirefoxProfile in $FirefoxProfiles) {
            $FirefoxProfilePath = $FirefoxProfile.FullName
            DeleteFiles "$FirefoxProfilePath\cache2\entries"
            DeleteFiles "$FirefoxProfilePath\cache2\doomed"
            DeleteFiles "$FirefoxProfilePath\cache2\entries"
            DeleteFiles "$FirefoxProfilePath\jumpListCache"
            DeleteFiles "$FirefoxProfilePath\OfflineCache"
            DeleteFiles "$FirefoxProfilePath\thumbnails"
        }
    }
}

try {
    # Clear Recycle Bin
    $RecycleBinPath = "C:\$Recycle.Bin"
    DeleteFiles $RecycleBinPath

    # Clear Windows Temp folder
    $WindowsTempPath = "C:\Windows\Temp"
    DeleteFiles $WindowsTempPath

    # Clear Windows Update Download folder
    $WindowsUpdatePath = "C:\Windows\SoftwareDistribution\Download"
    DeleteFiles $WindowsUpdatePath

    # Clear Windows Error Reporting folder
    $WERPath = "C:\ProgramData\Microsoft\Windows\WER\ReportQueue"
    DeleteFiles $WERPath

    # Clear user profile files
    DeleteUserProfileFiles

    # Final log message
    LogMessage "Cleanup completed."
}
catch {
    LogMessage "Error during cleanup: $_"
}

Write-Host "System Clean up Complete"
Read-Host "Press enter to close, logs in $logFilePath"
