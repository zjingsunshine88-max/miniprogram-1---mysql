@echo off
chcp 65001 >nul
echo ========================================
echo Force Reload Nginx Configuration
echo ========================================
echo.

:: Stop all nginx processes
echo [STEP 1] Stop all nginx processes
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 3 /nobreak >nul
echo [OK] All nginx processes stopped

:: Check if SSL config file exists in the right place
echo [STEP 2] Check SSL configuration file
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] SSL config exists: C:\nginx\conf.d\admin-ssl.conf
    echo [INFO] SSL config content:
    echo ----------------------------------------
    type C:\nginx\conf.d\admin-ssl.conf
    echo ----------------------------------------
) else (
    echo [ERROR] SSL config NOT found: C:\nginx\conf.d\admin-ssl.conf
    echo [INFO] Creating SSL config...
    goto :create_ssl_config
)

:: Check if nginx.conf includes conf.d
echo [STEP 3] Check nginx.conf includes
findstr /i "conf.d" "C:\nginx\conf\nginx.conf" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx.conf includes conf.d
    echo [INFO] nginx.conf include line:
    findstr /i "conf.d" "C:\nginx\conf\nginx.conf"
) else (
    echo [ERROR] nginx.conf does NOT include conf.d
    echo [INFO] Adding conf.d include to nginx.conf...
    goto :fix_nginx_conf
)

:: Test configuration
echo [STEP 4] Test nginx configuration
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
    echo [INFO] Check error details above
)
cd /d "%~dp0"

:: Start nginx
echo [STEP 5] Start nginx
cd /d C:\nginx
start "Nginx Server" nginx.exe
timeout /t 5 /nobreak >nul
cd /d "%~dp0"

:: Check nginx status
echo [STEP 6] Check nginx status
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] nginx failed to start
    goto :check_errors
)

:: Check ports
echo [STEP 7] Check ports
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 is listening
) else (
    echo [ERROR] Port 80 is not listening
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
    netstat -ano | find ":8443 "
) else (
    echo [ERROR] Port 8443 is still not listening
    echo [INFO] This indicates the SSL configuration is not being loaded
    goto :check_errors
)

goto :end

:create_ssl_config
echo [INFO] Creating SSL configuration...
(
echo # SSL configuration for port 8443
echo server {
echo     listen 80;
echo     server_name admin.practice.insightdate.top;
echo     return 301 https://$server_name:8443$request_uri;
echo }
echo.
echo server {
echo     listen 8443 ssl;
echo     server_name admin.practice.insightdate.top;
echo.
echo     ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers HIGH:!aNULL:!MD5;
echo     ssl_prefer_server_ciphers off;
echo.
echo     root C:/admin;
echo     index index.html;
echo.
echo     location / {
echo         try_files $uri $uri/ /index.html;
echo     }
echo.
echo     location /health {
echo         return 200 "OK";
echo         add_header Content-Type text/plain;
echo     }
echo }
) > "C:\nginx\conf.d\admin-ssl.conf"
echo [OK] Created SSL configuration
goto :end

:fix_nginx_conf
echo [INFO] Fixing nginx.conf...
copy "C:\nginx\conf\nginx.conf" "C:\nginx\conf\nginx.conf.backup" >nul
powershell -Command "(Get-Content 'C:\nginx\conf\nginx.conf') -replace '(http\s*\{)', '$1`n    include conf.d/*.conf;' | Set-Content 'C:\nginx\conf\nginx.conf'"
echo [OK] Added conf.d include to nginx.conf
goto :end

:check_errors
echo [INFO] Checking nginx error log...
if exist "C:\nginx\logs\error.log" (
    echo [INFO] Recent nginx errors:
    echo ----------------------------------------
    type C:\nginx\logs\error.log
    echo ----------------------------------------
) else (
    echo [WARNING] nginx error log not found
)

:end
echo.
echo ========================================
echo Reload Complete
echo ========================================
echo.
echo If port 8443 is still not listening, try:
echo 1. Check if SSL certificates exist and are valid
echo 2. Check if nginx.conf includes conf.d/*.conf
echo 3. Check nginx error log for SSL-related errors
echo 4. Try creating a minimal SSL configuration
echo.
echo Press any key to exit...
pause >nul
