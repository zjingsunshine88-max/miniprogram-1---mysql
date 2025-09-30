@echo off
chcp 65001 >nul
title 修复HTTPS代理问题

echo 🔧 修复HTTPS代理问题
echo.

echo 📋 问题诊断:
echo ✅ API服务正常运行: http://223.93.139.87:3002/api/
echo ✅ 服务器网络正常
echo ❌ HTTPS域名访问失败: https://practice.insightdata.top/api/
echo.

echo 🎯 问题原因:
echo 1. Nginx HTTPS代理配置问题
echo 2. SSL证书配置问题
echo 3. 域名解析问题
echo 4. 防火墙阻止HTTPS访问
echo.

echo 🔄 开始修复...
echo.

echo 步骤1: 检查域名解析...
nslookup practice.insightdata.top
echo.

echo 步骤2: 检查SSL证书文件...
if exist "C:\certificates\practice.insightdata.top.pem" (
    echo ✅ SSL证书文件存在
    for %%i in ("C:\certificates\practice.insightdata.top.pem") do echo 证书文件大小: %%~zi 字节
) else (
    echo ❌ SSL证书文件不存在
    echo 💡 请先运行SSL证书生成脚本
    pause
    exit /b 1
)

if exist "C:\certificates\practice.insightdata.top.key" (
    echo ✅ SSL私钥文件存在
    for %%i in ("C:\certificates\practice.insightdata.top.key") do echo 私钥文件大小: %%~zi 字节
) else (
    echo ❌ SSL私钥文件不存在
    echo 💡 请先运行SSL证书生成脚本
    pause
    exit /b 1
)

echo.
echo 步骤3: 创建正确的Nginx配置文件...
cd /d C:\nginx

echo 删除旧的配置文件...
if exist "conf\practice.insightdata.top.conf" del "conf\practice.insightdata.top.conf"

echo 创建新的HTTPS配置文件...
(
echo server {
echo     listen 443 ssl;
echo     server_name practice.insightdata.top;
echo     
echo     ssl_certificate C:/certificates/practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/practice.insightdata.top.key;
echo     
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
echo     ssl_prefer_server_ciphers on;
echo     
echo     location /api/ {
echo         proxy_pass http://localhost:3002/api/;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo     }
echo     
echo     location /health {
echo         proxy_pass http://localhost:3002/health;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo     }
echo     
echo     location / {
echo         root C:/admin/dist;
echo         index index.html;
echo         try_files $uri $uri/ /index.html;
echo     }
echo }
echo.
echo server {
echo     listen 80;
echo     server_name practice.insightdata.top;
echo     return 301 https://$server_name$request_uri;
echo }
) > conf\practice.insightdata.top.conf

echo ✅ 新的Nginx配置文件已创建

echo.
echo 步骤4: 检查Nginx配置语法...
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
echo 步骤5: 重启Nginx服务...
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
echo 步骤7: 测试HTTPS连接...
timeout /t 5 >nul

echo 测试本地HTTPS连接...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ 本地HTTPS连接成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 本地HTTPS连接失败:' $_.Exception.Message }"

echo.
echo 步骤8: 检查防火墙设置...
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
echo 🎉 HTTPS代理修复完成！
echo.
echo 📋 测试访问地址:
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo - 管理后台: https://practice.insightdata.top/
echo.
echo 💡 如果仍然无法访问，请检查:
echo 1. 云服务商安全组是否开放443端口
echo 2. 域名解析是否正确
echo 3. SSL证书是否有效
echo 4. 使用在线工具测试: https://www.yougetsignal.com/tools/open-ports/
echo.
echo 🌐 在线测试工具:
echo - 端口检查: https://www.yougetsignal.com/tools/open-ports/
echo - 域名解析: https://dnschecker.org/
echo - SSL证书检查: https://www.ssllabs.com/ssltest/
echo.
pause
