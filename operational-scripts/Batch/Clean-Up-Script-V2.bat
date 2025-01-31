@echo off

REM --- Additional Cleanup Steps ---

REM Skip Exchange logs cleanup

REM Clean Recycle Bin
cd /d "C:\$Recycle.Bin\"
del /q /s *.* > nul

REM Clean Windows Temp folder
cd /d "C:\windows\temp\"
del /q /s *.* > nul

REM Clean Software Distribution Download folder
cd /d "C:\Windows\SoftwareDistribution\Download"
del /q /s *.* > nul

REM Clean Windows Error Reporting ReportQueue
cd /d "C:\ProgramData\Microsoft\Windows\WER\ReportQueue"
del /q /s *.* > nul

CLS
FOR /D %%P IN ("%SYSTEMDRIVE%\Users\*") DO (
    FOR %%F IN (
        Recent
        Cookies
        AppData\Local\Temp
        "Local Settings\Temporary Internet Files"
        AppData\Microsoft\Windows\INetCache
        "AppData\Local\Microsoft\Windows\Temporary Internet Files\Low"
        "AppData\Local\Microsoft\Internet Explorer\CacheStorage"
        "AppData\Local\Microsoft\Internet Explorer\imagestore"
        "AppData\Local\MicrosoftEdge\User\Default"
        "AppData\Local\Google\Chrome\User Data\Default\Cache"
    ) DO (
        IF EXIST "%%P\%%F" (
            DEL /s /f /q "%%P\%%F\*.*" > nul
        )
    )

    IF EXIST "%%P\AppData\Local\Mozilla\Firefox\Profiles" (
        FOR /f "delims=" %%D IN ('DIR /B "%%P\AppData\Local\Mozilla\Firefox\Profiles\"') DO (
            FOR %%F IN (
                "cache2\entries"
                "cache2\doomed"
                "jumpListCache"
                "OfflineCache"
                "thumbnails"
            ) DO (
                IF EXIST "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\%%F" (
                    DEL /s /f /q "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\%%F\*.*" > nul
                )
            )
        )
    )
)
