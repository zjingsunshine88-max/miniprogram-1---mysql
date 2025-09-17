@echo off
chcp 65001 >nul
title 快速重启服务

echo ========================================
echo 🔄 快速重启刷题小程序管理系统
echo ========================================
echo.

REM 设置颜色
color 0E

echo 🛑 正在停止现有服务...
echo.

REM 停止所有相关进程
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

REM 等待进程完全停止
echo ⏳ 等待进程完全停止...
timeout /t 3 >nul

echo 🚀 重新启动服务...
echo.

REM 调用一键启动脚本
call "一键启动.bat"
