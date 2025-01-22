<#
.SYNOPSIS
    This script reads a CSV file and generates SQL INSERT statements for document configuration.

.DESCRIPTION
    The script prompts the user to enter the path to a CSV file containing document configuration data.
    It reads the CSV file line by line, processes each line, and generates SQL INSERT statements for 
    the RWWXCH_Document_Table_Local.DocumentConfiguration table based on the data in the CSV file.

.PARAMETER csv
    The path to the CSV file containing document configuration data.

.NOTES
    The script sets the execution policy to Bypass for the current process to allow script execution.
    It uses a StreamReader to read the CSV file and processes each line to generate SQL INSERT statements.
    The generated SQL statements are displayed in the console.

.EXAMPLE
    PS> .\document-insert.ps1
    Enter the path to the CSV file -eg C:\Trusts\RWW\Additional Docs\MDM-Document-Summary.csv: C:\path\to\your\file.csv
    SQL Statements:
    INSERT INTO RWWXCH_Document_Table_Local.DocumentConfiguration (CareSetting, DateAdded, DocumentGroup, DocumentName, DocumentRuleSet, DocumentType, Email, Fraxinus, GP, Letter, Share2Care, SourceApplication, DocumentSNOMEDCTCode) VALUES ('CareSettingValue', GETDATE(), 'DocumentGroupValue', 'DocumentNameValue', 'A', 'DocumentTypeValue', 1, 0, 1, 0, 1, 'SourceApplicationValue', 'DocumentSNOMEDCTCodeValue')

#>

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

try {
    cls

    $csv = (Read-Host -Prompt "Enter the path to the CSV file -eg C:\Trusts\RWW\Additional Docs\MDM-Document-Summary.csv").Trim('"')


    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }

    $reader = New-Object System.IO.StreamReader($csv)
    if ($reader -ne $null) {
        $sqlStatements = @()
        $linecount = 0

        while (!$reader.EndOfStream) {
            $linecount++
            $line = $reader.ReadLine()
            $input = $line.Split(",")
            if ($input[0] -eq "Y") {

                $CareSetting = $input[5]
                $DocumentGroup = $input[6]
                $DocumentName = $input[3]
                $DocumentRuleSet = "A" # Hard coded to A for now, understanding of document rule set required
                $DocumentType = $input[7]
                
                if ($input[13] -eq "Y") {$Email = "1"}
                else  {$Email = "0"}

                if ($input[11] -eq "Y") {$Fraxinus = "1"}
                else  {$Fraxinus = "0"}

                if ($input[9] -eq "Y") {$GP = "1"}
                else  {$GP = "0"}

                $Letter = 0 # From the document logic it appears this is set to wether the patient has to get a letter or not?


                $DocumentSNOMEDCTCode = $input[10]
                if ($DocumentSNOMEDCTCode -eq "") {$Share2Care = "0"}
                else  {$Share2Care = "1"}


                $SourceApplication = $input[7]

                
                $sql = "INSERT INTO RWWXCH_Document_Table_Local.DocumentConfiguration "
                $sql = $sql + "(CareSetting, DateAdded, DocumentGroup, DocumentName, DocumentRuleSet, DocumentType, Email, Fraxinus, GP, Letter, Share2Care, SourceApplication, DocumentSNOMEDCTCode)"
                $sql = $sql + " VALUES "
                $sql = $sql + "('$CareSetting', GETDATE(), '$DocumentGroup', '$DocumentName', '$DocumentRuleSet', '$DocumentType', $Email, $Fraxinus, $GP, $Letter, $Share2Care, '$SourceApplication', '$DocumentSNOMEDCTCode')"
                $sql
            }
        }

        Write-Host "SQL Statements:" -ForegroundColor Green
        $sqlStatements | ForEach-Object { Write-Host $_ }
    }
  

} Catch {
    "Error at line $linecount"
    $_
} Finally {
    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }

}