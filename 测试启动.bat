@echo off
chcp 65001 >nul
title 测试启动脚本

echo ========================================
echo 🧪 测试启动脚本
echo ========================================
echo.

REM 设置颜色
color 0E

echo 📋 测试步骤：
echo 1. 构建admin项目
echo 2. 启动admin服务（无浏览器模式）
echo 3. 等待服务启动
echo 4. 打开Chrome浏览器
echo.

REM 步骤1: 构建admin
echo ========================================
echo 📦 步骤1: 构建admin项目
echo ========================================
echo.

cd /d "%~dp0admin"

echo 📦 开始构建admin项目...
call npm run build

if errorlevel 1 (
    echo ❌ 构建失败！
    pause
    exit /b 1
)

echo ✅ admin构建成功！
echo.

REM 步骤2: 启动admin服务
echo ========================================
echo 🎨 步骤2: 启动admin服务
echo ========================================
echo.

cd /d "%~dp0"

echo 🚀 启动admin服务（无浏览器模式）...
start "Admin服务-测试" cmd /c "start-admin-no-browser.bat"

REM 等待服务启动
echo ⏳ 等待admin服务启动...
timeout /t 8 >nul

REM 检查服务是否启动
:check_service
netstat -an | findstr :3001 >nul
if errorlevel 1 (
    echo ⏳ admin服务启动中，请稍候...
    timeout /t 2 >nul
    goto check_service
)

echo ✅ admin服务启动成功！
echo.

REM 步骤3: 打开Chrome浏览器
echo ========================================
echo 🌐 步骤3: 打开Chrome浏览器
echo ========================================
echo.

echo 🔍 检查Chrome浏览器...
where chrome.exe >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Chrome浏览器
    echo 💡 请手动打开浏览器访问: http://223.93.139.87:3001/
    pause
    exit /b 1
)

echo ✅ Chrome浏览器检查通过
echo.

REM 创建临时用户数据目录
echo 📁 创建Chrome临时用户数据目录...
if not exist "C:\Temp" mkdir "C:\Temp" >nul 2>&1

echo 🌐 打开Chrome浏览器（无安全限制模式）...
start "" "chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"

echo.
echo ========================================
echo 🎉 测试完成！
echo ========================================
echo.
echo 📋 服务状态：
echo ✅ Admin服务: http://223.93.139.87:3001
echo ✅ Chrome浏览器: 已打开（无安全限制模式）
echo.
echo 💡 如果Chrome打开的是正确的地址，说明修改成功！
echo.

echo 按任意键关闭此窗口...
pause >nul
