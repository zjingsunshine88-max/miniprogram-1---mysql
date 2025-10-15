@echo off
chcp 65001 >nul
echo ========================================
echo Test SSL Certificates
echo ========================================
echo.

echo [STEP 1] Check SSL certificate file
echo ========================================
if exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [OK] SSL certificate file exists
    echo [INFO] Certificate file details:
    dir "C:\certificates\admin.practice.insightdata.top.pem"
    
    echo [INFO] Certificate file content (first 10 lines):
    echo ----------------------------------------
    type "C:\certificates\admin.practice.insightdata.top.pem" | head -10
    echo ----------------------------------------
    
    echo [INFO] Certificate file content (last 10 lines):
    echo ----------------------------------------
    type "C:\certificates\admin.practice.insightdata.top.pem" | tail -10
    echo ----------------------------------------
) else (
    echo [ERROR] SSL certificate file not found
    goto :end
)

echo.
echo [STEP 2] Check SSL private key file
echo ========================================
if exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [OK] SSL private key file exists
    echo [INFO] Private key file details:
    dir "C:\certificates\admin.practice.insightdata.top.key"
    
    echo [INFO] Private key file content (first 10 lines):
    echo ----------------------------------------
    type "C:\certificates\admin.practice.insightdata.top.key" | head -10
    echo ----------------------------------------
    
    echo [INFO] Private key file content (last 10 lines):
    echo ----------------------------------------
    type "C:\certificates\admin.practice.insightdata.top.key" | tail -10
    echo ----------------------------------------
) else (
    echo [ERROR] SSL private key file not found
    goto :end
)

echo.
echo [STEP 3] Test SSL certificate with OpenSSL (if available)
echo ========================================
where openssl >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] OpenSSL is available
    echo [INFO] Testing SSL certificate...
    openssl x509 -in "C:\certificates\admin.practice.insightdata.top.pem" -text -noout
    if %errorlevel% equ 0 (
        echo [OK] SSL certificate is valid
    ) else (
        echo [ERROR] SSL certificate is invalid or corrupted
    )
) else (
    echo [WARNING] OpenSSL not available, skipping certificate validation
)

echo.
echo [STEP 4] Check certificate file permissions
echo ========================================
echo [INFO] Checking certificate file permissions...
icacls "C:\certificates\admin.practice.insightdata.top.pem"
if %errorlevel% equ 0 (
    echo [OK] Certificate file permissions retrieved
) else (
    echo [WARNING] Could not retrieve certificate file permissions
)

echo [INFO] Checking private key file permissions...
icacls "C:\certificates\admin.practice.insightdata.top.key"
if %errorlevel% equ 0 (
    echo [OK] Private key file permissions retrieved
) else (
    echo [WARNING] Could not retrieve private key file permissions
)

echo.
echo [STEP 5] Test nginx with different SSL configuration
echo ========================================
echo [INFO] Creating test SSL configuration with different settings...
(
echo # Test SSL configuration
echo server {
echo     listen 9443 ssl;
echo     server_name localhost;
echo.
echo     ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo     ssl_protocols TLSv1.2;
echo     ssl_ciphers HIGH:!aNULL:!MD5;
echo.
echo     location / {
echo         return 200 "Test SSL Server";
echo         add_header Content-Type text/plain;
echo     }
echo }
) > "C:\nginx\conf.d\test-ssl-9443.conf"

echo [OK] Created test SSL configuration on port 9443

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
    echo [INFO] SSL server is working on port 9443
) else (
    echo [ERROR] Port 9443 is not listening
    echo [INFO] SSL server is not working
)

echo.
echo [STEP 6] Check nginx SSL module
echo ========================================
echo [INFO] Checking nginx SSL module...
C:\nginx\nginx.exe -V
if %errorlevel% equ 0 (
    echo [OK] nginx version information retrieved
) else (
    echo [ERROR] Could not retrieve nginx version information
)

echo.
echo ========================================
echo SSL Certificate Test Complete
echo ========================================
echo.
echo Summary:
echo - SSL certificate file: %errorlevel% (0=OK, 1=ERROR)
echo - SSL private key file: %errorlevel% (0=OK, 1=ERROR)
echo - nginx SSL configuration: %errorlevel% (0=OK, 1=ERROR)
echo.
echo If SSL certificates are valid but nginx still doesn't listen on 8443:
echo 1. Try using port 9443 (test configuration created)
echo 2. Check if nginx SSL module is compiled
echo 3. Check Windows firewall settings
echo 4. Try a different nginx version
echo.

:end
echo Press any key to exit...
pause >nul
