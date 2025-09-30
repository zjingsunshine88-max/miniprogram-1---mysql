@echo off
chcp 65001 >nul
title 修复Nginx配置文件

echo 🔧 修复Nginx配置文件
echo.

echo 📋 问题诊断:
echo ❌ Nginx配置文件包含错误的ECHO指令
echo ❌ 配置文件编码有问题
echo ❌ 需要重新生成干净的配置文件
echo.

echo 🔄 开始修复...
echo.

echo 步骤1: 备份当前配置文件...
cd /d C:\nginx
if exist "conf\practice.insightdata.top.conf.backup" del "conf\practice.insightdata.top.conf.backup"
if exist "conf\practice.insightdata.top.conf" (
    copy "conf\practice.insightdata.top.conf" "conf\practice.insightdata.top.conf.backup"
    echo ✅ 原配置文件已备份
)

echo.
echo 步骤2: 创建干净的Nginx配置文件...
(
echo # Nginx HTTPS配置文件
echo # 保存为: C:\nginx\conf\practice.insightdata.top.conf
echo.
echo # HTTPS配置
echo server {
echo     listen 443 ssl;
echo     server_name practice.insightdata.top;
echo     
echo     # SSL证书配置
echo     ssl_certificate C:/certificates/practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/practice.insightdata.top.key;
echo     
echo     # SSL安全配置
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
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
    echo ❌ Nginx配置仍有误
    echo 显示错误信息:
    nginx -t
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

echo 测试本地HTTPS连接...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ 本地HTTPS连接成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 本地HTTPS连接失败:' $_.Exception.Message }"

echo.
echo 步骤6: 检查服务状态...
echo 检查Nginx进程...
tasklist | findstr nginx.exe
if errorlevel 1 (
    echo ❌ Nginx未运行
) else (
    echo ✅ Nginx运行正常
)

echo.
echo 检查443端口监听...
netstat -an | findstr :443 | findstr LISTENING
if errorlevel 1 (
    echo ❌ 443端口未监听
) else (
    echo ✅ 443端口正在监听
)

echo.
echo 🎉 Nginx配置文件修复完成！
echo.
echo 📋 测试访问地址:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
echo 💡 如果仍然无法访问，请检查:
echo 1. 云服务商安全组是否开放443端口
echo 2. 防火墙是否允许443端口
echo 3. 域名解析是否正确
echo 4. SSL证书是否有效
echo.
pause
