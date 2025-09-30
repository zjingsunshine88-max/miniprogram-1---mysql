@echo off
chcp 65001 >nul
title 创建干净的Nginx配置文件

echo 🔧 创建干净的Nginx配置文件
echo.

echo 📋 问题诊断:
echo ❌ 配置文件被ECHO指令污染
echo ❌ 需要创建完全干净的配置文件
echo.

echo 🔄 开始创建...
echo.

cd /d C:\nginx

echo 删除旧的配置文件...
if exist "conf\practice.insightdata.top.conf" del "conf\practice.insightdata.top.conf"

echo 创建新的配置文件...
echo # Nginx HTTPS配置文件 > conf\practice.insightdata.top.conf
echo # 保存为: C:\nginx\conf\practice.insightdata.top.conf >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo # HTTPS配置 >> conf\practice.insightdata.top.conf
echo server { >> conf\practice.insightdata.top.conf
echo     listen 443 ssl; >> conf\practice.insightdata.top.conf
echo     server_name practice.insightdata.top; >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # SSL证书配置 >> conf\practice.insightdata.top.conf
echo     ssl_certificate C:/certificates/practice.insightdata.top.pem; >> conf\practice.insightdata.top.conf
echo     ssl_certificate_key C:/certificates/practice.insightdata.top.key; >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # SSL安全配置 >> conf\practice.insightdata.top.conf
echo     ssl_protocols TLSv1.2 TLSv1.3; >> conf\practice.insightdata.top.conf
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384; >> conf\practice.insightdata.top.conf
echo     ssl_prefer_server_ciphers on; >> conf\practice.insightdata.top.conf
echo     ssl_session_cache shared:SSL:10m; >> conf\practice.insightdata.top.conf
echo     ssl_session_timeout 10m; >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # 安全头 >> conf\practice.insightdata.top.conf
echo     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always; >> conf\practice.insightdata.top.conf
echo     add_header X-Frame-Options DENY always; >> conf\practice.insightdata.top.conf
echo     add_header X-Content-Type-Options nosniff always; >> conf\practice.insightdata.top.conf
echo     add_header X-XSS-Protection "1; mode=block" always; >> conf\practice.insightdata.top.conf
echo     add_header Referrer-Policy "strict-origin-when-cross-origin" always; >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # 日志配置 >> conf\practice.insightdata.top.conf
echo     access_log logs/practice.insightdata.top.access.log; >> conf\practice.insightdata.top.conf
echo     error_log logs/practice.insightdata.top.error.log; >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # API代理配置 >> conf\practice.insightdata.top.conf
echo     location /api/ { >> conf\practice.insightdata.top.conf
echo         proxy_pass http://localhost:3002/api/; >> conf\practice.insightdata.top.conf
echo         proxy_set_header Host $host; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Real-IP $remote_addr; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Forwarded-Proto $scheme; >> conf\practice.insightdata.top.conf
echo         proxy_connect_timeout 30s; >> conf\practice.insightdata.top.conf
echo         proxy_send_timeout 30s; >> conf\practice.insightdata.top.conf
echo         proxy_read_timeout 30s; >> conf\practice.insightdata.top.conf
echo     } >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # 健康检查 >> conf\practice.insightdata.top.conf
echo     location /health { >> conf\practice.insightdata.top.conf
echo         proxy_pass http://localhost:3002/health; >> conf\practice.insightdata.top.conf
echo         proxy_set_header Host $host; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Real-IP $remote_addr; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Forwarded-Proto $scheme; >> conf\practice.insightdata.top.conf
echo     } >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # 静态文件 >> conf\practice.insightdata.top.conf
echo     location /uploads/ { >> conf\practice.insightdata.top.conf
echo         proxy_pass http://localhost:3002/uploads/; >> conf\practice.insightdata.top.conf
echo         proxy_set_header Host $host; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Real-IP $remote_addr; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >> conf\practice.insightdata.top.conf
echo         proxy_set_header X-Forwarded-Proto $scheme; >> conf\practice.insightdata.top.conf
echo     } >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo     # 管理后台 >> conf\practice.insightdata.top.conf
echo     location / { >> conf\practice.insightdata.top.conf
echo         root C:/admin/dist; >> conf\practice.insightdata.top.conf
echo         index index.html; >> conf\practice.insightdata.top.conf
echo         try_files $uri $uri/ /index.html; >> conf\practice.insightdata.top.conf
echo     } >> conf\practice.insightdata.top.conf
echo } >> conf\practice.insightdata.top.conf
echo. >> conf\practice.insightdata.top.conf
echo # HTTP重定向到HTTPS >> conf\practice.insightdata.top.conf
echo server { >> conf\practice.insightdata.top.conf
echo     listen 80; >> conf\practice.insightdata.top.conf
echo     server_name practice.insightdata.top; >> conf\practice.insightdata.top.conf
echo     return 301 https://$server_name$request_uri; >> conf\practice.insightdata.top.conf
echo } >> conf\practice.insightdata.top.conf

echo ✅ 新的Nginx配置文件已创建

echo.
echo 检查配置文件内容...
type conf\practice.insightdata.top.conf

echo.
echo 检查Nginx配置语法...
nginx -t
if errorlevel 1 (
    echo ❌ Nginx配置有误
    echo 显示错误信息:
    nginx -t
    pause
    exit /b 1
) else (
    echo ✅ Nginx配置正确
)

echo.
echo 重启Nginx服务...
nginx -s reload
if errorlevel 1 (
    echo 停止Nginx...
    taskkill /F /IM nginx.exe >nul 2>&1
    timeout /t 2 >nul
    echo 启动Nginx...
    start nginx.exe
    timeout /t 3 >nul
) else (
    echo ✅ Nginx重新加载成功
)

echo.
echo 测试HTTPS连接...
timeout /t 5 >nul
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ HTTPS连接成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTPS连接失败:' $_.Exception.Message }"

echo.
echo 🎉 Nginx配置文件创建完成！
echo.
echo 📋 测试访问地址:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
pause
