@echo off
chcp 65001 >nul
echo ========================================
echo Quick Check 8443 Port Issue
echo ========================================
echo.

echo [CHECK 1] nginx process
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
) else (
    echo [ERROR] nginx is not running
)

echo.
echo [CHECK 2] Port 8443
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
) else (
    echo [ERROR] Port 8443 is NOT listening
)

echo.
echo [CHECK 3] nginx.conf includes conf.d
findstr /i "conf.d" "C:\nginx\conf\nginx.conf" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx.conf includes conf.d
) else (
    echo [ERROR] nginx.conf does NOT include conf.d
    echo [REASON] SSL config files are not loaded
)

echo.
echo [CHECK 4] SSL config file exists
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] SSL config exists
) else (
    echo [ERROR] SSL config NOT found
)

echo.
echo [CHECK 5] SSL config has port 8443
findstr /i "8443" "C:\nginx\conf.d\admin-ssl.conf" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] SSL config has port 8443
) else (
    echo [ERROR] SSL config does NOT have port 8443
)

echo.
echo [CHECK 6] SSL certificates exist
if exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [OK] SSL certificate exists
) else (
    echo [ERROR] SSL certificate NOT found
)

if exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [OK] SSL private key exists
) else (
    echo [ERROR] SSL private key NOT found
)

echo.
echo ========================================
echo Quick Fix
echo ========================================
echo.

:: Check if nginx.conf includes conf.d
findstr /i "conf.d" "C:\nginx\conf\nginx.conf" >nul 2>&1
if %errorlevel% neq 0 (
    echo [FIX] Adding conf.d include to nginx.conf...
    copy "C:\nginx\conf\nginx.conf" "C:\nginx\conf\nginx.conf.backup" >nul
    powershell -Command "(Get-Content 'C:\nginx\conf\nginx.conf') -replace '(http\s*\{)', '$1`n    include conf.d/*.conf;' | Set-Content 'C:\nginx\conf\nginx.conf'"
    echo [OK] Added conf.d include to nginx.conf
    
    :: Restart nginx
    echo [FIX] Restarting nginx...
    taskkill /f /im nginx.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
    cd /d C:\nginx
    start "Nginx" nginx.exe
    timeout /t 3 /nobreak >nul
    cd /d "%~dp0"
    
    :: Check port 8443 again
    netstat -an | find ":8443 " >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Port 8443 is now listening
    ) else (
        echo [ERROR] Port 8443 is still not listening
    )
)

echo.
echo ========================================
echo Final Status
echo ========================================
echo.

tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx: RUNNING
) else (
    echo [ERROR] nginx: NOT RUNNING
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443: LISTENING
) else (
    echo [ERROR] Port 8443: NOT LISTENING
)

echo.
echo If port 8443 is still not listening, run:
echo   check-nginx-ssl-loading.bat
echo.
echo Press any key to exit...
pause >nul
