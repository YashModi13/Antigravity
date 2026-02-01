@echo off
SETLOCAL EnableExtensions

echo ==========================================
echo       Starting MMS Full Application
echo ==========================================

REM Get the directory where the batch file is located
cd /d "%~dp0"

echo.
echo [1/2] Launching Backend Server...
if exist "MMS\Backend" (
    cd MMS\Backend
    start "MMS Backend - Spring Boot" cmd /k "mvn spring-boot:run"
) else (
    echo ERROR: MMS\Backend directory not found!
    pause
    exit /b
)

echo.
echo [2/2] Launching Frontend Application...
REM Navigate from Backend to Frontend (we are in MMS\Backend)
cd ..\Frontend
if exist "." (
    start "MMS Frontend - Angular" cmd /k "npm start"
) else (
    echo ERROR: MMS\Frontend directory not found!
    pause
    exit /b
)

echo.
echo ==========================================
echo Application startup initiated!
echo - Backend: http://localhost:8080
echo - Frontend: http://localhost:4200
echo ==========================================
echo.
echo You can close this window, but keep the other two windows open.
pause
