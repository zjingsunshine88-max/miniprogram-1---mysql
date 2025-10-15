@echo off
chcp 65001 >nul
echo ========================================
echo 解决DNS和跨域问题
echo ========================================
echo.

echo [问题分析]
echo ========================================
echo 1. 域名 admin.practice.insightdate.top 没有DNS解析记录
echo 2. 需要使用IP地址访问
echo 3. 跨域问题需要通过nginx代理解决
echo.

echo [STEP 1] 停止现有服务
echo ========================================
echo [INFO] 停止nginx服务...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [INFO] 停止Node.js服务...
taskkill /f /im node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [STEP 2] 创建IP访问的nginx配置
echo ========================================
echo [INFO] 创建IP访问配置...

:: 备份现有配置
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    copy "C:\nginx\conf.d\admin-ssl.conf" "C:\nginx\conf.d\admin-ssl.conf.backup" >nul
)

:: 创建IP访问配置
(
echo # Admin IP访问配置 - 解决DNS问题
echo server {
echo     listen 80;
echo     server_name 223.93.139.87;
echo     return 301 https://$server_name:8443$request_uri;
echo }
echo.
echo server {
echo     listen 8443 ssl;
echo     server_name 223.93.139.87;
echo.
echo     ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers HIGH:!aNULL:!MD5;
echo     ssl_prefer_server_ciphers off;
echo.
echo     # 代理API请求到主域名 - 解决跨域问题
echo     location /api/ {
echo         proxy_pass https://practice.insightdate.top/api/;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_ssl_verify off;
echo         proxy_ssl_server_name on;
echo     }
echo.
echo     # 前端静态文件
echo     root C:/admin;
echo     index index.html;
echo.
echo     location / {
echo         try_files $uri $uri/ /index.html;
echo     }
echo }
) > "C:\nginx\conf.d\admin-ssl.conf"

echo [OK] IP访问配置已创建

echo.
echo [STEP 3] 测试nginx配置
echo ========================================
echo [INFO] 测试nginx配置...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx配置测试通过
) else (
    echo [ERROR] nginx配置测试失败
    pause
    exit /b 1
)
cd /d "%~dp0"

echo.
echo [STEP 4] 启动nginx服务
echo ========================================
echo [INFO] 启动nginx服务...
cd /d C:\nginx
start "Nginx Server" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

echo [INFO] 检查nginx状态...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx服务已启动
) else (
    echo [ERROR] nginx服务启动失败
    pause
    exit /b 1
)

echo.
echo [STEP 5] 启动API服务器
echo ========================================
echo [INFO] 启动API服务器...
cd /d "%~dp0\server"
start "API Server" cmd /c "npm start"
timeout /t 5 /nobreak >nul
cd /d "%~dp0"

echo.
echo [STEP 6] 构建并部署Admin前端
echo ========================================
echo [INFO] 构建Admin前端...
cd /d "%~dp0\admin"
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Admin前端构建失败
    pause
    exit /b 1
)

echo [INFO] 部署到nginx目录...
if not exist "C:\admin" mkdir "C:\admin"
xcopy /E /I /Y dist\* C:\admin\ >nul
echo [OK] Admin前端已部署

cd /d "%~dp0"

echo.
echo ========================================
echo 解决方案完成
echo ========================================
echo.
echo 访问地址：
echo - Admin管理界面: https://223.93.139.87:8443
echo - API服务: https://practice.insightdate.top/api
echo.
echo 解决方案说明：
echo 1. 使用IP地址 223.93.139.87 访问admin界面
echo 2. nginx代理API请求到主域名，解决跨域问题
echo 3. 所有请求都在同一域名下，无跨域限制
echo.
echo 注意事项：
echo - 浏览器可能会显示SSL证书警告，点击"继续访问"即可
echo - 如果仍有问题，请检查防火墙设置
echo.
echo Press any key to exit...
pause >nul
