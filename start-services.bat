@echo off
chcp 65001 >nul
title 启动刷题小程序服务

echo 🚀 正在启动刷题小程序服务...
echo.

REM 设置环境变量
set NODE_ENV=production

REM 检查Node.js是否安装
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Node.js，请先安装Node.js
    pause
    exit /b 1
)

REM 检查PM2是否安装
pm2 --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到PM2，请先安装PM2
    pause
    exit /b 1
)

REM 启动API服务
echo 📡 启动API服务...
cd /d C:\question-bank\api
pm2 start app.js --name "question-bank-api" --env production

if errorlevel 1 (
    echo ❌ API服务启动失败
    pause
    exit /b 1
)

REM 保存PM2配置
pm2 save

REM 启动Nginx (如果存在)
if exist "C:\nginx\nginx.exe" (
    echo 🌐 启动Nginx...
    cd /d C:\nginx
    start nginx.exe
)

echo.
echo ✅ 所有服务启动成功！
echo.
echo 📊 服务状态：
pm2 status
echo.
echo 🌐 访问地址：
echo   后台管理: http://223.93.139.87/admin
echo   API服务: http://223.93.139.87/api
echo   健康检查: http://223.93.139.87/health
echo.
echo 按任意键退出...
pause >nul
