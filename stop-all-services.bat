@echo off
chcp 65001 >nul
title 停止所有服务

echo 🛑 停止所有服务...
echo.

echo 🔍 检查并终止Node.js进程...
tasklist | findstr node.exe >nul
if not errorlevel 1 (
    echo 发现Node.js进程，正在终止...
    taskkill /IM node.exe /F >nul 2>&1
    echo ✅ Node.js进程已终止
) else (
    echo ✅ 未发现Node.js进程
)

echo.
echo 🔍 检查并终止Nginx进程...
tasklist | findstr nginx.exe >nul
if not errorlevel 1 (
    echo 发现Nginx进程，正在终止...
    taskkill /IM nginx.exe /F >nul 2>&1
    echo ✅ Nginx进程已终止
) else (
    echo ✅ 未发现Nginx进程
)

echo.
echo 🔍 检查端口占用情况...
echo 端口3002状态:
netstat -ano | findstr :3002
if errorlevel 1 (
    echo ✅ 端口3002已释放
) else (
    echo ⚠️  端口3002仍被占用
)

echo 端口3000状态:
netstat -ano | findstr :3000
if errorlevel 1 (
    echo ✅ 端口3000已释放
) else (
    echo ⚠️  端口3000仍被占用
)

echo.
echo 🎉 服务停止完成！
echo.
pause
