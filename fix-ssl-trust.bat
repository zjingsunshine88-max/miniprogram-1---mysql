@echo off
chcp 65001 >nul
title 修复SSL证书信任问题

echo 🔐 修复SSL证书信任问题
echo.

echo 📋 当前问题: SSL证书不被浏览器信任
echo 💡 解决方案: 配置浏览器信任自签名证书
echo.

echo 📋 方案1: 浏览器中添加安全例外
echo.
echo 1. 在浏览器中访问: https://practice.insightdata.top/
echo 2. 点击"高级"或"Advanced"
echo 3. 点击"继续访问"或"Proceed to practice.insightdata.top"
echo 4. 添加安全例外
echo.

echo 📋 方案2: 使用HTTP访问（推荐用于开发）
echo.
echo 当前可用的HTTP访问:
echo - 管理后台: http://practice.insightdata.top/
echo - API接口: http://practice.insightdata.top/api/
echo - 健康检查: http://practice.insightdata.top/health
echo.

echo 📋 方案3: 创建HTTP版本的Nginx配置
echo.
echo 正在创建HTTP配置...

REM 创建HTTP配置
echo # HTTP配置用于开发环境 > C:\nginx\conf\http-dev.conf
echo server { >> C:\nginx\conf\http-dev.conf
echo     listen 80; >> C:\nginx\conf\http-dev.conf
echo     server_name practice.insightdata.top 223.93.139.87; >> C:\nginx\conf\http-dev.conf
echo. >> C:\nginx\conf\http-dev.conf
echo     # API代理 >> C:\nginx\conf\http-dev.conf
echo     location /api/ { >> C:\nginx\conf\http-dev.conf
echo         proxy_pass http://localhost:3002/api/; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header Host $host; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Real-IP $remote_addr; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Forwarded-Proto $scheme; >> C:\nginx\conf\http-dev.conf
echo     } >> C:\nginx\conf\http-dev.conf
echo. >> C:\nginx\conf\http-dev.conf
echo     # 健康检查 >> C:\nginx\conf\http-dev.conf
echo     location /health { >> C:\nginx\conf\http-dev.conf
echo         proxy_pass http://localhost:3002/health; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header Host $host; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Real-IP $remote_addr; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Forwarded-Proto $scheme; >> C:\nginx\conf\http-dev.conf
echo     } >> C:\nginx\conf\http-dev.conf
echo. >> C:\nginx\conf\http-dev.conf
echo     # 静态文件代理 >> C:\nginx\conf\http-dev.conf
echo     location /uploads/ { >> C:\nginx\conf\http-dev.conf
echo         proxy_pass http://localhost:3002/uploads/; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header Host $host; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Real-IP $remote_addr; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >> C:\nginx\conf\http-dev.conf
echo         proxy_set_header X-Forwarded-Proto $scheme; >> C:\nginx\conf\http-dev.conf
echo     } >> C:\nginx\conf\http-dev.conf
echo. >> C:\nginx\conf\http-dev.conf
echo     # 管理后台静态文件 >> C:\nginx\conf\http-dev.conf
echo     location / { >> C:\nginx\conf\http-dev.conf
echo         root C:/admin/dist; >> C:\nginx\conf\http-dev.conf
echo         index index.html; >> C:\nginx\conf\http-dev.conf
echo         try_files $uri $uri/ /index.html; >> C:\nginx\conf\http-dev.conf
echo     } >> C:\nginx\conf\http-dev.conf
echo } >> C:\nginx\conf\http-dev.conf

echo ✅ HTTP配置已创建

echo.
echo 📋 更新Nginx主配置...
echo 正在添加HTTP配置到主配置文件...

REM 备份原配置
copy "C:\nginx\conf\nginx.conf" "C:\nginx\conf\nginx.conf.backup"

REM 添加HTTP配置
echo. >> C:\nginx\conf\nginx.conf
echo     # 包含HTTP开发配置 >> C:\nginx\conf\nginx.conf
echo     include http-dev.conf; >> C:\nginx\conf\nginx.conf

echo ✅ Nginx配置已更新

echo.
echo 📋 重启Nginx...
nginx -s reload

if errorlevel 1 (
    echo ❌ Nginx重启失败
    echo 💡 请检查配置文件语法
    pause
    exit /b 1
) else (
    echo ✅ Nginx重启成功
)

echo.
echo 🎉 HTTP配置完成！
echo.
echo 📋 现在可以使用HTTP访问:
echo - 管理后台: http://practice.insightdata.top/
echo - API接口: http://practice.insightdata.top/api/
echo - 健康检查: http://practice.insightdata.top/health
echo.
echo 📋 测试访问:
echo.
echo 正在测试HTTP访问...

curl -s http://practice.insightdata.top/health >nul
if errorlevel 1 (
    echo ❌ HTTP访问测试失败
) else (
    echo ✅ HTTP访问测试成功
)

echo.
echo 💡 建议:
echo 1. 开发阶段使用HTTP访问
echo 2. 生产环境建议使用有效SSL证书
echo 3. 可以使用在线工具生成免费证书
echo.
echo 按任意键退出...
pause >nul
