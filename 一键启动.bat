@echo off
chcp 65001 >nul
title 一键启动刷题小程序管理系统

echo ========================================
echo 🚀 刷题小程序管理系统 - 一键启动
echo ========================================
echo.

REM 设置颜色
color 0A

echo 📋 执行步骤：
echo 1. 构建admin生产版本
echo 2. 启动API服务器
echo 3. 启动admin服务
echo 4. 打开Chrome浏览器
echo.

REM 步骤1: 构建admin生产版本
echo ========================================
echo 📦 步骤1: 构建admin生产版本
echo ========================================
echo.

cd /d "%~dp0admin"

echo 🔍 检查admin目录...
if not exist "package.json" (
    echo ❌ 错误: admin目录中没有package.json文件
    echo 💡 请确保在正确的项目目录中运行此脚本
    pause
    exit /b 1
)

echo ✅ admin目录检查通过
echo.

echo 📦 开始构建admin项目...
call npm run build

if errorlevel 1 (
    echo ❌ 构建失败！
    echo 💡 请检查代码是否有错误
    pause
    exit /b 1
)

echo ✅ admin构建成功！
echo.

REM 检查dist目录
if not exist "dist\index.html" (
    echo ❌ 错误: dist目录中没有index.html文件
    echo 💡 构建可能失败，请检查错误信息
    pause
    exit /b 1
)

echo ✅ dist目录检查通过
echo.

REM 步骤2: 启动API服务器
echo ========================================
echo 🌐 步骤2: 启动API服务器
echo ========================================
echo.

cd /d "%~dp0"

echo 🔍 检查API服务器端口3002...
netstat -an | findstr :3002 >nul
if not errorlevel 1 (
    echo ⚠️  端口3002已被占用，正在结束占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002') do (
        taskkill /f /pid %%a >nul 2>&1
    )
    timeout /t 2 >nul
)

echo 🚀 启动API服务器...
start "API服务器" /min cmd /c "start-server.bat"

REM 等待API服务器启动
echo ⏳ 等待API服务器启动...
timeout /t 5 >nul

REM 检查API服务器是否启动成功
:check_api
netstat -an | findstr :3002 >nul
if errorlevel 1 (
    echo ⏳ API服务器启动中，请稍候...
    timeout /t 2 >nul
    goto check_api
)

echo ✅ API服务器启动成功！
echo.

REM 步骤3: 启动admin服务
echo ========================================
echo 🎨 步骤3: 启动admin服务
echo ========================================
echo.

echo 🔍 检查admin服务端口3001...
netstat -an | findstr :3001 >nul
if not errorlevel 1 (
    echo ⚠️  端口3001已被占用，正在结束占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
        taskkill /f /pid %%a >nul 2>&1
    )
    timeout /t 2 >nul
)

echo 🚀 启动admin服务...
start "Admin服务" /min cmd /c "start-admin-simple.bat"

REM 等待admin服务启动
echo ⏳ 等待admin服务启动...
timeout /t 10 >nul

REM 检查admin服务是否启动成功
:check_admin
netstat -an | findstr :3001 >nul
if errorlevel 1 (
    echo ⏳ admin服务启动中，请稍候...
    timeout /t 3 >nul
    goto check_admin
)

echo ✅ admin服务启动成功！
echo.

REM 步骤4: 打开Chrome浏览器
echo ========================================
echo 🌐 步骤4: 打开Chrome浏览器
echo ========================================
echo.

echo 检查Chrome浏览器...
where chrome.exe >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Chrome浏览器
    echo 请确保Chrome已安装并在PATH环境变量中
    echo 或者手动打开浏览器访问: http://223.93.139.87:3001/
    echo.
    echo 尝试使用默认浏览器...
    start "" "http://223.93.139.87:3001/"
    echo 已尝试打开默认浏览器
    goto skip_chrome
)
/*
REM echo ✅ Chrome浏览器检查通过
REM echo.

REM REM 创建临时用户数据目录
REM echo 📁 创建Chrome临时用户数据目录...
REM if not exist "C:\Temp" mkdir "C:\Temp" >nul 2>&1

REM REM 等待一下确保admin服务完全启动
REM echo ⏳ 等待admin服务完全启动...
REM timeout /t 3 >nul

REM echo 打开Chrome浏览器（无安全限制模式）...
REM start "" "chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"

REM :skip_chrome
REM echo.
REM echo ========================================
REM echo 启动完成！
REM echo ========================================
REM echo.
REM echo 服务状态：
REM echo API服务器: http://223.93.139.87:3002
REM echo Admin服务: http://223.93.139.87:3001
REM echo 浏览器: 已打开
REM echo.
REM echo 提示：
REM echo - 关闭此窗口不会停止服务
REM echo - 要停止服务，请关闭对应的服务窗口
REM echo - 或者使用 stop-services.bat 停止所有服务
REM echo.

REM REM 保持窗口打开
REM echo 按任意键关闭此窗口...
REM pause >nul