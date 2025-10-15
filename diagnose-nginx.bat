@echo off
chcp 65001 >nul
echo ========================================
echo Nginx Startup Diagnosis
echo ========================================
echo.

echo [STEP 1] Check nginx installation
echo ========================================
if exist "C:\nginx\nginx.exe" (
    echo [OK] nginx.exe exists: C:\nginx\nginx.exe
    C:\nginx\nginx.exe -v
) else (
    echo [ERROR] nginx.exe NOT found: C:\nginx\nginx.exe
    echo Please install nginx to C:\nginx directory
    goto :end
)

echo.
echo [STEP 2] Check nginx configuration files
echo ========================================
if exist "C:\nginx\conf\nginx.conf" (
    echo [OK] nginx.conf exists: C:\nginx\conf\nginx.conf
    echo [INFO] nginx.conf content:
    echo ----------------------------------------
    type C:\nginx\conf\nginx.conf
    echo ----------------------------------------
) else (
    echo [ERROR] nginx.conf NOT found: C:\nginx\conf\nginx.conf
    goto :end
)

echo.
echo [STEP 3] Check SSL configuration
echo ========================================
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] admin-ssl.conf exists: C:\nginx\conf.d\admin-ssl.conf
    echo [INFO] admin-ssl.conf content:
    echo ----------------------------------------
    type C:\nginx\conf.d\admin-ssl.conf
    echo ----------------------------------------
) else (
    echo [WARNING] admin-ssl.conf NOT found: C:\nginx\conf.d\admin-ssl.conf
)

echo.
echo [STEP 4] Check SSL certificates
echo ========================================
if exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [OK] SSL certificate exists: C:\certificates\admin.practice.insightdata.top.pem
) else (
    echo [ERROR] SSL certificate NOT found: C:\certificates\admin.practice.insightdata.top.pem
)

if exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [OK] SSL private key exists: C:\certificates\admin.practice.insightdata.top.key
) else (
    echo [ERROR] SSL private key NOT found: C:\certificates\admin.practice.insightdata.top.key
)

echo.
echo [STEP 5] Check required directories
echo ========================================
if exist "C:\nginx\logs" (
    echo [OK] logs directory exists: C:\nginx\logs
) else (
    echo [WARNING] logs directory NOT found: C:\nginx\logs
    echo [INFO] Creating logs directory...
    mkdir "C:\nginx\logs"
    echo [OK] logs directory created
)

if exist "C:\nginx\conf.d" (
    echo [OK] conf.d directory exists: C:\nginx\conf.d
) else (
    echo [WARNING] conf.d directory NOT found: C:\nginx\conf.d
    echo [INFO] Creating conf.d directory...
    mkdir "C:\nginx\conf.d"
    echo [OK] conf.d directory created
)

echo.
echo [STEP 6] Check mime.types file
echo ========================================
if exist "C:\nginx\mime.types" (
    echo [OK] mime.types exists: C:\nginx\mime.types
) else (
    echo [WARNING] mime.types NOT found: C:\nginx\mime.types
    echo [INFO] Creating basic mime.types...
    (
        echo types {
        echo     text/html                             html htm shtml;
        echo     text/css                              css;
        echo     text/javascript                       js;
        echo     application/javascript                js;
        echo     image/png                             png;
        echo     image/jpeg                            jpeg jpg;
        echo     application/json                       json;
        echo     application/octet-stream               bin exe dll;
        echo }
    ) > "C:\nginx\mime.types"
    echo [OK] mime.types created
)

echo.
echo [STEP 7] Check port availability
echo ========================================
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

echo.
echo [STEP 8] Stop existing nginx processes
echo ========================================
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Stopping existing nginx processes...
    taskkill /f /im nginx.exe
    timeout /t 2 /nobreak >nul
    echo [OK] Existing nginx processes stopped
) else (
    echo [OK] No existing nginx processes found
)

echo.
echo [STEP 9] Test nginx configuration
echo ========================================
cd /d C:\nginx
echo [INFO] Testing nginx configuration...
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
    echo [INFO] Check error details above
)
cd /d "%~dp0"

echo.
echo [STEP 10] Try to start nginx
echo ========================================
cd /d C:\nginx
echo [INFO] Attempting to start nginx...
echo [INFO] Working directory: %CD%

:: Try to start nginx in background
start "Nginx Server" nginx.exe
timeout /t 3 /nobreak >nul

:: Check if nginx started
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx process is running
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] nginx process not found
    echo [INFO] Trying direct start to see error...
    nginx.exe
    timeout /t 2 /nobreak >nul
)

cd /d "%~dp0"

echo.
echo [STEP 11] Check nginx error log
echo ========================================
if exist "C:\nginx\logs\error.log" (
    echo [INFO] nginx error log content:
    echo ----------------------------------------
    type C:\nginx\logs\error.log
    echo ----------------------------------------
) else (
    echo [WARNING] nginx error log not found: C:\nginx\logs\error.log
)

echo.
echo [STEP 12] Final status check
echo ========================================
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
) else (
    echo [ERROR] nginx is NOT running
)

netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 is listening
) else (
    echo [ERROR] Port 80 is NOT listening
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
) else (
    echo [ERROR] Port 8443 is NOT listening
)

:end
echo.
echo ========================================
echo Diagnosis Complete
echo ========================================
echo.
echo If nginx is still not running, common issues:
echo 1. Configuration file syntax errors
echo 2. SSL certificate file paths incorrect
echo 3. Port conflicts
echo 4. Missing required files (mime.types, etc.)
echo 5. Permission issues
echo.
echo Press any key to exit...
pause >nul
