$SQLFiles = @("C:\Synanetics\SQL\RTGXCHAlerts.log", "C:\Synanetics\SQL\RTGXCHAlerts_Unsupported.log")

Try {
    cls
    ForEach ($SQLFile in $SQLFiles) {
        if (Test-Path -Path $SQLFile) {
            Remove-Item $SQLFile
        }  else {
             $SQLFile + " does not exist"
        }
    }
} Catch {
    $_
} Finally {


}