@echo off
chcp 65001 >nul
title 修复Nginx端口冲突

echo 🔧 修复Nginx端口冲突
echo ========================================
echo.

set DOMAIN=practice.insightdata.top
set IP=223.93.139.87

echo 📋 检查端口占用情况...
echo.

echo 步骤1: 检查443端口占用...
netstat -ano | findstr :443
echo.

echo 步骤2: 检查常用替代端口...
echo 🔍 检查端口8443:
netstat -ano | findstr :8443
if errorlevel 1 (
    echo ✅ 端口8443可用
    set ALTERNATIVE_PORT=8443
) else (
    echo ❌ 端口8443被占用
)

echo 🔍 检查端口9443:
netstat -ano | findstr :9443
if errorlevel 1 (
    echo ✅ 端口9443可用
    if not defined ALTERNATIVE_PORT set ALTERNATIVE_PORT=9443
) else (
    echo ❌ 端口9443被占用
)

echo 🔍 检查端口10443:
netstat -ano | findstr :10443
if errorlevel 1 (
    echo ✅ 端口10443可用
    if not defined ALTERNATIVE_PORT set ALTERNATIVE_PORT=10443
) else (
    echo ❌ 端口10443被占用
)

echo 🔍 检查端口3003:
netstat -ano | findstr :3003
if errorlevel 1 (
    echo ✅ 端口3003可用
    if not defined ALTERNATIVE_PORT set ALTERNATIVE_PORT=3003
) else (
    echo ❌ 端口3003被占用
)

echo.
echo 📊 端口占用分析:
if defined ALTERNATIVE_PORT (
    echo ✅ 推荐使用端口: %ALTERNATIVE_PORT%
) else (
    echo ❌ 所有常用端口都被占用
    echo 请手动选择其他端口
)

echo.
echo 💡 解决方案:
echo.

echo 方案1: 使用替代端口 (推荐)
echo ========================================
echo 1. 修改Nginx配置文件
echo 2. 修改小程序配置
echo 3. 更新防火墙设置
echo.

echo 方案2: 释放443端口
echo ========================================
echo 1. 查找占用443端口的进程
echo 2. 停止冲突的服务
echo 3. 重新启动Nginx
echo.

echo 方案3: 使用HTTP (临时)
echo ========================================
echo 1. 暂时使用HTTP协议
echo 2. 端口80或3002
echo 3. 后续再配置HTTPS
echo.

echo 🎯 推荐配置 (使用端口%ALTERNATIVE_PORT%):
echo ========================================
echo.
echo Nginx配置:
echo listen %ALTERNATIVE_PORT% ssl;
echo.
echo 小程序配置:
echo BASE_URL: https://%DOMAIN%:%ALTERNATIVE_PORT%
echo.
echo 访问地址:
echo https://%DOMAIN%:%ALTERNATIVE_PORT%/
echo https://%DOMAIN%:%ALTERNATIVE_PORT%/api/
echo.

echo 🔧 是否要自动生成配置文件? (Y/N)
set /p choice=
if /i "%choice%"=="Y" (
    echo 正在生成配置文件...
    call :generate_configs
) else (
    echo 跳过自动生成
)

echo.
echo 📝 手动配置步骤:
echo.
echo 1. 修改 nginx-https.conf:
echo    listen %ALTERNATIVE_PORT% ssl;
echo.
echo 2. 修改 miniprogram/config/production.js:
echo    BASE_URL: 'https://%DOMAIN%:%ALTERNATIVE_PORT%'
echo.
echo 3. 更新防火墙规则:
echo    - 允许端口%ALTERNATIVE_PORT%
echo    - 确保端口对外开放
echo.
echo 4. 重启Nginx服务
echo.
echo 5. 测试访问:
echo    https://%DOMAIN%:%ALTERNATIVE_PORT%/
echo.

goto :eof

:generate_configs
echo 生成Nginx配置文件...
echo.
echo 创建 nginx-https-%ALTERNATIVE_PORT%.conf...

