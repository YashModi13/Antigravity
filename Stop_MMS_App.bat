@echo off
SETLOCAL EnableExtensions

echo ==========================================
echo       Stopping MMS Full Application
echo ==========================================
echo.

echo [1/2] Closing Backend Window...
REM Terminates the cmd window titled "MMS Backend - Spring Boot" and its child processes (java.exe)
taskkill /F /FI "WINDOWTITLE eq MMS Backend - Spring Boot" /T 2>nul
if %ERRORLEVEL% EQU 0 (
    echo    - Backend stopped successfully (Window Closed).
) else (
    echo    - Backend window not found or already closed.
)

echo.
echo [2/2] Closing Frontend Window...
REM Terminates the cmd window titled "MMS Frontend - Angular" and its child processes (node.exe)
taskkill /F /FI "WINDOWTITLE eq MMS Frontend - Angular" /T 2>nul
if %ERRORLEVEL% EQU 0 (
    echo    - Frontend stopped successfully (Window Closed).
) else (
    echo    - Frontend window not found or already closed.
)

echo.
echo ==========================================
echo Attempting to cleanup lingering processes...
echo ==========================================
REM Optional: Force kill java/node if purely running as background tasks (Uncomment if needed, but risky for other apps)
REM taskkill /F /IM java.exe /T 2>nul
REM taskkill /F /IM node.exe /T 2>nul

echo.
echo Shutdown Complete.
pause
