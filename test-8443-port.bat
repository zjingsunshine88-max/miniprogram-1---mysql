@echo off
chcp 65001 >nul
echo ========================================
echo Test Port 8443 Access
echo ========================================
echo.

echo [TEST 1] Check if nginx is running
echo ========================================
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
) else (
    echo [ERROR] nginx is NOT running
    echo [INFO] Starting nginx...
    cd /d C:\nginx
    start "Nginx" nginx.exe
    timeout /t 3 /nobreak >nul
    cd /d "%~dp0"
)

echo.
echo [TEST 2] Check port 8443 listening
echo ========================================
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
    netstat -ano | find ":8443 "
) else (
    echo [ERROR] Port 8443 is NOT listening
    echo [INFO] This is the main problem!
)

echo.
echo [TEST 3] Test local HTTPS access
echo ========================================
echo [INFO] Testing https://localhost:8443
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://localhost:8443' -TimeoutSec 10 -SkipCertificateCheck; Write-Host '[OK] Local HTTPS access successful - Status:' $response.StatusCode } catch { Write-Host '[ERROR] Local HTTPS access failed:' $_.Exception.Message }"

echo.
echo [TEST 4] Test local HTTP access
echo ========================================
echo [INFO] Testing http://localhost
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost' -TimeoutSec 10; Write-Host '[OK] Local HTTP access successful - Status:' $response.StatusCode } catch { Write-Host '[ERROR] Local HTTP access failed:' $_.Exception.Message }"

echo.
echo [TEST 5] Check nginx configuration for port 8443
echo ========================================
echo [INFO] Checking nginx configuration...
findstr /i "8443" "C:\nginx\conf.d\admin-ssl.conf" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 found in nginx configuration
    echo [INFO] Configuration lines with 8443:
    findstr /i "8443" "C:\nginx\conf.d\admin-ssl.conf"
) else (
    echo [ERROR] Port 8443 NOT found in nginx configuration
    echo [INFO] This is why port 8443 is not listening!
)

echo.
echo [TEST 6] Check SSL certificate configuration
echo ========================================
echo [INFO] Checking SSL certificate paths in nginx config...
findstr /i "ssl_certificate" "C:\nginx\conf.d\admin-ssl.conf"
if %errorlevel% equ 0 (
    echo [OK] SSL certificate configuration found
) else (
    echo [ERROR] SSL certificate configuration NOT found
)

echo.
echo [TEST 7] Check if admin files exist
echo ========================================
if exist "C:\admin\index.html" (
    echo [OK] Admin files exist: C:\admin\index.html
) else (
    echo [ERROR] Admin files NOT found: C:\admin\index.html
    echo [INFO] This is why the site is not accessible!
)

echo.
echo [TEST 8] Check nginx error log
echo ========================================
if exist "C:\nginx\logs\error.log" (
    echo [INFO] Recent nginx errors:
    echo ----------------------------------------
    type C:\nginx\logs\error.log | tail -10
    echo ----------------------------------------
) else (
    echo [WARNING] nginx error log not found
)

echo.
echo ========================================
echo Quick Fix Suggestions
echo ========================================
echo.

:: Check if port 8443 is listening
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% neq 0 (
    echo [PROBLEM] Port 8443 is not listening
    echo [SOLUTION] Run: fix-nginx-encoding.bat
    echo [SOLUTION] Or run: clean-nginx-configs.bat
    echo.
)

:: Check if admin files exist
if not exist "C:\admin\index.html" (
    echo [PROBLEM] Admin files not found
    echo [SOLUTION] Run: start-admin-ssl.bat (to build and deploy)
    echo.
)

:: Check if nginx is running
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% neq 0 (
    echo [PROBLEM] nginx is not running
    echo [SOLUTION] Run: start-nginx-only.bat
    echo.
)

echo ========================================
echo Test Complete
echo ========================================
echo.
echo If port 8443 is not listening, the main issues are:
echo 1. nginx configuration problem
echo 2. nginx not running
echo 3. SSL certificate issues
echo.
echo Run the suggested solutions above to fix the problem.
echo.
echo Press any key to exit...
pause >nul
