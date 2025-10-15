@echo off
chcp 65001 >nul
echo ========================================
echo Check Nginx SSL Configuration Loading
echo ========================================
echo.

echo [STEP 1] Check nginx.conf includes
echo ========================================
if exist "C:\nginx\conf\nginx.conf" (
    echo [INFO] nginx.conf content:
    echo ----------------------------------------
    type C:\nginx\conf\nginx.conf
    echo ----------------------------------------
    
    findstr /i "conf.d" "C:\nginx\conf\nginx.conf" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] nginx.conf includes conf.d
        echo [INFO] Include line:
        findstr /i "conf.d" "C:\nginx\conf\nginx.conf"
    ) else (
        echo [ERROR] nginx.conf does NOT include conf.d
        echo [REASON] SSL configuration files are not being loaded
    )
) else (
    echo [ERROR] nginx.conf not found
)

echo.
echo [STEP 2] Check SSL configuration file
echo ========================================
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] SSL config exists: C:\nginx\conf.d\admin-ssl.conf
    echo [INFO] SSL config content:
    echo ----------------------------------------
    type C:\nginx\conf.d\admin-ssl.conf
    echo ----------------------------------------
    
    findstr /i "8443" "C:\nginx\conf.d\admin-ssl.conf" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Port 8443 found in SSL config
        echo [INFO] 8443 configuration lines:
        findstr /i "8443" "C:\nginx\conf.d\admin-ssl.conf"
    ) else (
        echo [ERROR] Port 8443 NOT found in SSL config
    )
) else (
    echo [ERROR] SSL config not found: C:\nginx\conf.d\admin-ssl.conf
)

echo.
echo [STEP 3] Check SSL certificates
echo ========================================
if exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [OK] SSL certificate exists
) else (
    echo [ERROR] SSL certificate NOT found
    echo [REASON] nginx cannot start SSL server without certificate
)

if exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [OK] SSL private key exists
) else (
    echo [ERROR] SSL private key NOT found
    echo [REASON] nginx cannot start SSL server without private key
)

echo.
echo [STEP 4] Check nginx error log for SSL errors
echo ========================================
if exist "C:\nginx\logs\error.log" (
    echo [INFO] nginx error log content:
    echo ----------------------------------------
    type C:\nginx\logs\error.log
    echo ----------------------------------------
    
    findstr /i "ssl" "C:\nginx\logs\error.log" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] SSL-related errors found:
        findstr /i "ssl" "C:\nginx\logs\error.log"
    ) else (
        echo [INFO] No SSL-related errors in log
    )
    
    findstr /i "8443" "C:\nginx\logs\error.log" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] 8443-related errors found:
        findstr /i "8443" "C:\nginx\logs\error.log"
    ) else (
        echo [INFO] No 8443-related errors in log
    )
) else (
    echo [WARNING] nginx error log not found
)

echo.
echo [STEP 5] Test nginx configuration with verbose output
echo ========================================
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t -c "C:\nginx\conf\nginx.conf"
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
)
cd /d "%~dp0"

echo.
echo [STEP 6] Check if nginx is actually loading SSL config
echo ========================================
echo [INFO] Checking nginx process and loaded configuration...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
    echo [INFO] nginx processes:
    tasklist /fi "imagename eq nginx.exe" /fo table
    
    echo [INFO] Checking loaded configuration...
    echo [INFO] This may show if SSL config is loaded
) else (
    echo [ERROR] nginx is not running
)

echo.
echo [STEP 7] Check all listening ports
echo ========================================
echo [INFO] All listening ports:
netstat -an | find "LISTENING" | find ":80\|:443\|:8443"

echo.
echo [STEP 8] Try to reload nginx configuration
echo ========================================
echo [INFO] Attempting to reload nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -s reload
if %errorlevel% equ 0 (
    echo [OK] nginx configuration reloaded
) else (
    echo [ERROR] nginx configuration reload failed
)
cd /d "%~dp0"

:: Check ports after reload
echo [INFO] Checking ports after reload...
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is now listening after reload
) else (
    echo [ERROR] Port 8443 is still not listening after reload
)

echo.
echo ========================================
echo Analysis Complete
echo ========================================
echo.
echo Possible reasons why port 8443 is not listening:
echo 1. nginx.conf does not include conf.d/*.conf
echo 2. SSL configuration file has syntax errors
echo 3. SSL certificates are missing or invalid
echo 4. nginx is not loading the SSL configuration
echo 5. Port 8443 is blocked by firewall or another service
echo.
echo Solutions:
echo 1. Run: force-reload-nginx.bat
echo 2. Check SSL certificate files
echo 3. Verify nginx.conf includes conf.d
echo 4. Check nginx error log for SSL errors
echo.
echo Press any key to exit...
pause >nul
