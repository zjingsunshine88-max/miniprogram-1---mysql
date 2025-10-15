@echo off
chcp 65001 >nul
echo ========================================
echo Fix Nginx Encoding Issues
echo ========================================
echo.

:: Stop nginx
taskkill /f /im nginx.exe >nul 2>&1

:: Remove problematic admin.conf file
echo [INFO] Removing problematic admin.conf file...
if exist "C:\nginx\conf\conf.d\admin.conf" (
    del "C:\nginx\conf\conf.d\admin.conf"
    echo [OK] Removed admin.conf
)

if exist "C:\nginx\conf.d\admin.conf" (
    del "C:\nginx\conf.d\admin.conf"
    echo [OK] Removed admin.conf from conf.d
)

:: Remove any other problematic .conf files
echo [INFO] Cleaning all .conf files...
for %%f in (C:\nginx\conf\*.conf) do (
    if not "%%f"=="C:\nginx\conf\nginx.conf" (
        del "%%f"
        echo [OK] Removed %%f
    )
)

for %%f in (C:\nginx\conf.d\*.conf) do (
    del "%%f"
    echo [OK] Removed %%f
)

:: Create clean SSL config
echo [INFO] Creating clean SSL configuration...
(
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
echo.
echo     root C:/admin;
echo     index index.html;
echo.
echo     location / {
echo         try_files $uri $uri/ /index.html;
echo     }
echo }
) > "C:\nginx\conf.d\admin-ssl.conf"

echo [OK] Created clean SSL configuration

:: Test and start nginx
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] Configuration test passed
    echo [INFO] Starting nginx...
    start "Nginx" nginx.exe
    timeout /t 3 /nobreak >nul
    
    tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] nginx is running
    ) else (
        echo [ERROR] nginx failed to start
    )
) else (
    echo [ERROR] Configuration test failed
)

cd /d "%~dp0"

echo.
echo ========================================
echo Fix Complete
echo ========================================
echo.
echo Access: https://admin.practice.insightdate.top:8443
echo.
pause
