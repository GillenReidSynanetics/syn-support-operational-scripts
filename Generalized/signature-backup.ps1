# Generic script to replicate MS signatures
# Declaring Pathways for both signature and backup folder
# Purpose of this script is to copy sig files to a backup folder, then clearing the folder.



$sFolder = "$env:APPDATA\Microsoft\Signatures"
$sBackupFolder = "$env:APPDATA\Microsoft\SignaturesBackup"

if (!(Test-Path -Path $sBackupFolder)) {
    New-Item -ItemType Directory -Path $sBackupFolder -Force | Out-Null
}


try {
    Get-ChildItem $sFolder -Recurse | ForEach-Object {
        $sourceFile = $_.FullName
        $destFile = Join-Path $sBackupFolder $_.RelativePath
        Write-Host "Copying $sourceFile to $destFile"
        Copy-Item $sourceFile $destFile -Force
    }
    Write-Output "Signature files backed up to $sBackupFolder"
}
catch {
    Write-Warning "Error backing up signature files: $_"
}


try {
    Get-ChildItem -Path $sFolder -Include *.* -Recurse | foreach { $_.Delete() }
    Write-Output "Signature files deleted from $sFolder"
}
catch {
    Write-Warning "Failed to delete signature files: $_"
}
