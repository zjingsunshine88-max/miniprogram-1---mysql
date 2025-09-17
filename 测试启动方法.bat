@echo off
chcp 65001 >nul
title 测试启动方法

echo ========================================
echo 🧪 测试不同的启动方法
echo ========================================
echo.

REM 设置颜色
color 0E

echo 📋 可用的启动方法：
echo 1. start-admin.bat (使用 npx vite preview)
echo 2. start-admin-simple.bat (使用 http-server)
echo 3. start-admin-powershell.bat (使用 PowerShell)
echo 4. start-admin-no-browser.bat (使用 vite preview)
echo.

set /p choice="请选择要测试的方法 (1-4): "

if "%choice%"=="1" (
    echo 测试方法1: npx vite preview
    call start-admin.bat
) else if "%choice%"=="2" (
    echo 测试方法2: http-server
    call start-admin-simple.bat
) else if "%choice%"=="3" (
    echo 测试方法3: PowerShell
    call start-admin-powershell.bat
) else if "%choice%"=="4" (
    echo 测试方法4: vite preview (no-browser)
    call start-admin-no-browser.bat
) else (
    echo ❌ 无效选择
    pause
    exit /b 1
)

echo.
echo 测试完成！请检查是否自动打开了浏览器。
echo 如果没有自动打开浏览器，说明该方法有效。
echo.

pause
