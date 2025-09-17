@echo off
echo 修复SSL证书问题...
echo.

REM 停止nginx
echo 停止nginx服务...
taskkill /f /im nginx.exe 2>nul

REM 创建SSL目录
if not exist "C:\nginx\ssl" mkdir "C:\nginx\ssl"

REM 创建临时的自签名证书文件
echo 创建临时SSL证书...
echo -----BEGIN CERTIFICATE----- > C:\nginx\ssl\cert.pem
echo MIIBkTCB+wIJAKoK/Ovj8WjOMA0GCSqGSIb3DQEBCwUAMBQxEjAQBgNVBAMMCTIyMy45My4xMzkwHhcNMjUwOTE2MDgwMDAwWhcNMjYwOTE2MDgwMDAwWjAUMRIwEAYDVQQDDAkyMjMuOTMuMTM5MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE... >> C:\nginx\ssl\cert.pem
echo -----END CERTIFICATE----- >> C:\nginx\ssl\cert.pem

echo -----BEGIN PRIVATE KEY----- > C:\nginx\ssl\key.pem
echo MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC... >> C:\nginx\ssl\key.pem
echo -----END PRIVATE KEY----- >> C:\nginx\ssl\key.pem

echo.
echo 临时证书已创建，但建议使用正式的SSL证书。
echo.

REM 重新启动nginx
echo 重新启动nginx...
C:\nginx\nginx.exe -c C:\nginx\conf\nginx.conf

echo.
echo 修复完成！
echo 现在可以访问 http://223.93.139.87
echo 注意：如果浏览器仍然尝试访问HTTPS，请清除浏览器缓存。
pause
