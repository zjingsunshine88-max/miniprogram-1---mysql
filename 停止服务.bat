@echo off
chcp 65001 >nul
title 停止所有服务

echo ========================================
echo 🛑 停止刷题小程序管理系统服务
echo ========================================
echo.

REM 设置颜色
color 0C

echo 🔍 正在查找并停止相关进程...
echo.

REM 停止Node.js进程（API服务器）
echo 📦 停止API服务器...
tasklist | findstr "node.exe" >nul
if not errorlevel 1 (
    for /f "tokens=2" %%a in ('tasklist ^| findstr "node.exe"') do (
        echo 停止Node.js进程: %%a
        taskkill /f /pid %%a >nul 2>&1
    )
    echo ✅ API服务器已停止
) else (
    echo ℹ️  未找到Node.js进程
)

echo.

REM 停止Chrome进程（如果使用了临时用户数据目录）
echo 🌐 停止Chrome浏览器...
tasklist | findstr "chrome.exe" >nul
if not errorlevel 1 (
    echo 停止Chrome进程...
    taskkill /f /im chrome.exe >nul 2>&1
    echo ✅ Chrome浏览器已停止
) else (
    echo ℹ️  未找到Chrome进程
)

echo.

REM 清理临时文件
echo 🧹 清理临时文件...
if exist "C:\Temp" (
    echo 清理Chrome临时用户数据...
    rmdir /s /q "C:\Temp" >nul 2>&1
    echo ✅ 临时文件已清理
) else (
    echo ℹ️  无需清理临时文件
)

echo.

REM 检查端口状态
echo 🔍 检查端口状态...
netstat -an | findstr :3001 >nul
if not errorlevel 1 (
    echo ⚠️  端口3001仍被占用
) else (
    echo ✅ 端口3001已释放
)

netstat -an | findstr :3002 >nul
if not errorlevel 1 (
    echo ⚠️  端口3002仍被占用
) else (
    echo ✅ 端口3002已释放
)

echo.
echo ========================================
echo 🎉 服务停止完成！
echo ========================================
echo.
echo 💡 提示：
echo - 所有相关进程已停止
echo - 临时文件已清理
echo - 端口已释放
echo.

echo 按任意键关闭此窗口...
pause >nul
