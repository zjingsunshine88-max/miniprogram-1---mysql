@echo off
chcp 65001 >nul
title 启动API服务器 (8443端口)

echo 🚀 启动API服务器 (8443端口)...
echo.
echo 📋 服务配置:
echo - 本地端口: 3002
echo - HTTPS端口: 8443
echo - 域名: practice.insightdata.top
echo.

REM 进入server目录
cd /d "%~dp0server"

REM 检查app.js是否存在
if not exist "app.js" (
    echo ❌ 错误: app.js文件不存在
    pause
    exit /b 1
)

echo ✅ app.js文件检查通过
echo.

REM 设置环境变量
echo 🔧 设置环境变量...
set NODE_ENV=production
echo NODE_ENV=production
echo [信息] 生产环境模式，API将通过nginx 8443端口对外提供服务

REM 检查端口3002是否被占用
netstat -an | findstr :3002 >nul
if not errorlevel 1 (
    echo ⚠️  端口3002已被占用
    echo 🔍 正在查找占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002') do (
        echo 进程ID: %%a
        tasklist /fi "pid eq %%a"
    )
    echo.
    set /p KILL_PROCESS="是否要结束占用进程？(y/n): "
    if /i "%KILL_PROCESS%"=="y" (
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002') do (
            taskkill /f /pid %%a
        )
        echo ✅ 进程已结束
    ) else (
        echo ❌ 取消启动
        pause
        exit /b 1
    )
)

echo 🌐 启动API服务器...
echo 本地访问地址: http://localhost:3002
echo HTTPS访问地址: https://practice.insightdata.top:8443/api/
echo 健康检查: https://practice.insightdata.top:8443/health
echo 按 Ctrl+C 停止服务
echo.

REM 启动服务器
node app.js

pause
