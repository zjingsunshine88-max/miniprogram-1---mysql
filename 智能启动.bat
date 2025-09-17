@echo off
chcp 65001 >nul
title 智能启动刷题小程序管理系统

echo ========================================
echo 智能启动刷题小程序管理系统
echo ========================================
echo.

REM 设置颜色
color 0A

echo 执行步骤：
echo 1. 构建admin生产版本
echo 2. 启动API服务器
echo 3. 启动admin服务
echo 4. 智能打开浏览器
echo.

REM 步骤1: 构建admin生产版本
echo ========================================
echo 步骤1: 构建admin生产版本
echo ========================================
echo.

cd /d "%~dp0admin"

echo 检查admin目录...
if not exist "package.json" (
    echo 错误: admin目录中没有package.json文件
    echo 请确保在正确的项目目录中运行此脚本
    pause
    exit /b 1
)

echo admin目录检查通过
echo.

echo 开始构建admin项目...
call npm run build

if errorlevel 1 (
    echo 构建失败！
    echo 请检查代码是否有错误
    pause
    exit /b 1
)

echo admin构建成功！
echo.

REM 检查dist目录
if not exist "dist\index.html" (
    echo 错误: dist目录中没有index.html文件
    echo 构建可能失败，请检查错误信息
    pause
    exit /b 1
)

echo dist目录检查通过
echo.

REM 步骤2: 启动API服务器
echo ========================================
echo 步骤2: 启动API服务器
echo ========================================
echo.

cd /d "%~dp0"

echo 检查API服务器端口3002...
netstat -an | findstr :3002 >nul
if not errorlevel 1 (
    echo 端口3002已被占用，正在结束占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002') do (
        taskkill /f /pid %%a >nul 2>&1
    )
    timeout /t 2 >nul
)

echo 启动API服务器...
start "API服务器" /min cmd /c "start-server.bat"

REM 等待API服务器启动
echo 等待API服务器启动...
timeout /t 5 >nul

REM 检查API服务器是否启动成功
:check_api
netstat -an | findstr :3002 >nul
if errorlevel 1 (
    echo API服务器启动中，请稍候...
    timeout /t 2 >nul
    goto check_api
)

echo API服务器启动成功！
echo.

REM 步骤3: 启动admin服务
echo ========================================
echo 步骤3: 启动admin服务
echo ========================================
echo.

echo 检查admin服务端口3001...
netstat -an | findstr :3001 >nul
if not errorlevel 1 (
    echo 端口3001已被占用，正在结束占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
        taskkill /f /pid %%a >nul 2>&1
    )
    timeout /t 2 >nul
)

echo 启动admin服务...
start "Admin服务" /min cmd /c "start-admin-simple.bat"

REM 等待admin服务启动
echo 等待admin服务启动...
timeout /t 10 >nul

REM 检查admin服务是否启动成功
:check_admin
netstat -an | findstr :3001 >nul
if errorlevel 1 (
    echo admin服务启动中，请稍候...
    timeout /t 3 >nul
    goto check_admin
)

echo admin服务启动成功！
echo.

REM 步骤4: 智能打开浏览器
echo ========================================
echo 步骤4: 智能打开浏览器
echo ========================================
echo.

echo 智能检测浏览器...

REM 检查Chrome
echo 检查Chrome浏览器...
where chrome.exe >nul 2>&1
if not errorlevel 1 (
    echo 找到Chrome浏览器
    echo Chrome路径: 
    where chrome.exe
    echo.
    echo 创建Chrome临时用户数据目录...
    if not exist "C:\Temp" mkdir "C:\Temp" >nul 2>&1
    echo 打开Chrome浏览器（无安全限制模式）...
    echo 启动命令: chrome.exe --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"
    start "" "chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"
    echo Chrome已启动，请检查是否打开了无安全限制模式
    goto browser_opened
) else (
    echo 未找到Chrome浏览器
    echo 尝试其他浏览器...
)

REM 检查Edge
where msedge.exe >nul 2>&1
if not errorlevel 1 (
    echo 找到Microsoft Edge浏览器
    echo 打开Edge浏览器...
    start "" "msedge.exe" "http://223.93.139.87:3001/"
    goto browser_opened
)

REM 检查Firefox
where firefox.exe >nul 2>&1
if not errorlevel 1 (
    echo 找到Firefox浏览器
    echo 打开Firefox浏览器...
    start "" "firefox.exe" "http://223.93.139.87:3001/"
    goto browser_opened
)

REM 使用默认浏览器
echo 未找到常用浏览器，使用默认浏览器...
start "" "http://223.93.139.87:3001/"

:browser_opened
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
echo 提示：
echo - 关闭此窗口不会停止服务
echo - 要停止服务，请关闭对应的服务窗口
echo - 或者使用 stop-services.bat 停止所有服务
echo.

REM 保持窗口打开
echo 按任意键关闭此窗口...
pause >nul
