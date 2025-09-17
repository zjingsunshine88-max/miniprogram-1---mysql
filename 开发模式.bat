@echo off
chcp 65001 >nul
title 开发模式启动

echo ========================================
echo 🛠️ 刷题小程序管理系统 - 开发模式
echo ========================================
echo.

REM 设置颜色
color 0B

echo 📋 开发模式特点：
echo - 代码修改后自动重新构建
echo - 热重载支持
echo - 详细的错误信息
echo.

echo 🔍 检查开发环境...
echo.

REM 检查admin目录
cd /d "%~dp0admin"
if not exist "package.json" (
    echo ❌ 错误: admin目录中没有package.json文件
    pause
    exit /b 1
)

REM 检查server目录
cd /d "%~dp0server"
if not exist "app.js" (
    echo ❌ 错误: server目录中没有app.js文件
    pause
    exit /b 1
)

echo ✅ 开发环境检查通过
echo.

REM 停止现有服务
echo 🛑 停止现有服务...
tasklist | findstr "node.exe" >nul
if not errorlevel 1 (
    for /f "tokens=2" %%a in ('tasklist ^| findstr "node.exe"') do (
        taskkill /f /pid %%a >nul 2>&1
    )
)

tasklist | findstr "chrome.exe" >nul
if not errorlevel 1 (
    taskkill /f /im chrome.exe >nul 2>&1
)

echo ✅ 现有服务已停止
echo.

REM 启动API服务器（开发模式）
echo 🚀 启动API服务器（开发模式）...
cd /d "%~dp0server"
start "API服务器-开发模式" cmd /c "set NODE_ENV=development && node app.js"

REM 等待API服务器启动
echo ⏳ 等待API服务器启动...
timeout /t 5 >nul

REM 启动admin开发服务器
echo 🎨 启动admin开发服务器...
cd /d "%~dp0admin"
start "Admin开发服务器" cmd /c "npm run dev -- --host 0.0.0.0 --port 3001"

REM 等待admin服务启动
echo ⏳ 等待admin服务启动...
timeout /t 8 >nul

REM 打开Chrome浏览器
echo 🌐 打开Chrome浏览器...
if exist "C:\Temp" rmdir /s /q "C:\Temp" >nul 2>&1
mkdir "C:\Temp" >nul 2>&1
start "" "chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"

echo.
echo ========================================
echo 🎉 开发模式启动完成！
echo ========================================
echo.
echo 📋 服务状态：
echo ✅ API服务器: http://223.93.139.87:3002 (开发模式)
echo ✅ Admin服务: http://223.93.139.87:3001 (热重载)
echo ✅ Chrome浏览器: 已打开（无安全限制模式）
echo.
echo 💡 开发提示：
echo - 修改admin代码会自动重新构建和刷新
echo - 修改server代码需要手动重启API服务器
echo - 关闭此窗口不会停止服务
echo - 使用 stop-services.bat 停止所有服务
echo.

echo 按任意键关闭此窗口...
pause >nul
