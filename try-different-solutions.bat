@echo off
chcp 65001 >nul
echo ========================================
echo Try Different Solutions for 8443 Port
echo ========================================
echo.

echo [SOLUTION 1] Try port 9443 instead of 8443
echo ========================================
echo [INFO] Creating SSL configuration for port 9443...
(
echo # SSL configuration for port 9443
echo server {
echo     listen 80;
echo     server_name admin.practice.insightdate.top;
echo     return 301 https://$server_name:9443$request_uri;
echo }
echo.
echo server {
echo     listen 9443 ssl;
echo     server_name admin.practice.insightdate.top;
echo.
echo     ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo     ssl_protocols TLSv1.2;
echo     ssl_ciphers HIGH:!aNULL:!MD5;
echo.
echo     root C:/admin;
echo     index index.html;
echo.
echo     location / {
echo         try_files $uri $uri/ /index.html;
echo     }
echo }
) > "C:\nginx\conf.d\admin-ssl-9443.conf"

echo [OK] Created SSL configuration for port 9443

:: Remove old SSL config
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    del "C:\nginx\conf.d\admin-ssl.conf"
    echo [OK] Removed old SSL configuration
)

:: Test and reload nginx
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
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

echo [INFO] Checking port 9443...
netstat -an | find ":9443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 9443 is listening
    echo [SUCCESS] SSL server is working on port 9443
    echo [INFO] You can now access: https://admin.practice.insightdate.top:9443
) else (
    echo [ERROR] Port 9443 is not listening
    goto :solution2
)

goto :end

:solution2
echo.
echo [SOLUTION 2] Try HTTP only (no SSL)
echo ========================================
echo [INFO] Creating HTTP-only configuration for port 8080...
(
echo # HTTP-only configuration for port 8080
echo server {
echo     listen 8080;
echo     server_name admin.practice.insightdate.top;
echo.
echo     root C:/admin;
echo     index index.html;
echo.
echo     location / {
echo         try_files $uri $uri/ /index.html;
echo     }
echo }
) > "C:\nginx\conf.d\admin-http-8080.conf"

echo [OK] Created HTTP-only configuration for port 8080

:: Remove SSL configs
if exist "C:\nginx\conf.d\admin-ssl.conf" del "C:\nginx\conf.d\admin-ssl.conf"
if exist "C:\nginx\conf.d\admin-ssl-9443.conf" del "C:\nginx\conf.d\admin-ssl-9443.conf"

:: Test and reload nginx
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
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

echo [INFO] Checking port 8080...
netstat -an | find ":8080 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8080 is listening
    echo [SUCCESS] HTTP server is working on port 8080
    echo [INFO] You can now access: http://admin.practice.insightdate.top:8080
) else (
    echo [ERROR] Port 8080 is not listening
    goto :solution3
)

goto :end

:solution3
echo.
echo [SOLUTION 3] Try minimal nginx configuration
echo ========================================
echo [INFO] Creating minimal nginx configuration...
(
echo # Minimal nginx configuration
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
echo.
echo         ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo         ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo         root C:/admin;
echo         index index.html;
echo.
echo         location / {
echo             try_files $uri $uri/ /index.html;
echo         }
echo     }
echo }
) > "C:\nginx\conf\nginx.conf"

echo [OK] Created minimal nginx configuration

:: Remove all conf.d files
for %%f in (C:\nginx\conf.d\*.conf) do (
    del "%%f"
    echo [OK] Removed %%f
)

:: Test and restart nginx
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
)
cd /d "%~dp0"

echo [INFO] Restarting nginx...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul
cd /d C:\nginx
start "Nginx" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

echo [INFO] Checking ports...
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 80 is listening
) else (
    echo [ERROR] Port 80 is not listening
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
    echo [SUCCESS] SSL server is working on port 8443
    echo [INFO] You can now access: https://admin.practice.insightdate.top:8443
) else (
    echo [ERROR] Port 8443 is still not listening
    echo [INFO] This indicates a deeper nginx SSL issue
)

:end
echo.
echo ========================================
echo Solutions Complete
echo ========================================
echo.
echo If none of the solutions worked:
echo 1. Check if nginx SSL module is compiled
echo 2. Try a different nginx version
echo 3. Check Windows firewall settings
echo 4. Check if SSL certificates are valid
echo.
echo Press any key to exit...
pause >nul
