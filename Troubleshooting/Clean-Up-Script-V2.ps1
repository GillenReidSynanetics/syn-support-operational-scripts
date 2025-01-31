# --- Additional Cleanup Steps ---

# Skip Exchange logs cleanup

# Clean Recycle Bin
Remove-Item -Path "C:\$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Windows Temp folder
Remove-Item -Path "C:\windows\temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Software Distribution Download folder
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Windows Error Reporting ReportQueue
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean user-specific folders
$foldersToClean = @(
    "Recent",
    "Cookies",
    "AppData\Local\Temp",
    "Local Settings\Temporary Internet Files",
    "AppData\Microsoft\Windows\INetCache",
    "AppData\Local\Microsoft\Windows\Temporary Internet Files\Low",
    "AppData\Local\Microsoft\Internet Explorer\CacheStorage",
    "AppData\Local\Microsoft\Internet Explorer\imagestore",
    "AppData\Local\MicrosoftEdge\User\Default",
    "AppData\Local\Google\Chrome\User Data\Default\Cache"
)

$firefoxFoldersToClean = @(
    "cache2\entries",
    "cache2\doomed",
    "jumpListCache",
    "OfflineCache",
    "thumbnails"
)

Get-ChildItem -Path "$env:SystemDrive\Users" -Directory | ForEach-Object {
    $userProfile = $_.FullName
    foreach ($folder in $foldersToClean) {
        $path = Join-Path -Path $userProfile -ChildPath $folder
        if (Test-Path -Path $path) {
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    $firefoxProfilePath = Join-Path -Path $userProfile -ChildPath "AppData\Local\Mozilla\Firefox\Profiles"
    if (Test-Path -Path $firefoxProfilePath) {
        Get-ChildItem -Path $firefoxProfilePath -Directory | ForEach-Object {
            $firefoxProfile = $_.FullName
            foreach ($folder in $firefoxFoldersToClean) {
                $path = Join-Path -Path $firefoxProfile -ChildPath $folder
                if (Test-Path -Path $path) {
                    Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
