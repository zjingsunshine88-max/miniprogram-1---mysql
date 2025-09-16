@echo off
chcp 65001 >nul
title 启动API服务器

echo 🚀 启动API服务器...
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
echo 访问地址: http://223.93.139.87:3002
echo 按 Ctrl+C 停止服务
echo.

REM 启动服务器
node app.js

pause