(
echo # HTTPS Nginx配置 - 端口%ALTERNATIVE_PORT%
echo server {
echo     listen %ALTERNATIVE_PORT% ssl http2;
echo     listen [::]:%ALTERNATIVE_PORT% ssl http2;
echo     server_name %DOMAIN%;
echo.
echo     # SSL证书配置
echo     ssl_certificate C:/ssl/practice.insightdata.top.pem;
echo     ssl_certificate_key C:/ssl/practice.insightdata.top.key;
echo.
echo     # SSL配置
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
echo     ssl_prefer_server_ciphers on;
echo     ssl_session_cache shared:SSL:10m;
echo     ssl_session_timeout 10m;
echo.
echo     # 安全头
echo     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
echo     add_header X-Frame-Options DENY always;
echo     add_header X-Content-Type-Options nosniff always;
echo     add_header X-XSS-Protection "1; mode=block" always;
echo.
echo     # 客户端最大上传大小
echo     client_max_body_size 50M;
echo.
echo     # API代理
echo     location /api/ {
echo         proxy_pass http://localhost:3002/api/;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_set_header X-Forwarded-Port $server_port;
echo.
echo         # WebSocket支持
echo         proxy_http_version 1.1;
echo         proxy_set_header Upgrade $http_upgrade;
echo         proxy_set_header Connection "upgrade";
echo.
echo         # 超时设置
echo         proxy_connect_timeout 60s;
echo         proxy_send_timeout 60s;
echo         proxy_read_timeout 60s;
echo     }
echo.
echo     # 健康检查
echo     location /health {
echo         proxy_pass http://localhost:3002/health;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo     }
echo.
echo     # 静态文件缓存
echo     location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
echo         root C:/admin/dist;
echo         expires 1y;
echo         add_header Cache-Control "public, immutable";
echo     }
echo.
echo     # 管理后台静态文件
echo     location / {
echo         root C:/admin/dist;
echo         index index.html;
echo         try_files $uri $uri/ /index.html;
echo.
echo         # 静态文件缓存
echo         location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
echo             expires 1y;
echo             add_header Cache-Control "public, immutable";
echo         }
echo     }
echo.
echo     # 错误页面
echo     error_page 404 /404.html;
echo     error_page 500 502 503 504 /50x.html;
echo     location = /50x.html {
echo         root C:/admin/dist;
echo     }
echo }
) > nginx-https-%ALTERNATIVE_PORT%.conf

echo ✅ Nginx配置文件已生成: nginx-https-%ALTERNATIVE_PORT%.conf

echo.
echo 生成小程序配置文件...
(
echo // 生产环境配置 - 端口%ALTERNATIVE_PORT%
echo module.exports = {
echo   // API基础URL
echo   BASE_URL: 'https://%DOMAIN%:%ALTERNATIVE_PORT%',
echo   
echo   // 小程序配置
echo   APP_ID: 'wx93529c7938093719',
echo   
echo   // 其他配置
echo   DEBUG: false,
echo   VERSION: '1.0.0'
echo }
) > miniprogram/config/production-%ALTERNATIVE_PORT%.js

echo ✅ 小程序配置文件已生成: miniprogram/config/production-%ALTERNATIVE_PORT%.js

echo.
echo 生成启动脚本...
(
echo @echo off
echo chcp 65001 ^>nul
echo title 启动HTTPS服务 - 端口%ALTERNATIVE_PORT%
echo.
echo echo 🚀 启动HTTPS服务 - 端口%ALTERNATIVE_PORT%
echo echo ========================================
echo echo.
echo.
echo set DOMAIN=%DOMAIN%
echo set PORT=%ALTERNATIVE_PORT%
echo.
echo echo 📋 服务配置:
echo echo 域名: %%DOMAIN%%
echo echo 端口: %%PORT%%
echo echo 访问地址: https://%%DOMAIN%%:%%PORT%%/
echo echo.
echo.
echo echo 步骤1: 停止现有Nginx服务...
echo taskkill /F /IM nginx.exe ^>nul 2^>^&1
echo timeout /t 2 ^>nul
echo.
echo echo 步骤2: 复制Nginx配置文件...
echo copy "nginx-https-%%PORT%%.conf" "C:\nginx\conf\practice.insightdata.top.conf" ^>nul
echo.
echo echo 步骤3: 启动Nginx服务...
echo cd /d C:\nginx
echo start nginx
echo timeout /t 3 ^>nul
echo.
echo echo 步骤4: 启动API服务...
echo cd /d "%%~dp0\server"
echo set NODE_ENV=production
echo set DB_PASSWORD=LOVEjing96..
echo start "API Server" cmd /k "npm run start:prod"
echo timeout /t 5 ^>nul
echo.
echo echo 步骤5: 构建管理后台...
echo cd /d "%%~dp0\admin"
echo set VITE_SERVER_URL=https://%%DOMAIN%%:%%PORT%%
echo npm run build
echo.
echo echo 步骤6: 复制静态文件...
echo if not exist "C:\admin\dist" mkdir C:\admin\dist
echo xcopy /E /Y "dist\*" "C:\admin\dist\" ^>nul
echo.
echo echo ✅ 服务启动完成！
echo echo.
echo echo 🌐 访问地址:
echo echo 管理后台: https://%%DOMAIN%%:%%PORT%%/
echo echo API接口: https://%%DOMAIN%%:%%PORT%%/api/
echo echo 健康检查: https://%%DOMAIN%%:%%PORT%%/health
echo echo.
echo echo 按任意键退出...
echo pause ^>nul
) > start-https-services-%ALTERNATIVE_PORT%.bat

echo ✅ 启动脚本已生成: start-https-services-%ALTERNATIVE_PORT%.bat

echo.
echo 🎉 配置文件生成完成！
echo.
echo 📝 下一步操作:
echo 1. 运行: start-https-services-%ALTERNATIVE_PORT%.bat
echo 2. 测试访问: https://%DOMAIN%:%ALTERNATIVE_PORT%/
echo 3. 更新小程序配置使用新端口
echo.
goto :eof
