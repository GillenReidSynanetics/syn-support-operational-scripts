REM This batch script performs cleanup operations on various system directories and user profiles.
REM It deletes files from the following locations:
REM 
REM 1. Recycle Bin
REM    - C:\$Recycle.Bin\
REM 
REM 2. Windows Temp Directory
REM    - C:\windows\temp\
REM 
REM 3. Windows Update Download Cache
REM    - C:\Windows\SoftwareDistribution\Download
REM 
REM 4. Windows Error Reporting Queue
REM    - C:\ProgramData\Microsoft\Windows\WER\ReportQueue
REM 
REM 5. User Profile Directories
REM    - For each user profile in %SYSTEMDRIVE%\Users\*:
REM      - Recent files
REM      - Cookies
REM      - Local Temp files
REM      - Temporary Internet Files (Windows XP-7)
REM      - Temporary Internet Files (Windows 8-10)
REM      - Internet Explorer Cache Storage
REM      - Internet Explorer Image Storage
REM      - Microsoft Edge Cache
REM      - Google Chrome Cache
REM      - Mozilla Firefox Cache
REM 
REM The script uses the DEL command with /s, /f, and /q options to delete files recursively, forcefully, and quietly.
REM The CLS command is used to clear the screen before starting the cleanup operations.
cd "C:\$Recycle.Bin\"
del *.* /q /s

cd "C:\windows\temp\"
del *.* /q /s

cd "C:\Windows\SoftwareDistribution\Download"
del *.* /q /s

cd "C:\ProgramData\Microsoft\Windows\WER\ReportQueue"
del *.* /q /s

CLS
FOR /d %%P IN ("%SYSTEMDRIVE%\Users\*") DO (
	IF EXIST "%%P\Recent" (
		DEL /s /f /q "%%P\Recent"\*.*
	)
	IF EXIST "%%P\Cookies" (
		DEL /s /f /q "%%P\Cookies"\*.*
	)
	IF EXIST "%%P\AppData\Local\Temp" (
		DEL /s /f /q "%%P\AppData\Local\Temp"\*.*
	)
	:: Temporary Internet Files (Windows XP-7)
	IF EXIST "%%P\Local Settings\Temporary Internet Files" (
		DEL /s /f /q "%%P\Local Settings\Temporary Internet Files"\*.*
	)
	:: Temporary Internet Files (Windows 8-10)
	IF EXIST "%%P\AppData\Microsoft\Windows\INetCache" (
		DEL /s /f /q "%%P\AppData\Microsoft\Windows\INetCache"\*.*
	)
	:: Temporary Internet Files (Windows 8-10)
	IF EXIST "%%P\AppData\Local\Microsoft\Windows\Temporary Internet Files\Low" (
		DEL /s /f /q "%%P\AppData\Local\Microsoft\Windows\Temporary Internet Files\Low"\*.*
	)
	:: Internet Explorer (Cache Storage)
	IF EXIST "%%P\AppData\Local\Microsoft\Internet Explorer\CacheStorage" (
		DEL /s /f /q "%%P\AppData\Local\Microsoft\Internet Explorer\CacheStorage"\*.*
	)
	:: Internet Explorer (Image Storage)
	IF EXIST "%%P\AppData\Local\Microsoft\Internet Explorer\imagestore" (
		DEL /s /f /q "%%P\AppData\Local\Microsoft\Internet Explorer\imagestore"\*.*
	)
	:: Microsoft Edge
	IF EXIST "%%P\AppData\Local\MicrosoftEdge\User\Default" (
		DEL /s /f /q "%%P\AppData\Local\MicrosoftEdge\User\Default"\*.*
	)
	:: Google Chrome
	IF EXIST "%%P\AppData\Local\Google\Chrome\User Data\Default\Cache" (
		DEL /s /f /q "%%P\AppData\Local\Google\Chrome\User Data\Default\Cache"\*.*
	)
	:: Mozilla Firefox
	IF EXIST "%%P\AppData\Local\Mozilla\Firefox\Profiles" (
		FOR /f "delims=" %%D IN ('DIR %%P\AppData\Local\Mozilla\Firefox\Profiles\ /b') DO (
			DEL /s /f /q "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\cache2\entries"\*.*
			DEL /s /f /q "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\cache2\doomed"\*.*
			DEL /s /f /q "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\cache2\entries"\*.*
			DEL /s /f /q "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\jumpListCache"\*.*
			DEL /s /f /q "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\OfflineCache"\*.*
			DEL /s /f /q "%%P\AppData\Local\Mozilla\Firefox\Profiles\%%D\thumbnails"\*.*
		)
	)
)