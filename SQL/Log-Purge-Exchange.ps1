try {
    cls
    $Logs = @(
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound.log"
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound_Unsupported.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound_Unsupported.log"
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound_today.log"
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound_today_Unsupported.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound_today.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound_today_Unsupported.log"
    )

    ForEach ($Log in $Logs) {
        if (Test-Path $Log) {Remove-Item $Log}
    }

} catch {
    "-----------------------ERROR---------------------------"
    $_
    "-------------------------------------------------------"
} Finally {


}