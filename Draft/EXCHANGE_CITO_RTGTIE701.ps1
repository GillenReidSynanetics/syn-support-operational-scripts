try {
    cls
    $Log = "C:\Synanetics\SQL\EXCHANGE_CITO_RTGTIE701.log"
    $Destination = "C:\Synanetics\Scripts\Files\MTDD"
    $Temp = "C:\Synanetics\Scripts\Temp"

    $Script = "$Temp\Copy.ps1"
    if (Test-Path $Script) {Remove-Item $Script}

    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }
    $reader = New-Object System.IO.StreamReader($Log)
    $readline = $False
    if ($reader -ne $null) {
        while (!$reader.EndOfStream) {
            $input = $reader.ReadLine().Split("`t")
            if ($input[0] -eq "Guid") {
                $readline = $True
            } elseif ($input[0] -like "*Rows(s) Affected") {
                $readline = $False
            } elseif ($readline) {
                if ($input -ne $null) {
                    $pdf = $input[1]
                    $fileRef  = $pdf.Split("_")[0].Split("\")[-1]
                    $pdfExists = Test-Path $pdf
                    if (!$pdfExists) {
                        "$pdf  $pdfExists"

                        $search = "$fileRef*"

                        $Archive = "\\uhdbfs\healthshare\Meditech\Live\Archive\"
                        $FileCount = 0
                        Get-ChildItem  $Archive  | Where-Object {$_.Name -like "$search" } | ForEach {
                            $FileCount++
                            $ArchiveFile = $_.FullName
                        }
                        if ($FileCount -eq 1) {
                       
                            $target = "$Destination\$fileRef"
                            $copyText = "Copy-Item -Path $ArchiveFile -Destination $target"
                            Add-Content -Path $Script $copyText
                        }

                    }
                       
                }
            }

        }
    }

} Catch { 
    $_
} Finally {
    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }

}