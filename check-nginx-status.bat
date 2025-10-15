@echo off
chcp 65001 >nul
echo ========================================
echo Check Nginx Status and Port Access
echo ========================================
echo.

echo [STEP 1] Check nginx process
echo ========================================
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx process is running
    echo [INFO] nginx process details:
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] nginx process is NOT running
    echo [INFO] nginx needs to be started
)

echo.
echo [STEP 2] Check port 80
echo ========================================
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 is listening
    echo [INFO] Port 80 details:
    netstat -ano | find ":80 "
) else (
    echo [ERROR] Port 80 is NOT listening
)

echo.
echo [STEP 3] Check port 8443
echo ========================================
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
    echo [INFO] Port 8443 details:
    netstat -ano | find ":8443 "
) else (
    echo [ERROR] Port 8443 is NOT listening
)

echo.
echo [STEP 4] Check all listening ports
echo ========================================
echo [INFO] All listening ports (80, 443, 8443):
netstat -an | find "LISTENING" | find ":80\|:443\|:8443"

echo.
echo [STEP 5] Check nginx configuration
echo ========================================
if exist "C:\nginx\conf\nginx.conf" (
    echo [OK] nginx.conf exists
    echo [INFO] nginx.conf content:
    echo ----------------------------------------
    type C:\nginx\conf\nginx.conf
    echo ----------------------------------------
) else (
    echo [ERROR] nginx.conf NOT found
)

echo.
echo [STEP 6] Check SSL configuration
echo ========================================
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] admin-ssl.conf exists
    echo [INFO] admin-ssl.conf content:
    echo ----------------------------------------
    type C:\nginx\conf.d\admin-ssl.conf
    echo ----------------------------------------
) else (
    echo [ERROR] admin-ssl.conf NOT found
)

echo.
echo [STEP 7] Check SSL certificates
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
echo [STEP 8] Check admin static files
echo ========================================
if exist "C:\admin\index.html" (
    echo [OK] Admin static files exist: C:\admin\index.html
    echo [INFO] Admin directory contents:
    dir C:\admin /b
) else (
    echo [ERROR] Admin static files NOT found: C:\admin\index.html
)

echo.
echo [STEP 9] Test local access
echo ========================================
echo [INFO] Testing local HTTP access...
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://localhost
if %errorlevel% neq 0 (
    echo [WARNING] curl not available, trying alternative method
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost' -TimeoutSec 5; Write-Host 'HTTP Status:' $response.StatusCode } catch { Write-Host 'HTTP Error:' $_.Exception.Message }"
)

echo [INFO] Testing local HTTPS access...
curl -s -k -o nul -w "HTTPS Status: %%{http_code}\n" https://localhost:8443
if %errorlevel% neq 0 (
    echo [WARNING] curl not available, trying alternative method
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://localhost:8443' -TimeoutSec 5 -SkipCertificateCheck; Write-Host 'HTTPS Status:' $response.StatusCode } catch { Write-Host 'HTTPS Error:' $_.Exception.Message }"
)

echo.
echo [STEP 10] Check nginx error log
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
echo [STEP 11] Check nginx access log
echo ========================================
if exist "C:\nginx\logs\access.log" (
    echo [INFO] nginx access log content:
    echo ----------------------------------------
    type C:\nginx\logs\access.log
    echo ----------------------------------------
) else (
    echo [WARNING] nginx access log not found: C:\nginx\logs\access.log
)

echo.
echo [STEP 12] Check firewall and network
echo ========================================
echo [INFO] Checking if ports are accessible from outside...
echo [INFO] This may take a few seconds...

:: Check if port 8443 is accessible
telnet localhost 8443 < nul
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is accessible locally
) else (
    echo [WARNING] Port 8443 may not be accessible
)

echo.
echo ========================================
echo Status Summary
echo ========================================
echo.

:: Summary check
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx process: RUNNING
) else (
    echo [ERROR] nginx process: NOT RUNNING
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443: LISTENING
) else (
    echo [ERROR] Port 8443: NOT LISTENING
)

if exist "C:\admin\index.html" (
    echo [OK] Admin files: EXISTS
) else (
    echo [ERROR] Admin files: NOT FOUND
)

if exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [OK] SSL certificate: EXISTS
) else (
    echo [ERROR] SSL certificate: NOT FOUND
)

echo.
echo ========================================
echo Troubleshooting Tips
echo ========================================
echo.
echo If nginx is not running:
echo   1. Run: start-nginx-only.bat
echo   2. Check: C:\nginx\logs\error.log
echo.
echo If port 8443 is not listening:
echo   1. Check nginx configuration
echo   2. Check if port is blocked by firewall
echo   3. Check if another service is using the port
echo.
echo If admin.practice.insightdata.top:8443 is not accessible:
echo   1. Check DNS resolution
echo   2. Check firewall rules
echo   3. Check SSL certificate validity
echo   4. Check nginx server_name configuration
echo.
echo Press any key to exit...
pause >nul