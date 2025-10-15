@echo off
echo ========================================
echo Start Admin System
echo ========================================
echo.

:: Check SSL certificates
if not exist "C:\certificates\admin.practice.insightdata.top.pem" goto :no_cert
if not exist "C:\certificates\admin.practice.insightdata.top.key" goto :no_key

echo [OK] SSL certificates found
echo.

:: Build admin
echo [INFO] Building admin...
cd admin
if not exist "node_modules" call npm install
call npm run build
if not exist "dist" goto :build_failed

:: Copy to C:\admin
echo [INFO] Copying files...
if not exist "C:\admin" mkdir "C:\admin"
xcopy "dist\*" "C:\admin\" /E /Y /Q
cd ..

:: Stop nginx
echo [INFO] Stopping nginx...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: Start nginx
echo [INFO] Starting nginx...
cd /d C:\nginx
start "Nginx" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

:: Check status
echo [INFO] Checking status...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx is running
) else (
    echo [ERROR] Nginx not running
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
) else (
    echo [ERROR] Port 8443 not listening
)

echo.
echo ========================================
echo Complete!
echo ========================================
echo.
echo Access: https://admin.practice.insightdate.top:8443
echo Local:  https://localhost:8443
echo.
pause
goto :end

:no_cert
echo [ERROR] SSL certificate not found: C:\certificates\admin.practice.insightdata.top.pem
pause
goto :end

:no_key
echo [ERROR] SSL private key not found: C:\certificates\admin.practice.insightdata.top.key
pause
goto :end

:build_failed
echo [ERROR] Admin build failed
pause
goto :end

:end
