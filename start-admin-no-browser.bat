@echo off
chcp 65001 >nul
title 启动后台管理系统（无浏览器）

echo 🚀 启动后台管理系统（无浏览器模式）...
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
    echo ⚠️  端口3001已被占用，正在结束占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
        taskkill /f /pid %%a >nul 2>&1
    )
    timeout /t 2 >nul
)

echo 🌐 启动admin服务...
echo 访问地址: http://223.93.139.87:3001
echo 按 Ctrl+C 停止服务
echo.

REM 使用vite preview命令启动（不会自动打开浏览器）
call npx vite preview --host 0.0.0.0 --port 3001

pause
