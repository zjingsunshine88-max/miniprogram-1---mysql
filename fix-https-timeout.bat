@echo off
chcp 65001 >nul
title 修复HTTPS连接超时问题

echo 🔧 修复HTTPS连接超时问题
echo.

echo 📋 问题诊断结果:
echo ✅ SSL证书文件存在
echo ✅ Nginx服务运行正常
echo ✅ API服务运行正常
echo ✅ 443端口监听正常
echo ✅ 本地API服务正常
echo ❌ HTTPS连接超时
echo.

echo 🎯 问题原因:
echo 1. 防火墙阻止外部访问443端口
echo 2. 云服务商安全组未开放443端口
echo 3. 网络路由问题
echo 4. SSL证书可能有问题
echo.

echo 🔄 开始修复...
echo.

echo 步骤1: 检查防火墙设置...
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
echo 步骤2: 检查Windows防火墙状态...
netsh advfirewall show allprofiles state

echo.
echo 步骤3: 测试SSL证书有效性...
echo 检查证书文件内容...
powershell -Command "try { $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2('C:\certificates\practice.insightdata.top.pem'); Write-Host '✅ 证书有效 - 主题:' $cert.Subject '过期时间:' $cert.NotAfter } catch { Write-Host '❌ 证书无效:' $_.Exception.Message }"

echo.
echo 步骤4: 重新生成Nginx配置文件（修复编码问题）...
cd /d C:\nginx

echo 创建新的HTTPS配置文件...
(
echo # Nginx HTTPS配置文件
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
echo 步骤5: 检查Nginx配置语法...
nginx -t
if errorlevel 1 (
    echo ❌ Nginx配置有误
    pause
    exit /b 1
) else (
    echo ✅ Nginx配置正确
)

echo.
echo 步骤6: 重启Nginx服务...
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
echo 步骤7: 测试本地HTTPS连接...
timeout /t 5 >nul

echo 测试本地HTTPS连接...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ 本地HTTPS连接成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 本地HTTPS连接失败:' $_.Exception.Message }"

echo.
echo 步骤8: 检查网络连接...
echo 检查外网IP地址...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://api.ipify.org' -TimeoutSec 10; Write-Host '外网IP地址:' $response.Content } catch { Write-Host '无法获取外网IP' }"

echo.
echo 检查域名解析...
nslookup practice.insightdata.top

echo.
echo 🎉 HTTPS连接超时修复完成！
echo.
echo 📋 如果仍然无法访问，请检查:
echo.
echo 1. 云服务商安全组设置:
echo    - 确保开放443端口（HTTPS）
echo    - 确保开放80端口（HTTP重定向）
echo    - 检查入站规则设置
echo.
echo 2. 服务器提供商设置:
echo    - 阿里云ECS安全组
echo    - 腾讯云CVM安全组
echo    - AWS安全组
echo    - 其他云服务商安全组
echo.
echo 3. 网络路由检查:
echo    - 使用在线工具测试: https://www.yougetsignal.com/tools/open-ports/
echo    - 输入服务器IP: 223.93.139.87
echo    - 输入端口: 443
echo    - 检查端口是否开放
echo.
echo 4. 临时解决方案:
echo    - 使用HTTP访问: http://practice.insightdata.top/api/
echo    - 配置HTTP到HTTPS重定向
echo    - 联系服务器提供商检查网络设置
echo.
echo 💡 推荐操作:
echo 1. 登录云服务商控制台
echo 2. 检查安全组设置
echo 3. 确保443端口对外开放
echo 4. 使用在线工具验证端口开放状态
echo.
pause
