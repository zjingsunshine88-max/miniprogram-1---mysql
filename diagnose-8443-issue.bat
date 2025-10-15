@echo off
chcp 65001 >nul
echo ========================================
echo Diagnose 8443 Port Issue
echo ========================================
echo.

echo [STEP 1] Check nginx process status
echo ========================================
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx process is running
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] nginx process is NOT running
    echo [REASON] nginx failed to start due to configuration errors
    goto :check_config
)

echo.
echo [STEP 2] Check port 8443 listening status
echo ========================================
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
    netstat -ano | find ":8443 "
) else (
    echo [ERROR] Port 8443 is NOT listening
    echo [REASON] nginx configuration does not include port 8443
    goto :check_config
)

echo.
echo [STEP 3] Check nginx configuration files
echo ========================================
:check_config
echo [INFO] Checking nginx configuration files...

if exist "C:\nginx\conf\nginx.conf" (
    echo [OK] nginx.conf exists
    echo [INFO] Checking if nginx.conf includes conf.d:
    findstr /i "conf.d" "C:\nginx\conf\nginx.conf"
    if %errorlevel% neq 0 (
        echo [ERROR] nginx.conf does NOT include conf.d/*.conf
        echo [REASON] This is why port 8443 is not configured
    )
) else (
    echo [ERROR] nginx.conf NOT found
    echo [REASON] nginx cannot start without main configuration file
)

echo.
echo [STEP 4] Check SSL configuration file
echo ========================================
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] admin-ssl.conf exists
    echo [INFO] Checking port 8443 configuration:
    findstr /i "8443" "C:\nginx\conf.d\admin-ssl.conf"
    if %errorlevel% neq 0 (
        echo [ERROR] Port 8443 NOT found in admin-ssl.conf
        echo [REASON] SSL configuration does not include port 8443
    ) else (
        echo [OK] Port 8443 found in SSL configuration
    )
) else (
    echo [ERROR] admin-ssl.conf NOT found
    echo [REASON] No SSL configuration file exists
)

echo.
echo [STEP 5] Check for problematic configuration files
echo ========================================
echo [INFO] Checking for problematic .conf files...

:: Check conf.d directory
if exist "C:\nginx\conf.d" (
    echo [INFO] conf.d directory contents:
    dir C:\nginx\conf.d /b
    
    for %%f in (C:\nginx\conf.d\*.conf) do (
        echo [INFO] Checking file: %%f
        findstr /i "" "%%f" >nul 2>&1
        if %errorlevel% equ 0 (
            echo [ERROR] Found problematic characters in %%f
            echo [REASON] This file contains encoding issues
        )
    )
) else (
    echo [WARNING] conf.d directory not found
)

:: Check conf directory for other .conf files
if exist "C:\nginx\conf" (
    echo [INFO] conf directory contents:
    dir C:\nginx\conf /b
    
    for %%f in (C:\nginx\conf\*.conf) do (
        if not "%%f"=="C:\nginx\conf\nginx.conf" (
            echo [INFO] Checking file: %%f
            findstr /i "" "%%f" >nul 2>&1
            if %errorlevel% equ 0 (
                echo [ERROR] Found problematic characters in %%f
                echo [REASON] This file contains encoding issues
            )
        )
    )
)

echo.
echo [STEP 6] Check nginx error log
echo ========================================
if exist "C:\nginx\logs\error.log" (
    echo [INFO] Recent nginx errors:
    echo ----------------------------------------
    type C:\nginx\logs\error.log
    echo ----------------------------------------
    
    :: Check for specific error patterns
    findstr /i "8443" "C:\nginx\logs\error.log" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] Found 8443-related errors in log
        findstr /i "8443" "C:\nginx\logs\error.log"
    )
    
    findstr /i "unknown directive" "C:\nginx\logs\error.log" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [ERROR] Found unknown directive errors
        echo [REASON] Configuration files contain invalid syntax
        findstr /i "unknown directive" "C:\nginx\logs\error.log"
    )
) else (
    echo [WARNING] nginx error log not found
)

echo.
echo [STEP 7] Test nginx configuration
echo ========================================
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
    echo [REASON] Configuration files contain errors
)
cd /d "%~dp0"

echo.
echo [STEP 8] Check SSL certificates
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
echo ========================================
echo Root Cause Analysis
echo ========================================
echo.

:: Analyze the most likely causes
echo [ANALYSIS] Most likely reasons why port 8443 is not listening:
echo.

:: Check if nginx is running
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% neq 0 (
    echo [CAUSE 1] nginx process is not running
    echo [REASON] Configuration errors prevent nginx from starting
    echo [SOLUTION] Fix configuration files and restart nginx
    echo.
)

:: Check if port 8443 is configured
findstr /i "8443" "C:\nginx\conf.d\admin-ssl.conf" >nul 2>&1
if %errorlevel% neq 0 (
    echo [CAUSE 2] Port 8443 not configured in nginx
    echo [REASON] SSL configuration file missing or incorrect
    echo [SOLUTION] Create or fix admin-ssl.conf file
    echo.
)

:: Check for problematic files
for %%f in (C:\nginx\conf.d\*.conf) do (
    findstr /i "" "%%f" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [CAUSE 3] Configuration file contains encoding issues
        echo [REASON] File %%f has problematic characters
        echo [SOLUTION] Delete or recreate this file
        echo.
    )
)

:: Check if nginx.conf includes conf.d
findstr /i "conf.d" "C:\nginx\conf\nginx.conf" >nul 2>&1
if %errorlevel% neq 0 (
    echo [CAUSE 4] nginx.conf does not include conf.d
    echo [REASON] SSL configuration files are not loaded
    echo [SOLUTION] Add 'include conf.d/*.conf;' to nginx.conf
    echo.
)

echo ========================================
echo Recommended Solutions
echo ========================================
echo.
echo [SOLUTION 1] Clean all configuration files:
echo    Run: clean-nginx-configs.bat
echo.
echo [SOLUTION 2] Fix encoding issues:
echo    Run: fix-nginx-encoding.bat
echo.
echo [SOLUTION 3] Create minimal configuration:
echo    Run: create-minimal-nginx.bat
echo.
echo [SOLUTION 4] Manual fix:
echo    1. Delete all .conf files in C:\nginx\conf.d
echo    2. Delete all .conf files in C:\nginx\conf (except nginx.conf)
echo    3. Recreate admin-ssl.conf with port 8443
echo    4. Restart nginx
echo.
echo Press any key to exit...
pause >nul
