@echo off
chcp 65001 >nul
title 启动后台管理系统 (简单HTTP服务器)

echo 🚀 启动后台管理系统 (简单HTTP服务器)...
echo.

REM 进入admin目录
cd /d "%~dp0admin"

REM 检查dist目录是否存在
if not exist "dist" (
    echo ❌ 错误: dist目录不存在
    echo 💡 请先运行构建命令: npm run build
    pause
    exit /b 1
)

echo ✅ dist目录检查通过
echo.

REM 检查Node.js是否安装
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Node.js
    echo 💡 请先安装Node.js: https://nodejs.org/
    pause
    exit /b 1
)

echo 📦 检查http-server是否安装...
npx http-server --version >nul 2>&1
if errorlevel 1 (
    echo 📥 安装http-server...
    call npm install -g http-server
    if errorlevel 1 (
        echo ❌ http-server安装失败
        pause
        exit /b 1
    )
)

echo ✅ http-server已准备就绪
echo.

REM 检查端口3001是否被占用
netstat -an | findstr :3001 >nul
if not errorlevel 1 (
    echo ⚠️  端口3001已被占用，尝试使用端口3003...
    set PORT=3003
) else (
    set PORT=3001
)

echo 🌐 启动HTTP服务器...
echo 访问地址: http://223.93.139.87:%PORT%
echo 按 Ctrl+C 停止服务
echo.

REM 启动HTTP服务器
npx http-server dist -p %PORT% -a 0.0.0.0 -c-1 --cors

pause
