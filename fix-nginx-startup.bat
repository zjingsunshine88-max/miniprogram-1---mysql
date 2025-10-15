@echo off
chcp 65001 >nul
echo ========================================
echo Fix Nginx Startup Issues
echo ========================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run as administrator
    echo Right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo [OK] Running as administrator
echo.

:: Stop all nginx processes
echo [STEP 1] Stop all nginx processes
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo [OK] All nginx processes stopped

:: Create required directories
echo [STEP 2] Create required directories
if not exist "C:\nginx\logs" (
    mkdir "C:\nginx\logs"
    echo [OK] Created logs directory
)

if not exist "C:\nginx\conf.d" (
    mkdir "C:\nginx\conf.d"
    echo [OK] Created conf.d directory
)

if not exist "C:\nginx\temp" (
    mkdir "C:\nginx\temp"
    echo [OK] Created temp directory
)

:: Create mime.types file
echo [STEP 3] Create mime.types file
(
echo types {
echo     text/html                             html htm shtml;
echo     text/css                              css;
echo     text/xml                              xml;
echo     image/gif                             gif;
echo     image/jpeg                            jpeg jpg;
echo     application/javascript                js;
echo     application/json                       json;
echo     image/png                             png;
echo     image/svg+xml                         svg;
echo     application/pdf                        pdf;
echo     application/octet-stream               bin exe dll;
echo }
) > "C:\nginx\mime.types"
echo [OK] Created mime.types file

:: Create clean nginx.conf
echo [STEP 4] Create clean nginx.conf
(
echo # Windows nginx configuration
echo worker_processes auto;
echo error_log logs/error.log warn;
echo pid logs/nginx.pid;
echo.
echo events {
echo     worker_connections 1024;
echo     use select;
echo     multi_accept on;
echo }
echo.
echo http {
echo     include mime.types;
echo     default_type application/octet-stream;
echo.
echo     log_format main '$remote_addr - $remote_user [$time_local] "$request" '
echo                     '$status $body_bytes_sent "$http_referer" '
echo                     '"$http_user_agent" "$http_x_forwarded_for"';
echo.
echo     access_log logs/access.log main;
echo.
echo     sendfile on;
echo     tcp_nopush on;
echo     tcp_nodelay on;
echo     keepalive_timeout 65;
echo     types_hash_max_size 2048;
echo     client_max_body_size 20M;
echo.
echo     gzip on;
echo     gzip_vary on;
echo     gzip_min_length 1024;
echo     gzip_proxied any;
echo     gzip_comp_level 6;
echo     gzip_types
echo         text/plain
echo         text/css
echo         text/xml
echo         text/javascript
echo         application/javascript
echo         application/xml+rss
echo         application/json;
echo.
echo     include conf.d/*.conf;
echo }
) > "C:\nginx\conf\nginx.conf"
echo [OK] Created clean nginx.conf

:: Create simple SSL config
echo [STEP 5] Create simple SSL config
(
echo # Simple SSL configuration
echo server {
echo     listen 80;
echo     server_name localhost;
echo     return 301 https://$server_name:8443$request_uri;
echo }
echo.
echo server {
echo     listen 8443 ssl;
echo     server_name localhost;
echo.
echo     ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers HIGH:!aNULL:!MD5;
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
echo [OK] Created simple SSL config

:: Create log files
echo [STEP 6] Create log files
echo. > "C:\nginx\logs\error.log"
echo. > "C:\nginx\logs\access.log"
echo [OK] Created log files

:: Test configuration
echo [STEP 7] Test nginx configuration
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
echo [STEP 8] Start nginx
cd /d C:\nginx
start "Nginx Server" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

:: Check if nginx started
echo [STEP 9] Check nginx status
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] nginx is not running
    echo [INFO] Check error log: C:\nginx\logs\error.log
    if exist "C:\nginx\logs\error.log" (
        echo [INFO] Error log content:
        type C:\nginx\logs\error.log
    )
)

:: Check ports
echo [STEP 10] Check ports
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 is listening
) else (
    echo [ERROR] Port 80 is not listening
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
) else (
    echo [ERROR] Port 8443 is not listening
)

echo.
echo ========================================
echo Fix Complete
echo ========================================
echo.
echo If nginx is now running, you can access:
echo   HTTP:  http://localhost (redirects to HTTPS)
echo   HTTPS: https://localhost:8443
echo.
echo If nginx is still not running, run:
echo   diagnose-nginx.bat
echo.
echo Press any key to exit...
pause >nul
