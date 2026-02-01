@echo off
if not "%1" == "min" start /MIN cmd /c %0 min & exit/b
SETLOCAL EnableExtensions

echo ========================================================
echo   Jay Laxmi Jewellers Dhiran System - Desktop Launcher
echo ========================================================
echo.

REM 1. Set paths
set "ROOT_DIR=%~dp0"
set "BACKEND_DIR=%ROOT_DIR%MMS\Backend"
set "FRONTEND_DIR=%ROOT_DIR%MMS\Frontend"
set "CHROME_USER_DATA=%TEMP%\MMS_Chrome_Profile_%RANDOM%"

REM 2. Start Backend (Hidden/Minimized)
echo [1/3] Starting Backend Server...
start "MMS_Backend_Core" /MIN cmd /c "cd /d "%BACKEND_DIR%" && mvn spring-boot:run"

REM 3. Start Frontend (Hidden/Minimized)
echo [2/3] Starting Frontend Server...
start "MMS_Frontend_Core" /MIN cmd /c "cd /d "%FRONTEND_DIR%" && npm start"

REM 4. Wait for servers to warm up (approx 20 seconds)
echo [3/3] Waiting for application to initialize (20s)...
echo       (Window will stay minimized)
timeout /t 20 /nobreak >nul

REM 5. Launch Browser in App Mode and WAIT
REM Using chrome with --app run in a separate profile allows 'start /wait' to work correctly 
start /wait chrome --app=http://localhost:4200 --user-data-dir="%CHROME_USER_DATA%" --no-first-run

REM 6. Cleanup Loop
REM Kill specific window titles silently
taskkill /F /FI "WINDOWTITLE eq MMS_Backend_Core*" /T >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq MMS_Frontend_Core*" /T >nul 2>&1

REM Kill by Port (Double Check - ensures hidden processes die)
REM Backend (8080)
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8080" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1
REM Frontend (4200)
for /f "tokens=5" %%a in ('netstat -aon ^| find ":4200" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1

REM Cleanup Chrome profile
rmdir /s /q "%CHROME_USER_DATA%" >nul 2>&1

exit
