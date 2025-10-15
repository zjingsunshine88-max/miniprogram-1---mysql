@echo off
chcp 65001 >nul
echo ========================================
echo Simple Admin Start
echo ========================================
echo.

:: Check SSL certificates
if not exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [ERROR] SSL certificate not found: C:\certificates\admin.practice.insightdata.top.pem
    pause
    exit /b 1
)

if not exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [ERROR] SSL private key not found: C:\certificates\admin.practice.insightdata.top.key
    pause
    exit /b 1
)

echo [OK] SSL certificates found
echo.

:: Check admin directory
if not exist "admin" (
    echo [ERROR] admin directory not found
    pause
    exit /b 1
)

echo [INFO] Entering admin directory...
cd admin

:: Check package.json
if not exist "package.json" (
    echo [ERROR] package.json not found
    pause
    exit /b 1
)

:: Install dependencies if needed
if not exist "node_modules" (
    echo [INFO] Installing dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
)

echo [INFO] Dependencies OK
echo.

:: Build admin project
echo [INFO] Building admin project...
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build admin project
    pause
    exit /b 1
)

echo [INFO] Admin project built successfully
echo.

:: Create C:\admin directory
if not exist "C:\admin" (
    echo [INFO] Creating C:\admin directory...
    mkdir "C:\admin"
)

:: Copy dist to C:\admin
echo [INFO] Copying build files to C:\admin...
if exist "dist" (
    xcopy "dist\*" "C:\admin\" /E /Y /Q
    if %errorlevel% equ 0 (
        echo [OK] Build files copied successfully
    ) else (
        echo [ERROR] Failed to copy build files
        pause
        exit /b 1
    )
) else (
    echo [ERROR] dist directory not found
    pause
    exit /b 1
)

:: Return to project root
cd ..

:: Stop existing nginx
echo [INFO] Stopping existing nginx...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: Start nginx
echo [INFO] Starting nginx...
echo [INFO] nginx path: C:\nginx
echo [INFO] config file: C:\nginx\conf\nginx.conf
start "Nginx Server" cmd /c "cd /d C:\nginx && nginx"

:: Wait for nginx to start
echo [INFO] Waiting for nginx to start...
timeout /t 5 /nobreak >nul

:: Check services
echo [INFO] Checking services...
echo.

:: Check admin files
if exist "C:\admin\index.html" (
    echo [OK] Admin static files deployed (C:\admin)
) else (
    echo [ERROR] Admin static files deployment failed
)

:: Check nginx process
echo [INFO] Checking nginx process...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx process running (C:\nginx)
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] Nginx process not started
    echo [INFO] Trying manual start...
    cd /d C:\nginx
    start "Nginx Manual" nginx.exe
    timeout /t 3 /nobreak >nul
    cd /d "%~dp0"
    
    :: Check again
    tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Nginx process started manually
    ) else (
        echo [ERROR] Nginx process still not running
    )
)

:: Check ports
echo [INFO] Checking ports...
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 listening
) else (
    echo [ERROR] Port 80 not listening
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 listening
) else (
    echo [ERROR] Port 8443 not listening
)

:: Show all listening ports
echo [INFO] All listening ports:
netstat -an | find "LISTENING" | find ":80\|:443\|:8443"

echo.
echo ========================================
echo Startup Complete!
echo ========================================
echo.
echo Access URLs:
echo   HTTPS: https://admin.practice.insightdate.top:8443
echo   HTTP:  http://admin.practice.insightdate.top (redirects to HTTPS:8443)
echo.
echo Local test URLs:
echo   Nginx proxy: http://localhost
echo   HTTPS test: https://localhost:8443
echo.
echo Deployment info:
echo   - Static files: C:\admin
echo   - Nginx path: C:\nginx
echo   - Nginx config: C:\nginx\conf\nginx.conf
echo   - Remote API: https://practice.insightdate.top/api
echo   - Stop service: run stop-admin-ssl.bat
echo.
echo Press any key to exit...
pause >nul
