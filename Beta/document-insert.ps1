<#
.SYNOPSIS
    This script reads a CSV file and inserts data into a SQL table.

.DESCRIPTION
    The script reads a CSV file located at "C:\Trusts\RWW\Additional Docs\MDM-Document-Summary.csv".
    For each line in the CSV file, it checks if the first column is "Y".
    If so, it extracts various fields from the CSV line and constructs an SQL INSERT statement to insert the data into the "RWWXCH_Document_Table_Local.DocumentConfiguration" table.

.PARAMETERS
    None

.NOTES
    The script assumes the CSV file has the following columns:
    - Column 0: Indicator (Y/N)
    - Column 3: DocumentName
    - Column 5: CareSetting
    - Column 6: DocumentGroup
    - Column 7: DocumentType
    - Column 9: GP Indicator (Y/N)
    - Column 10: DocumentSNOMEDCTCode
    - Column 11: Fraxinus Indicator (Y/N)
    - Column 13: Email Indicator (Y/N)

    The script uses the current date and time for the DateAdded field in the SQL table.
    The DocumentRuleSet is hardcoded to "S".
    The Letter field is hardcoded to 0.

.EXAMPLE
    To run the script, simply execute it in a PowerShell session:
    .\document-insert.ps1
.AUTHOR
    Mark Bain

#>
try {
    cls

    $csv = "C:\Trusts\RWW\Additional Docs\MDM-Document-Summary.csv"

    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }

    $reader = New-Object System.IO.StreamReader($csv)
    if ($reader -ne $null) {
        while (!$reader.EndOfStream) {
            $linecount++
            $line = $reader.ReadLine()
            $input = $line.Split(",")
            if ($input[0] -eq "Y") {

                $CareSetting = $input[5]
                $DocumentGroup = $input[6]
                $DocumentName = $input[3]
                $DocumentRuleSet = "S" #Don't know where this comes from
                $DocumentType = $input[7]
                
                if ($input[13] -eq "Y") {$Email = "1"}
                else  {$Email = "0"}

                if ($input[11] -eq "Y") {$Fraxinus = "1"}
                else  {$Fraxinus = "0"}

                if ($input[9] -eq "Y") {$GP = "1"}
                else  {$GP = "0"}

                $Letter = 0 #Don't know where this comes from


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