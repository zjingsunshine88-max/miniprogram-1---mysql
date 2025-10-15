@echo off
chcp 65001 >nul
echo ========================================
echo Check Built API Configuration
echo ========================================
echo.

echo [STEP 1] Check built files in admin/dist
echo ========================================
if exist "admin\dist" (
    echo [OK] admin\dist directory exists
    echo [INFO] Contents of admin\dist:
    dir admin\dist /b
    
    if exist "admin\dist\index.html" (
        echo [OK] index.html exists in dist
    ) else (
        echo [ERROR] index.html not found in dist
    )
    
    if exist "admin\dist\assets" (
        echo [OK] assets directory exists in dist
        echo [INFO] Contents of assets:
        dir admin\dist\assets /b
    ) else (
        echo [ERROR] assets directory not found in dist
    )
) else (
    echo [ERROR] admin\dist directory not found
    echo [INFO] Please build the admin project first
    goto :end
)

echo.
echo [STEP 2] Check for API URLs in built files
echo ========================================
echo [INFO] Searching for API URLs in built files...

:: Search for old API URL
findstr /s /i "223.93.139.87" "admin\dist\*" >nul 2>&1
if %errorlevel% equ 0 (
    echo [ERROR] Found old API URL (223.93.139.87) in built files
    echo [INFO] Files containing old API URL:
    findstr /s /i "223.93.139.87" "admin\dist\*"
) else (
    echo [OK] No old API URL found in built files
)

:: Search for new API URL
findstr /s /i "practice.insightdate.top" "admin\dist\*" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Found new API URL (practice.insightdate.top) in built files
    echo [INFO] Files containing new API URL:
    findstr /s /i "practice.insightdate.top" "admin\dist\*"
) else (
    echo [ERROR] New API URL not found in built files
)

echo.
echo [STEP 3] Check deployed files in C:\admin
echo ========================================
if exist "C:\admin" (
    echo [OK] C:\admin directory exists
    echo [INFO] Contents of C:\admin:
    dir C:\admin /b
    
    if exist "C:\admin\index.html" (
        echo [OK] index.html exists in C:\admin
    ) else (
        echo [ERROR] index.html not found in C:\admin
    )
) else (
    echo [ERROR] C:\admin directory not found
)

echo.
echo [STEP 4] Check for API URLs in deployed files
echo ========================================
echo [INFO] Searching for API URLs in deployed files...

:: Search for old API URL in deployed files
findstr /s /i "223.93.139.87" "C:\admin\*" >nul 2>&1
if %errorlevel% equ 0 (
    echo [ERROR] Found old API URL (223.93.139.87) in deployed files
    echo [INFO] Files containing old API URL:
    findstr /s /i "223.93.139.87" "C:\admin\*"
) else (
    echo [OK] No old API URL found in deployed files
)

:: Search for new API URL in deployed files
findstr /s /i "practice.insightdate.top" "C:\admin\*" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Found new API URL (practice.insightdate.top) in deployed files
    echo [INFO] Files containing new API URL:
    findstr /s /i "practice.insightdate.top" "C:\admin\*"
) else (
    echo [ERROR] New API URL not found in deployed files
)

echo.
echo [STEP 5] Check browser cache
echo ========================================
echo [INFO] Browser cache may contain old files
echo [INFO] Please clear browser cache completely:
echo   1. Press Ctrl+Shift+Delete
echo   2. Select "All time" or "Everything"
echo   3. Check all boxes
echo   4. Click "Clear data"
echo   5. Close and reopen browser
echo   6. Reload the admin page

echo.
echo [STEP 6] Check nginx serving correct files
echo ========================================
echo [INFO] Checking if nginx is serving the correct files...
if exist "C:\admin\index.html" (
    echo [OK] nginx should be serving C:\admin\index.html
) else (
    echo [ERROR] nginx cannot serve C:\admin\index.html (file not found)
)

echo.
echo ========================================
echo Check Complete
echo ========================================
echo.
echo Summary:
echo - Built files: %errorlevel% (0=OK, 1=ERROR)
echo - Deployed files: %errorlevel% (0=OK, 1=ERROR)
echo - Old API URL found: %errorlevel% (0=YES, 1=NO)
echo - New API URL found: %errorlevel% (0=YES, 1=NO)
echo.
echo If old API URL is still found:
echo 1. Run: force-fix-api-url.bat
echo 2. Clear browser cache completely
echo 3. Reload the page
echo.

:end
echo Press any key to exit...
pause >nul
