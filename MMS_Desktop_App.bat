@echo off
setlocal EnableDelayedExpansion

REM ========================================================
REM   Jay Laxmi Jewellers Dhiran System - Desktop Launcher
REM ========================================================
title Jay Laxmi Jewellers Dhiran System

REM 1. Set paths
set "ROOT_DIR=%~dp0"
set "BACKEND_DIR=%ROOT_DIR%MMS\Backend"
set "FRONTEND_DIR=%ROOT_DIR%MMS\Frontend"
set "CHROME_USER_DATA=%TEMP%\MMS_App_Profile"

echo.
echo ------------------------------------------------------------
echo    Dhiran System is starting...
echo    Please do not close this window.
echo ------------------------------------------------------------
echo.

REM 2. Cleanup existing processes to avoid port conflicts
echo [1/5] Checking for existing instances...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8081" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| find ":4200" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1

REM 3. Start Backend
echo [2/5] Starting Backend Server...
start "MMS_Backend_Service" /MIN cmd /c "cd /d "%BACKEND_DIR%" && mvn spring-boot:run"

REM 4. Start Frontend
echo [3/5] Starting Frontend Server...
start "MMS_Frontend_Service" /MIN cmd /c "cd /d "%FRONTEND_DIR%" && npm start"

REM 5. Polling for readiness (more graceful than hard timeout)
echo [4/5] Waiting for services to become ready...
set "MAX_RETRIES=60"
set "COUNT=0"
set "BACKEND_READY=0"
set "FRONTEND_READY=0"

:poll_loop
set /a COUNT+=1
if !COUNT! GTR !MAX_RETRIES! (
    echo.
    echo [ERROR] Services reached timeout. Please check if ports 8081 and 4200 are available.
    pause
    exit /b
)

REM Check Backend
netstat -an | find ":8081" | find "LISTENING" >nul
if !ERRORLEVEL! EQU 0 set "BACKEND_READY=1"

REM Check Frontend
netstat -an | find ":4200" | find "LISTENING" >nul
if !ERRORLEVEL! EQU 0 set "FRONTEND_READY=1"

if !BACKEND_READY! EQU 1 (
    if !FRONTEND_READY! EQU 1 (
        goto services_up
    )
)

<nul set /p "=."
timeout /t 2 /nobreak >nul
goto poll_loop

:services_up
echo.
echo [OK] All services are online.

REM 6. Launch Chrome in App Mode (Full Screen presentation)
echo [5/5] Launching Desktop Application...
echo.
echo ------------------------------------------------------------
echo    SYSTEM ACTIVE
echo    To shutdown the system, simply close the Chrome window.
echo ------------------------------------------------------------
echo.

REM --app: Hides toolbar and tabs for a desktop app feel
REM --start-maximized: Opens in full size
REM --user-data-dir: Uses a clean local profile
start /wait chrome --app=http://localhost:4200 --start-maximized --user-data-dir="%CHROME_USER_DATA%" --no-first-run --no-default-browser-check

REM 7. Graceful Shutdown on Chrome exit
echo.
echo ------------------------------------------------------------
echo    Gracefully shutting down services...
echo ------------------------------------------------------------

REM Kill by window title
taskkill /F /FI "WINDOWTITLE eq MMS_Backend_Service*" /T >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq MMS_Frontend_Service*" /T >nul 2>&1

REM Fail-safe: Kill by Port
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8081" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| find ":4200" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1

REM Cleanup profile data
rmdir /s /q "%CHROME_USER_DATA%" >nul 2>&1

echo.
echo System shutdown complete.
timeout /t 2 >nul
exit
