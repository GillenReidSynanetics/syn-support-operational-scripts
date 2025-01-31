@echo off

echo Running WinSxS Cleanup...
echo.

REM Run DISM with the appropriate cleanup options
Dism.exe /online /Cleanup-Image /StartComponentCleanup

echo.
echo WinSxS Cleanup completed successfully.

pause
