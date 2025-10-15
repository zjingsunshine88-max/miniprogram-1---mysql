@echo off
chcp 65001 >nul
echo ========================================
echo Fix CORS Issue for Subdomain Access
echo ========================================
echo.

echo [STEP 1] Check current nginx configuration
echo ========================================
echo [INFO] Checking current nginx SSL configuration...

if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] admin-ssl.conf exists
    echo [INFO] Current SSL configuration:
    echo ----------------------------------------
    type C:\nginx\conf.d\admin-ssl.conf
    echo ----------------------------------------
) else (
    echo [ERROR] admin-ssl.conf not found
)

echo.
echo [STEP 2] Update nginx configuration with CORS headers
echo ========================================
echo [INFO] Updating nginx configuration to handle CORS...

:: Stop nginx
echo [INFO] Stopping nginx...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: Create updated SSL configuration with CORS
(
echo # SSL configuration with CORS support
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
echo     # CORS headers for subdomain access
echo     add_header Access-Control-Allow-Origin "https://admin.practice.insightdate.top:8443" always;
echo     add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
echo     add_header Access-Control-Allow-Headers "Content-Type, Authorization, Accept, X-Requested-With" always;
echo     add_header Access-Control-Allow-Credentials "true" always;
echo     add_header Access-Control-Max-Age "3600" always;
echo.
echo     # Handle preflight requests
echo     if ($request_method = OPTIONS) {
echo         add_header Access-Control-Allow-Origin "https://admin.practice.insightdate.top:8443" always;
echo         add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
echo         add_header Access-Control-Allow-Headers "Content-Type, Authorization, Accept, X-Requested-With" always;
echo         add_header Access-Control-Allow-Credentials "true" always;
echo         add_header Access-Control-Max-Age "3600" always;
echo         add_header Content-Type "text/plain; charset=utf-8";
echo         add_header Content-Length 0;
echo         return 204;
echo     }
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

echo [OK] Updated nginx configuration with CORS headers

echo.
echo [STEP 3] Test nginx configuration
echo ========================================
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
    echo [INFO] Check error details above
)
cd /d "%~dp0"

echo.
echo [STEP 4] Start nginx
echo ========================================
echo [INFO] Starting nginx...
cd /d C:\nginx
start "Nginx Server" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

echo [INFO] Checking nginx status...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
) else (
    echo [ERROR] nginx failed to start
)

echo.
echo [STEP 5] Check ports
echo ========================================
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
) else (
    echo [ERROR] Port 8443 is not listening
)

echo.
echo [STEP 6] Alternative solution: Use same domain
echo ========================================
echo [INFO] Alternative solution: Configure nginx to serve both admin and API on same domain
echo [INFO] This would eliminate CORS issues completely

:: Create alternative configuration
(
echo # Alternative configuration: Same domain for admin and API
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
echo     # Serve admin frontend
echo     location / {
echo         try_files $uri $uri/ /index.html;
echo     }
echo.
echo     # Proxy API requests to practice.insightdate.top
echo     location /api/ {
echo         proxy_pass https://practice.insightdate.top/api/;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_ssl_verify off;
echo         proxy_ssl_server_name on;
echo     }
echo.
echo     location /health {
echo         return 200 "OK";
echo         add_header Content-Type text/plain;
echo     }
echo }
) > "C:\nginx\conf.d\admin-ssl-alternative.conf"

echo [OK] Created alternative configuration (admin-ssl-alternative.conf)

echo.
echo ========================================
echo CORS Fix Complete
echo ========================================
echo.
echo Two solutions provided:
echo.
echo [SOLUTION 1] CORS Headers (Current)
echo - Added CORS headers to allow subdomain access
echo - Handles preflight OPTIONS requests
echo - Allows credentials and custom headers
echo.
echo [SOLUTION 2] Same Domain Proxy (Alternative)
echo - Proxies API requests through nginx
echo - Eliminates CORS issues completely
echo - Admin and API appear to be on same domain
echo.
echo To use Solution 2:
echo 1. Stop nginx
echo 2. Rename admin-ssl.conf to admin-ssl.conf.backup
echo 3. Rename admin-ssl-alternative.conf to admin-ssl.conf
echo 4. Restart nginx
echo.
echo Next steps:
echo 1. Test the admin login
echo 2. Check browser developer tools for CORS errors
echo 3. If still having issues, try Solution 2
echo.
echo Press any key to exit...
pause >nul
