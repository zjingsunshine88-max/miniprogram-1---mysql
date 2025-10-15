@echo off
chcp 65001 >nul
echo ========================================
echo Create Minimal Nginx Configuration
echo ========================================
echo.

:: Stop nginx
taskkill /f /im nginx.exe >nul 2>&1

:: Create minimal nginx.conf
echo [INFO] Creating minimal nginx.conf...
(
echo worker_processes 1;
echo error_log logs/error.log;
echo pid logs/nginx.pid;
echo.
echo events {
echo     worker_connections 1024;
echo }
echo.
echo http {
echo     include mime.types;
echo     default_type application/octet-stream;
echo.
echo     server {
echo         listen 80;
echo         server_name localhost;
echo         root C:/admin;
echo         index index.html;
echo.
echo         location / {
echo             try_files $uri $uri/ /index.html;
echo         }
echo     }
echo.
echo     server {
echo         listen 8443 ssl;
echo         server_name localhost;
echo         root C:/admin;
echo         index index.html;
echo.
echo         ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo         ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo         location / {
echo             try_files $uri $uri/ /index.html;
echo         }
echo     }
echo }
) > "C:\nginx\conf\nginx.conf"

:: Create minimal mime.types
echo [INFO] Creating minimal mime.types...
(
echo types {
echo     text/html html;
echo     text/css css;
echo     text/javascript js;
echo     application/javascript js;
echo     image/png png;
echo     image/jpeg jpg;
echo     application/json json;
echo }
) > "C:\nginx\mime.types"

:: Create directories
if not exist "C:\nginx\logs" mkdir "C:\nginx\logs"
if not exist "C:\nginx\conf.d" mkdir "C:\nginx\conf.d"

:: Create log files
echo. > "C:\nginx\logs\error.log"
echo. > "C:\nginx\logs\access.log"

echo [OK] Minimal nginx configuration created

:: Test configuration
echo [INFO] Testing configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
cd /d "%~dp0"

:: Start nginx
echo [INFO] Starting nginx...
cd /d C:\nginx
start "Nginx" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

:: Check status
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
) else (
    echo [ERROR] nginx is not running
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
) else (
    echo [ERROR] Port 8443 is not listening
)

echo.
echo ========================================
echo Complete
echo ========================================
echo.
echo Access: https://localhost:8443
echo.
pause
