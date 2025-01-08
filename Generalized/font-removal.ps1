# Define the specific font to remove in addition to other fonts
$fontToRemove = "FONTNAMEGOESHERE"
$regpath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

# Function to remove a font by name
function Remove-Font {
    param (
        [string]$fontbasename,
        [string]$fontname,
        [string]$fontvalue
    )

    if (Test-path "C:\Windows\Fonts\$fontname") {
        Write-Host "Removing $fontname..."
        # Remove the font file from the system fonts folder
        Remove-Item "C:\Windows\Fonts\$fontname" -Force -ErrorAction SilentlyContinue

        # Delete the corresponding registry key for the font
        Remove-ItemProperty -Path $regpath -Name $fontvalue -Force -ErrorAction SilentlyContinue

        Write-Host "$fontname has been removed."
    } else {
        Write-Host "$fontname not found in the system fonts folder."
    }
}

# Get all fonts from Fonts Folder
$Fonts = Get-ChildItem "C:\Windows\Fonts"

foreach ($Font in $Fonts) {
    $fontbasename = $Font.basename
    $fontname = $Font.name

    If ($Font.Extension -eq ".ttf") {
        $fontvalue = $Font.Basename + " (TrueType)"
    }
    elseif ($Font.Extension -eq ".otf") {
        $fontvalue = $Font.Basename + " (OpenType)"
    }
    else {
        Write-Host "Font extension not supported" -ForegroundColor Blue -BackgroundColor White
        break
    }

    # Remove each font in the folder
    Remove-Font -fontbasename $fontbasename -fontname $fontname -fontvalue $fontvalue
}

# Now specifically target the "Neusa Next Std Medium" font for removal
$fontToRemoveFiles = Get-ChildItem -Path "C:\Windows\Fonts" | Where-Object { $_.BaseName -eq $fontToRemove }

foreach ($Font in $fontToRemoveFiles) {
    $fontbasename = $Font.basename
    $fontname = $Font.name

    If ($Font.Extension -eq ".ttf") {
        $fontvalue = $Font.Basename + " (TrueType)"
    }
    elseif ($Font.Extension -eq ".otf") {
        $fontvalue = $Font.Basename + " (OpenType)"
    }
    else {
        Write-Host "Font extension not supported" -ForegroundColor Blue -BackgroundColor White
        break
    }

    # Remove the specific "Neusa Next Std Medium" font
    Remove-Font -fontbasename $fontbasename -fontname $fontname -fontvalue $fontvalue
}
