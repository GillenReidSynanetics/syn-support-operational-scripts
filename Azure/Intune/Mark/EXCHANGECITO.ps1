
try {
    #cls
    $SQLResult = "C:\Synanetics\SQL\EXCHANGECITO.log"
    $Output = "C:\Synanetics\Scripts\Output\EXCHANGECITO.csv"
    if (Test-Path -Path $Output) {
    "Clear file"
        Remove-Item $Output
    }
                    

    $empty = 0
    $populated = 0
    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }
    $i = 0
    $sessions = @()
    "Open " + $SQLResult
    $reader = New-Object System.IO.StreamReader($SQLResult)
    if ($reader -ne $null) {
        while (!$reader.EndOfStream) {
            
            $input = $reader.ReadLine().Split("`t")

            if (($input[0] -as [int]) -is [int]) {

                
                $session = $input[0]
                $sessions += $session
                $line = $input[1]
                $i++
               
            } else {
                $line = $input[0]
            }
           

            if ($line -eq $null) {Continue}

            $hl7 = $line.Split("|")


            if (($hl7[0] -eq "MSH" -and $Document -ne "" ) -or ($hl7[0] -eq "" -and $Document -ne "" )) {
               # if (!$PDFProcessed) {
                    $Text = $DateTime+","+$Session + "," + $Document + "," + $PDFProcessed
                   
                    
                    Add-Content -Path $Output $Text
               # }
                $Document = ""
                $PDFSent = $False
                $PDFProcessed = $False
                
            }
            if ($hl7[0] -eq "MSH") {
                $DateTime = $hl7[6]
               
            }

            if  ($hl7[0] -eq "TXA") {
                $Document = $hl7[12]
               
            }
            if  ($hl7[0] -eq "OBX" ) {
                $Fields = $hl7[5].Split("^")
                if ($Fields[2] -eq "PDF" ) {
                    if ($Fields[4] -eq "") {
                        $empty++
                        $PDFProcessed = $False
                     } else {
                        $populated++
                        $PDFProcessed = $True

                     }
                }
            
            }
        <#   #>
        }
         
    } else {
        $SQLResult + " not found"
    }

   

     "Populated: " + $populated
     "Empty: " + $empty 
     $total = $populated + $empty 
     "Total: "+ $total

    
 } Catch {
    "Error"   
     $_
} Finally {
    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }
}