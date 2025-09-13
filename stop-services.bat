@echo off
chcp 65001 >nul
title 停止刷题小程序服务

echo 🛑 正在停止刷题小程序服务...
echo.

REM 停止PM2服务
echo 📡 停止API服务...
pm2 stop question-bank-api
pm2 delete question-bank-api

REM 停止Nginx
echo 🌐 停止Nginx...
taskkill /f /im nginx.exe >nul 2>&1

echo.
echo ✅ 所有服务停止成功！
echo.
echo 按任意键退出...
pause >nul
