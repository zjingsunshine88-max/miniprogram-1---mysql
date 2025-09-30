@echo off
chcp 65001 >nul
title 修复HTTPS访问问题

echo 🔧 修复HTTPS访问问题
echo.

echo 📋 问题诊断:
echo ✅ SSL证书文件存在
echo ✅ Nginx服务运行正常
echo ✅ API服务运行正常
echo ✅ 443端口监听正常
echo ❌ HTTPS访问失败
echo.

echo 🎯 可能的原因:
echo 1. SSL证书文件损坏或格式错误
echo 2. Nginx配置编码问题
echo 3. 证书文件路径不正确
echo 4. 防火墙阻止外部访问
echo.

echo 🔄 开始修复...
echo.

echo 步骤1: 检查SSL证书文件...
if exist "C:\certificates\practice.insightdata.top.pem" (
    echo ✅ 证书文件存在
    for %%i in ("C:\certificates\practice.insightdata.top.pem") do echo 文件大小: %%~zi 字节
) else (
    echo ❌ 证书文件不存在
    echo 💡 请先运行SSL证书生成脚本
    pause
    exit /b 1
)

if exist "C:\certificates\practice.insightdata.top.key" (
    echo ✅ 私钥文件存在
    for %%i in ("C:\certificates\practice.insightdata.top.key") do echo 文件大小: %%~zi 字节
) else (
    echo ❌ 私钥文件不存在
    echo 💡 请先运行SSL证书生成脚本
    pause
    exit /b 1
)

echo.
echo 步骤2: 重新生成Nginx配置文件...
cd /d C:\nginx

echo 创建新的HTTPS配置文件...
(
echo # Nginx HTTPS配置文件
echo # 保存为: C:\nginx\conf\practice.insightdata.top.conf
echo.
echo # HTTPS配置
echo server {
echo     listen 443 ssl http2;
echo     server_name practice.insightdata.top;
echo     
echo     # SSL证书配置
echo     ssl_certificate C:/certificates/practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/practice.insightdata.top.key;
echo     
echo     # SSL安全配置
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
echo     ssl_prefer_server_ciphers on;
echo     ssl_session_cache shared:SSL:10m;
echo     ssl_session_timeout 10m;
echo     
echo     # 安全头
echo     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
echo     add_header X-Frame-Options DENY always;
echo     add_header X-Content-Type-Options nosniff always;
echo     add_header X-XSS-Protection "1; mode=block" always;
echo     add_header Referrer-Policy "strict-origin-when-cross-origin" always;
echo     
echo     # 日志配置
echo     access_log logs/practice.insightdata.top.access.log;
echo     error_log logs/practice.insightdata.top.error.log;
echo     
echo     # API代理配置
echo     location /api/ {
echo         proxy_pass http://localhost:3002/api/;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_connect_timeout 30s;
echo         proxy_send_timeout 30s;
echo         proxy_read_timeout 30s;
echo     }
echo     
echo     # 健康检查
echo     location /health {
echo         proxy_pass http://localhost:3002/health;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo     }
echo     
echo     # 静态文件
echo     location /uploads/ {
echo         proxy_pass http://localhost:3002/uploads/;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo     }
echo     
echo     # 管理后台
echo     location / {
echo         root C:/admin/dist;
echo         index index.html;
echo         try_files $uri $uri/ /index.html;
echo     }
echo }
echo.
echo # HTTP重定向到HTTPS
echo server {
echo     listen 80;
echo     server_name practice.insightdata.top;
echo     return 301 https://$server_name$request_uri;
echo }
) > conf\practice.insightdata.top.conf

echo ✅ 新的Nginx配置文件已创建

echo.
echo 步骤3: 检查Nginx配置语法...
nginx -t
if errorlevel 1 (
    echo ❌ Nginx配置有误
    echo 💡 请检查配置文件
    pause
    exit /b 1
) else (
    echo ✅ Nginx配置正确
)

echo.
echo 步骤4: 重启Nginx服务...
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
echo 步骤5: 测试HTTPS连接...
timeout /t 5 >nul

echo 测试本地连接...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ HTTPS连接成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTPS连接失败:' $_.Exception.Message }"

echo.
echo 步骤6: 检查防火墙设置...
echo 检查443端口防火墙规则...
netsh advfirewall firewall show rule name="HTTPS" >nul 2>&1
if errorlevel 1 (
    echo ❌ 443端口防火墙规则不存在
    echo 添加防火墙规则...
    netsh advfirewall firewall add rule name="HTTPS" dir=in action=allow protocol=TCP localport=443
    echo ✅ 防火墙规则已添加
) else (
    echo ✅ 443端口防火墙规则已存在
)

echo.
echo 🎉 HTTPS访问修复完成！
echo.
echo 📋 测试访问地址:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
echo 💡 如果仍然无法访问，请检查:
echo 1. 域名解析是否正确
echo 2. 服务器防火墙设置
echo 3. 云服务商安全组设置
echo.
pause
