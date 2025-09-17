@echo off
chcp 65001 >nul
title 测试Chrome启动

echo ========================================
echo 测试Chrome启动
echo ========================================
echo.

echo 检查Chrome浏览器位置...
where chrome.exe
echo.

echo 检查Chrome进程...
tasklist | findstr chrome.exe
echo.

echo 创建临时用户数据目录...
if not exist "C:\Temp" mkdir "C:\Temp" >nul 2>&1

echo 尝试启动Chrome（无安全限制模式）...
echo 命令: chrome.exe --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"
echo.

start "" "chrome.exe" --disable-web-security --user-data-dir="C:\Temp" --new-window "http://223.93.139.87:3001/"

echo 等待5秒检查Chrome是否启动...
timeout /t 5 >nul

echo 检查Chrome进程...
tasklist | findstr chrome.exe

echo.
echo 如果Chrome没有启动，请检查：
echo 1. Chrome是否已安装
echo 2. Chrome是否在PATH环境变量中
echo 3. 是否有其他Chrome进程在运行
echo.

pause
