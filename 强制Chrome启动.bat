@echo off
chcp 65001 >nul
title 强制Chrome启动

echo ========================================
echo 强制Chrome启动（无安全限制模式）
echo ========================================
echo.

REM 先构建admin
echo 步骤1: 构建admin...
cd /d "%~dp0admin"
call npm run build
if errorlevel 1 (
    echo 构建失败！
    pause
    exit /b 1
)

REM 启动API服务器
echo.
echo 步骤2: 启动API服务器...
cd /d "%~dp0"
start "API服务器" /min cmd /c "start-server.bat"
timeout /t 5 >nul

REM 启动admin服务
echo 步骤3: 启动admin服务...
start "Admin服务" /min cmd /c "start-admin-simple.bat"
timeout /t 10 >nul

REM 强制启动Chrome
echo.
echo 步骤4: 强制启动Chrome...
echo.

REM 关闭现有Chrome进程
echo 关闭现有Chrome进程...
taskkill /f /im chrome.exe >nul 2>&1
timeout /t 2 >nul

REM 创建临时目录
echo 创建Chrome临时用户数据目录...
if not exist "C:\Temp" mkdir "C:\Temp" >nul 2>&1

REM 尝试多种Chrome路径
echo 尝试启动Chrome...

REM 方法1: 直接调用chrome.exe
echo 方法1: 直接调用chrome.exe
start "" "chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"
timeout /t 3 >nul

REM 检查是否启动成功
tasklist | findstr chrome.exe >nul
if not errorlevel 1 (
    echo Chrome启动成功！
    goto chrome_success
)

REM 方法2: 尝试Program Files路径
echo 方法2: 尝试Program Files路径
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"
    timeout /t 3 >nul
    tasklist | findstr chrome.exe >nul
    if not errorlevel 1 (
        echo Chrome启动成功！
        goto chrome_success
    )
)

REM 方法3: 尝试Program Files (x86)路径
echo 方法3: 尝试Program Files (x86)路径
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    start "" "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"
    timeout /t 3 >nul
    tasklist | findstr chrome.exe >nul
    if not errorlevel 1 (
        echo Chrome启动成功！
        goto chrome_success
    )
)

REM 方法4: 使用默认浏览器
echo Chrome启动失败，使用默认浏览器...
start "" "http://223.93.139.87:3001/"

:chrome_success
echo.
echo ========================================
echo 启动完成！
echo ========================================
echo.
echo 服务状态：
echo API服务器: http://223.93.139.87:3002
echo Admin服务: http://223.93.139.87:3001
echo 浏览器: 已打开
echo.
echo 如果Chrome没有以无安全限制模式启动，请：
echo 1. 手动关闭Chrome
echo 2. 重新运行此脚本
echo 3. 或者手动启动Chrome并添加参数
echo.

pause
