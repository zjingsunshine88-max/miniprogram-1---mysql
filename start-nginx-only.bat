@echo off
chcp 65001 >nul
echo ========================================
echo Start Nginx Only
echo ========================================
echo.

:: Check if nginx exists
if not exist "C:\nginx\nginx.exe" (
    echo [ERROR] nginx.exe not found: C:\nginx\nginx.exe
    echo Please install nginx to C:\nginx directory
    pause
    exit /b 1
)

echo [OK] nginx.exe found: C:\nginx\nginx.exe
echo.

:: Stop existing nginx
echo [INFO] Stopping existing nginx processes...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: Check ports
echo [INFO] Checking port availability...
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port 80 is already in use
    netstat -ano | find ":80 "
) else (
    echo [OK] Port 80 is available
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port 8443 is already in use
    netstat -ano | find ":8443 "
) else (
    echo [OK] Port 8443 is available
)

:: Start nginx
echo [INFO] Starting nginx...
echo [INFO] Working directory: C:\nginx
cd /d C:\nginx
echo [INFO] Current directory: %CD%

:: Try to start nginx
echo [INFO] Executing: nginx.exe
start "Nginx Server" nginx.exe
timeout /t 3 /nobreak >nul

:: Check if nginx started
echo [INFO] Checking if nginx started...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx process is running
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] Nginx process not found
    echo [INFO] Trying direct start...
    nginx.exe
    timeout /t 2 /nobreak >nul
    
    :: Check again
    tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Nginx started successfully
    ) else (
        echo [ERROR] Nginx failed to start
        echo [INFO] Check error log: C:\nginx\logs\error.log
        if exist "C:\nginx\logs\error.log" (
            echo [INFO] Error log content:
            type C:\nginx\logs\error.log
        )
    )
)

:: Check ports after start
echo [INFO] Checking ports after start...
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 is now listening
) else (
    echo [ERROR] Port 80 is not listening
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is now listening
) else (
    echo [ERROR] Port 8443 is not listening
)

:: Show all listening ports
echo [INFO] All listening ports:
netstat -an | find "LISTENING" | find ":80\|:443\|:8443"

cd /d "%~dp0"

echo.
echo ========================================
echo Nginx Start Complete!
echo ========================================
echo.
echo If nginx is running, you can access:
echo   HTTP:  http://localhost
echo   HTTPS: https://localhost:8443
echo.
echo If nginx failed to start, check:
echo   1. C:\nginx\logs\error.log
echo   2. Port 80 and 8443 availability
echo   3. nginx configuration files
echo.
echo Press any key to exit...
pause >nul
