@echo off
chcp 65001 >nul
echo ========================================
echo Rebuild Admin Project
echo ========================================
echo.

echo [STEP 1] Check admin directory
echo ========================================
if not exist "admin" (
    echo [ERROR] admin directory not found
    pause
    exit /b 1
)

echo [OK] admin directory exists
cd admin

echo.
echo [STEP 2] Install dependencies
echo ========================================
if not exist "node_modules" (
    echo [INFO] Installing dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install dependencies
        cd ..
        pause
        exit /b 1
    )
) else (
    echo [OK] Dependencies already installed
)

echo.
echo [STEP 3] Build admin project
echo ========================================
echo [INFO] Building admin project...
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build admin project
    cd ..
    pause
    exit /b 1
)

echo [OK] Admin project built successfully
cd ..

echo.
echo [STEP 4] Deploy to C:\admin
echo ========================================
echo [INFO] Deploying to C:\admin...

if exist "admin\dist" (
    if exist "C:\admin" (
        echo [INFO] Clearing C:\admin directory...
        del /q "C:\admin\*" >nul 2>&1
    ) else (
        echo [INFO] Creating C:\admin directory...
        mkdir "C:\admin"
    )
    
    echo [INFO] Copying files...
    xcopy "admin\dist\*" "C:\admin\" /E /Y /Q
    if %errorlevel% equ 0 (
        echo [OK] Files deployed successfully
    ) else (
        echo [ERROR] Failed to deploy files
    )
) else (
    echo [ERROR] admin\dist directory not found
)

echo.
echo [STEP 5] Check deployment
echo ========================================
if exist "C:\admin\index.html" (
    echo [OK] Deployment successful: C:\admin\index.html exists
) else (
    echo [ERROR] Deployment failed: C:\admin\index.html not found
)

echo.
echo ========================================
echo Rebuild Complete
echo ========================================
echo.
echo Next steps:
echo 1. Clear browser cache (Ctrl+F5)
echo 2. Reload the admin page
echo 3. Check browser developer tools to verify API calls
echo.
echo Press any key to exit...
pause >nul
