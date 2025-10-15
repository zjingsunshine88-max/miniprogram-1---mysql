@echo off
chcp 65001 >nul
echo ========================================
echo Deep Diagnose 8443 Port Issue
echo ========================================
echo.

echo [STEP 1] Check nginx configuration in detail
echo ========================================
echo [INFO] nginx.conf content:
echo ----------------------------------------
type C:\nginx\conf\nginx.conf
echo ----------------------------------------

echo.
echo [INFO] admin-ssl.conf content:
echo ----------------------------------------
type C:\nginx\conf.d\admin-ssl.conf
echo ----------------------------------------

echo.
echo [STEP 2] Check nginx error log for SSL errors
echo ========================================
if exist "C:\nginx\logs\error.log" (
    echo [INFO] nginx error log content:
    echo ----------------------------------------
    type C:\nginx\logs\error.log
    echo ----------------------------------------
    
    echo [INFO] Looking for SSL-related errors...
    findstr /i "ssl" "C:\nginx\logs\error.log" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [ERROR] SSL-related errors found:
        findstr /i "ssl" "C:\nginx\logs\error.log"
    ) else (
        echo [OK] No SSL-related errors in log
    )
    
    echo [INFO] Looking for certificate errors...
    findstr /i "certificate" "C:\nginx\logs\error.log" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [ERROR] Certificate-related errors found:
        findstr /i "certificate" "C:\nginx\logs\error.log"
    ) else (
        echo [OK] No certificate-related errors in log
    )
) else (
    echo [WARNING] nginx error log not found
)

echo.
echo [STEP 3] Test SSL certificate files
echo ========================================
echo [INFO] Testing SSL certificate file...
if exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [OK] SSL certificate file exists
    echo [INFO] Certificate file size:
    dir "C:\certificates\admin.practice.insightdata.top.pem" | find "admin.practice.insightdata.top.pem"
    
    echo [INFO] Certificate file content (first few lines):
    type "C:\certificates\admin.practice.insightdata.top.pem" | head -5
) else (
    echo [ERROR] SSL certificate file not found
)

echo.
echo [INFO] Testing SSL private key file...
if exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [OK] SSL private key file exists
    echo [INFO] Private key file size:
    dir "C:\certificates\admin.practice.insightdata.top.key" | find "admin.practice.insightdata.top.key"
    
    echo [INFO] Private key file content (first few lines):
    type "C:\certificates\admin.practice.insightdata.top.key" | head -5
) else (
    echo [ERROR] SSL private key file not found
)

echo.
echo [STEP 4] Check if nginx is actually loading the SSL config
echo ========================================
echo [INFO] Checking nginx process details...
tasklist /fi "imagename eq nginx.exe" /fo table

echo.
echo [INFO] Checking all listening ports...
netstat -an | find "LISTENING"

echo.
echo [STEP 5] Try to restart nginx completely
echo ========================================
echo [INFO] Stopping all nginx processes...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 3 /nobreak >nul

echo [INFO] Waiting for processes to stop...
timeout /t 2 /nobreak >nul

echo [INFO] Checking if nginx processes are stopped...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Some nginx processes are still running
    taskkill /f /im nginx.exe
    timeout /t 2 /nobreak >nul
) else (
    echo [OK] All nginx processes stopped
)

echo [INFO] Starting nginx...
cd /d C:\nginx
start "Nginx Server" nginx.exe
timeout /t 5 /nobreak >nul
cd /d "%~dp0"

echo [INFO] Checking nginx status after restart...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running after restart
) else (
    echo [ERROR] nginx failed to start after restart
)

echo.
echo [STEP 6] Check ports after restart
echo ========================================
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 is listening after restart
) else (
    echo [ERROR] Port 80 is not listening after restart
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening after restart
    netstat -ano | find ":8443 "
) else (
    echo [ERROR] Port 8443 is still not listening after restart
)

echo.
echo [STEP 7] Check nginx error log after restart
echo ========================================
if exist "C:\nginx\logs\error.log" (
    echo [INFO] nginx error log after restart:
    echo ----------------------------------------
    type C:\nginx\logs\error.log
    echo ----------------------------------------
) else (
    echo [WARNING] nginx error log not found after restart
)

echo.
echo [STEP 8] Try to create a minimal SSL configuration
echo ========================================
echo [INFO] Creating minimal SSL configuration for testing...
(
echo # Minimal SSL configuration for testing
echo server {
echo     listen 8443 ssl;
echo     server_name localhost;
echo.
echo     ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo     location / {
echo         return 200 "SSL Server Working";
echo         add_header Content-Type text/plain;
echo     }
echo }
) > "C:\nginx\conf.d\test-ssl.conf"

echo [OK] Created minimal SSL configuration

echo [INFO] Testing nginx configuration with minimal SSL config...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed with minimal SSL config
) else (
    echo [ERROR] nginx configuration test failed with minimal SSL config
)
cd /d "%~dp0"

echo [INFO] Reloading nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -s reload
if %errorlevel% equ 0 (
    echo [OK] nginx configuration reloaded
) else (
    echo [ERROR] nginx configuration reload failed
)
cd /d "%~dp0"

echo [INFO] Checking port 8443 after minimal config...
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening with minimal SSL config
) else (
    echo [ERROR] Port 8443 is still not listening with minimal SSL config
)

echo.
echo ========================================
echo Deep Diagnosis Complete
echo ========================================
echo.
echo If port 8443 is still not listening, possible causes:
echo 1. SSL certificate files are corrupted or invalid
echo 2. nginx SSL module is not compiled or loaded
echo 3. Port 8443 is blocked by firewall or another service
echo 4. nginx configuration has hidden syntax errors
echo 5. Windows-specific nginx SSL issues
echo.
echo Next steps:
echo 1. Check if SSL certificate files are valid
echo 2. Try using a different port (e.g., 9443)
echo 3. Check Windows firewall settings
echo 4. Try a different nginx version
echo.
echo Press any key to exit...
pause >nul
