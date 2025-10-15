@echo off
chcp 65001 >nul
echo ========================================
echo Test External Access to admin.practice.insightdata.top:8443
echo ========================================
echo.

echo [TEST 1] Check DNS resolution
echo ========================================
echo [INFO] Testing DNS resolution for admin.practice.insightdata.top
nslookup admin.practice.insightdata.top
if %errorlevel% equ 0 (
    echo [OK] DNS resolution successful
) else (
    echo [ERROR] DNS resolution failed
)

echo.
echo [TEST 2] Test external HTTPS access
echo ========================================
echo [INFO] Testing https://admin.practice.insightdata.top:8443
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://admin.practice.insightdata.top:8443' -TimeoutSec 15 -SkipCertificateCheck; Write-Host '[OK] External HTTPS access successful - Status:' $response.StatusCode } catch { Write-Host '[ERROR] External HTTPS access failed:' $_.Exception.Message }"

echo.
echo [TEST 3] Test external HTTP access
echo ========================================
echo [INFO] Testing http://admin.practice.insightdata.top
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://admin.practice.insightdata.top' -TimeoutSec 15; Write-Host '[OK] External HTTP access successful - Status:' $response.StatusCode } catch { Write-Host '[ERROR] External HTTP access failed:' $_.Exception.Message }"

echo.
echo [TEST 4] Check local server configuration
echo ========================================
echo [INFO] Checking if nginx is configured for external access
findstr /i "server_name" "C:\nginx\conf.d\admin-ssl.conf"
if %errorlevel% equ 0 (
    echo [OK] server_name configuration found
) else (
    echo [ERROR] server_name configuration NOT found
)

echo.
echo [TEST 5] Check firewall status
echo ========================================
echo [INFO] Checking Windows Firewall status
netsh advfirewall show allprofiles state
if %errorlevel% equ 0 (
    echo [OK] Firewall status retrieved
) else (
    echo [WARNING] Could not retrieve firewall status
)

echo.
echo [TEST 6] Check if ports are open in firewall
echo ========================================
echo [INFO] Checking firewall rules for port 8443
netsh advfirewall firewall show rule name=all | findstr /i "8443"
if %errorlevel% equ 0 (
    echo [OK] Firewall rules for port 8443 found
) else (
    echo [WARNING] No firewall rules found for port 8443
    echo [INFO] You may need to add firewall rules for port 8443
)

echo.
echo [TEST 7] Check network connectivity
echo ========================================
echo [INFO] Testing basic network connectivity
ping -n 4 8.8.8.8
if %errorlevel% equ 0 (
    echo [OK] Network connectivity is working
) else (
    echo [ERROR] Network connectivity issues
)

echo.
echo ========================================
echo External Access Test Summary
echo ========================================
echo.
echo Common issues preventing external access:
echo 1. nginx not running or not listening on port 8443
echo 2. Firewall blocking port 8443
echo 3. DNS not pointing to this server
echo 4. nginx server_name not configured correctly
echo 5. SSL certificate issues
echo.
echo Solutions:
echo 1. Run: test-8443-port.bat (check local nginx)
echo 2. Run: check-nginx-status.bat (full status check)
echo 3. Add firewall rule for port 8443
echo 4. Check DNS configuration
echo 5. Verify SSL certificate
echo.
echo Press any key to exit...
pause >nul
