@echo off
chcp 65001 >nul
title 启动后台管理系统

echo 🚀 启动后台管理系统...
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

echo 📁 检查dist目录...
dir dist /b | findstr /i "index.html" >nul
if errorlevel 1 (
    echo ❌ 错误: dist目录中没有index.html文件
    echo 💡 请检查构建是否成功
    pause
    exit /b 1
)

echo ✅ dist目录检查通过
echo.

REM 检查端口3001是否被占用
netstat -an | findstr :3001 >nul
if not errorlevel 1 (
    echo ⚠️  端口3001已被占用
    echo 🔍 正在查找占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
        echo 进程ID: %%a
        tasklist /fi "pid eq %%a"
    )
    echo.
    set /p KILL_PROCESS="是否要结束占用进程？(y/n): "
    if /i "%KILL_PROCESS%"=="y" (
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
            taskkill /f /pid %%a
        )
        echo ✅ 进程已结束
    ) else (
        echo ❌ 取消启动
        pause
        exit /b 1
    )
)

echo 🌐 启动admin服务...
echo 访问地址: http://223.93.139.87:3001
echo 按 Ctrl+C 停止服务
echo.

REM 启动vite预览服务器
call npm run serve

pause
