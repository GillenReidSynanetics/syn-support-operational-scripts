<#
.SYNOPSIS
    Merges text content from all .docx files in a specified folder into a single CSV file.

.DESCRIPTION
    This script scans a specified folder for .docx files, extracts their text content, and merges the content into a single CSV file. 
    Each row in the CSV file contains the filename and the extracted content of a .docx file. 
    The script ensures that the output CSV file is created if it does not already exist.

.PARAMETER folderPath
    The path to the folder containing the .docx files to be processed.

.PARAMETER outputCsv
    The path to the output CSV file where the merged content will be saved.

.NOTES
    The script uses the Word COM object to read the content of .docx files. 
    Ensure that Microsoft Word is installed on the system where this script is executed.

.EXAMPLE
    .\merge-script.ps1
    This example runs the script with the default folder path and output CSV file path specified in the script.
#>
$folderPath = "C:\Users\Gillen\Downloads\Obsidian-20250130T161725Z-001\Obsidian"
$outputCsv = "c:\Users\Gillen\OneDrive - synanetics.com\Merged.csv"
# Check if the output CSV file exists, if not, create it
if (-Not (Test-Path -Path $outputCsv)) {
    New-Item -ItemType File -Path $outputCsv -Force
}

# Initialize an empty array to store data
$notes = @()

# Loop through each .docx file in the folder
$word = New-Object -ComObject Word.Application
$word.Visible = $false

foreach ($file in Get-ChildItem -Path $folderPath -Filter *.docx) {
    try {
        $doc = $word.Documents.Open($file.FullName)
        if ($null -ne $doc) {
            $text = $doc.Content.Text -replace "`r`n"," "  # Remove line breaks to make it CSV-friendly
            $doc.Close()
        } else {
            Write-Host "Error processing document: The file appears to be corrupted."
            continue
        }
        $doc.Close()
    } catch {
        Write-Host "Error processing document: $($_.Exception.Message)"
        continue
    }
    # Store filename and extracted content
    $notes += [PSCustomObject]@{
        Filename = $file.Name
        Content  = $text
    }
}

# Quit Word
$word.Quit()

# Export to CSV
$notes | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Data saved to $outputCsv"