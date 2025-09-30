@echo off
chcp 65001 >nul
title 启动HTTPS服务

echo 🚀 启动HTTPS服务...
echo.

echo 📋 服务配置:
echo - 域名: practice.insightdata.top
echo - 协议: HTTPS
echo - API端口: 3002
echo - 管理后台端口: 3000
echo.

REM 进入项目根目录
cd /d "%~dp0"

echo 步骤1: 检查证书文件...
if not exist "C:\certificates\practice.insightdata.top.pem" (
    echo ❌ SSL证书文件不存在: C:\certificates\practice.insightdata.top.pem
    echo 💡 请按照 WINDOWS_SSL_SETUP_GUIDE.md 配置SSL证书
    pause
    exit /b 1
)

if not exist "C:\certificates\practice.insightdata.top.key" (
    echo ❌ SSL私钥文件不存在: C:\certificates\practice.insightdata.top.key
    echo 💡 请按照 WINDOWS_SSL_SETUP_GUIDE.md 配置SSL证书
    pause
    exit /b 1
)

echo ✅ SSL证书文件检查通过

echo.
echo 步骤2: 配置Nginx...
cd /d C:\nginx

REM 复制HTTPS配置文件
echo 📋 配置HTTPS Nginx...
if not exist "conf\practice.insightdata.top.conf" (
    echo 复制HTTPS配置文件...
    copy "%~dp0nginx-https.conf" "conf\practice.insightdata.top.conf" >nul
    echo ✅ HTTPS配置文件已复制
) else (
    echo ✅ HTTPS配置文件已存在
)

REM 检查Nginx是否已在运行
tasklist | findstr nginx.exe >nul
if not errorlevel 1 (
    echo ⚠️  Nginx已在运行，重启服务...
    nginx.exe -s reload
) else (
    echo 🌐 启动Nginx服务...
    start nginx.exe
)

timeout /t 3 >nul
echo ✅ Nginx服务启动完成

echo.
echo 步骤3: 启动API服务...
cd /d "%~dp0\server"

REM 检查端口3002是否被占用
echo 🔍 检查端口3002状态...
netstat -ano | findstr :3002 >nul
if not errorlevel 1 (
    echo ⚠️  端口3002已被占用，正在终止占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002') do (
        echo 终止进程: %%a
        taskkill /PID %%a /F >nul 2>&1
    )
    timeout /t 2 >nul
    echo ✅ 端口3002已释放
) else (
    echo ✅ 端口3002可用
)

REM 设置生产环境变量
set NODE_ENV=production
set DB_PASSWORD=LOVEjing96..

echo 🔧 设置环境变量...
echo NODE_ENV=production
echo DB_PASSWORD=LOVEjing96..

echo 🌐 启动API服务器...
echo 访问地址: https://practice.insightdata.top/api/
echo 健康检查: https://practice.insightdata.top/health
echo.

start "API Server" cmd /k "npm run start:prod"

echo ✅ API服务启动完成

echo.
echo 步骤4: 构建管理后台...
cd /d "%~dp0\admin"

REM 设置环境变量
set VITE_SERVER_URL=https://practice.insightdata.top

echo 🔧 设置环境变量...
echo VITE_SERVER_URL=https://practice.insightdata.top

echo 🔨 构建管理后台...
npm run build

if errorlevel 1 (
    echo ❌ 管理后台构建失败
    pause
    exit /b 1
)

echo ✅ 管理后台构建完成

echo 📁 复制构建文件到Nginx目录...
if not exist "C:\admin\dist" mkdir C:\admin\dist
xcopy /E /Y "dist\*" "C:\admin\dist\"

echo ✅ 管理后台文件复制完成
echo 📝 管理后台将通过Nginx静态文件访问: https://practice.insightdata.top/

echo.
echo 步骤5: 验证服务状态...
timeout /t 5 >nul

echo 🔍 检查服务状态...
echo.

REM 检查Nginx
tasklist | findstr nginx.exe >nul
if errorlevel 1 (
    echo ❌ Nginx未运行
) else (
    echo ✅ Nginx运行正常
)

REM 检查API服务
netstat -an | findstr :3002 >nul
if errorlevel 1 (
    echo ❌ API服务端口3002未监听
) else (
    echo ✅ API服务端口3002监听正常
)

REM 检查管理后台静态文件
if exist "C:\admin\index.html" (
    echo ✅ 管理后台静态文件存在
) else (
    echo ❌ 管理后台静态文件不存在
)

echo.
echo 🎉 HTTPS服务启动完成！
echo.
echo 📋 服务访问地址:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo - 文件上传: https://practice.insightdata.top/uploads/
echo.
echo 💡 注意事项:
echo 1. 确保域名 practice.insightdata.top 已解析到服务器IP
echo 2. 确保SSL证书文件位于 C:\certificates\ 目录
echo 3. 确保防火墙允许443端口访问
echo 4. 小程序配置已更新为HTTPS域名
echo.
echo 🎯 服务状态监控:
echo - 按 Ctrl+C 停止所有服务
echo - 按任意键查看服务状态
echo - 关闭此窗口将保持服务运行
echo.
pause
echo.
echo 🔍 当前服务状态:
echo.
tasklist | findstr nginx.exe >nul
if errorlevel 1 (
    echo ❌ Nginx未运行
) else (
    echo ✅ Nginx运行正常
)

tasklist | findstr node.exe >nul
if errorlevel 1 (
    echo ❌ Node.js服务未运行
) else (
    echo ✅ Node.js服务运行正常
)

echo.
echo 🌐 测试访问地址:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
echo 💡 如果无法访问，请检查:
echo 1. 域名解析是否正确
echo 2. SSL证书是否存在
echo 3. 防火墙是否允许443端口
echo.
echo 按任意键退出监控...
pause >nul
