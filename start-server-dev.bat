@echo off
chcp 65001 >nul
title 启动API服务器 (开发环境)

echo 🚀 启动API服务器 (开发环境)...
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

REM 设置开发环境变量
echo 🔧 设置开发环境变量...
set NODE_ENV=development
set DB_PASSWORD=1234
echo NODE_ENV=development
echo DB_PASSWORD=1234

REM 检查nodemon是否安装
echo 📦 检查nodemon是否安装...
call npm list nodemon >nul 2>&1
if errorlevel 1 (
    echo ⚠️  nodemon未安装，正在安装...
    call npm install nodemon --save-dev
    if errorlevel 1 (
        echo ❌ nodemon安装失败
        echo 💡 将使用普通node启动
        goto use_node
    )
)

echo ✅ nodemon已准备就绪
echo.

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

echo 🌐 启动开发服务器 (使用nodemon)...
echo 访问地址: http://localhost:3002
echo 特性: 文件变化时自动重启
echo 按 Ctrl+C 停止服务
echo.

REM 使用nodemon启动开发服务器
call npm run dev
goto end

:use_node
echo 🌐 启动开发服务器 (使用node)...
echo 访问地址: http://localhost:3002
echo 按 Ctrl+C 停止服务
echo.
node app.js

:end
pause
