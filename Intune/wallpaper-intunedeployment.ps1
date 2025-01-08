# Relatively simple script to system wide deploy a wall paper for all managed machines - ensure the image you are using remains the same name.
# For example, if you have image1 and want to replace it with image2 - best way to action is to rename imageB to imageA to ensure the image remains effective.
# Backup and over write your AZURE location image storage also.

$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"


$DesktopPath = "DesktopImagePath"
$DesktopStatus = "DesktopImageStatus"
$DesktopUrl = "DesktopImageUrl"

$StatusValue = "1"


$url = "[Location that its stored on the blob storage]"
$DesktopImageValue = "[Actual Image location goes here]"
$directory = "[Directory that the image is in on local machine]"


If ((Test-Path -Path $directory) -eq $false)
{
	New-Item -Path $directory -ItemType directory
}

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $DesktopImageValue)



if (!(Test-Path $RegKeyPath))
{
	Write-Host "Creating registry path $($RegKeyPath)."
	New-Item -Path $RegKeyPath -Force | Out-Null
}


New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null

RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
