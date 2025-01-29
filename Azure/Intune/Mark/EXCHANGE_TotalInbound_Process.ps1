try {
    cls
    $Log = "C:\Synanetics\SQL\EXCHANGE_TotalInbound.log"

    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }
    $ProcessTotals = $False
    $ProcessMDM = $False
    $meditech_total_inbound = 0
    $cito_total_outbound = 0
    $cito_total_inbound = 0
    $empty = 0
    $populated = 0
    $MDMCount =0
    $meditech_total_error = 0
    $reader = New-Object System.IO.StreamReader($Log)
    if ($reader -ne $null) {
        while (!$reader.EndOfStream) {
            $input = $reader.ReadLine().Split("`t")

            if ($input[0] -eq "SourceConfigName") {
                "Start Totals"
                $ProcessTotals = $True
            } elseif ($input[0] -eq "RawContent") {
                "Start MDM"
                $ProcessMDM = $True
            } elseif ($input[0] -eq "") {
     
                 $ProcessTotals = $False
        
            } elseif ($ProcessTotals) {
                $source = $input[0]
                $target =   $input[1]
                $messages =  $input[2]
               

                if (($source -eq "MEDITECH.INBOUND.FILE.ED" -or $source -eq "MEDITECH.INBOUND.FILE.INPATIENT") -and ($target -eq "Meditech.Document.Inbound.DocumentConverter")) {
                    $meditech_total_inbound += $messages
                } elseif ($source -eq "CITO.INTERNAL.SQL" -and $target -eq "CITO.INBOUND.DOCUMENTPROCESSOR" ) {
                     $cito_total_inbound += $messages
                } elseif ($target -eq "CITO.OUTBOUND.TCP.HL7.MDM") {
                    $cito_total_outbound += $messages
                } elseif ($source -eq "MEDITECH.DOCUMENT.INBOUND.DOCUMENTCONVERTER" -and $target -eq "ENS.ALERT" ) {
                    $meditech_total_error = $messages
                } else {
                    $source + " -> " + $target + " = " + $messages
                }
            }  elseif ($ProcessMDM) {
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
                  #  $Text = $DateTime+","+$Session + "," + $Document + "," + $PDFProcessed
                   
                 #   $Text
                    #Add-Content -Path $Output $Text
               # }
                $Document = ""
                $PDFSent = $False
                $PDFProcessed = $False
                
            }
            if ($hl7[0] -eq "MSH") {
                $DateTime = $hl7[6]
                $MDMCount++
               
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
            }
        }
    }
    "Messages from Meditech:`t`t`t$meditech_total_inbound"
    "Messages from Cito Database:`t$cito_total_inbound"

    $discrepancy = $meditech_total_inbound - $cito_total_outbound
    "Discrepancy:`t`t`t`t`t$discrepancy"
    "Conversion Errors:`t`t`t`t$meditech_total_error"

    $undefinederrors = $discrepancy - $meditech_total_error
    "Undefined Errors::`t`t`t`t$undefinederrors"

    "____________________________________"



     $total = $populated + $empty 
     "Messages from Cito Database:`t$cito_total_inbound"
     "Total MDM Messages:`t`t`t`t$MDMCount"
     $MDMdiscrepancy = $cito_total_outbound - $MDMCount
     "Discrepancy :`t`t`t`t`t$MDMdiscrepancy"
     "MDM Messages with Empty OBX:`t$empty" 
     "____________________________________"



     

} catch {
    "-----------------------ERROR---------------------------"
    $_
    "-------------------------------------------------------"
} Finally {
    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }
}