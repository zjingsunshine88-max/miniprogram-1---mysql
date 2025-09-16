@echo off
chcp 65001 >nul
title 使用PM2启动后台管理系统

echo 🚀 使用PM2启动后台管理系统...
echo.

REM 进入admin目录
cd /d "%~dp0admin"

REM 检查dist目录是否存在
if not exist "dist" (
    echo ❌ 错误: dist目录不存在
    echo 💡 请先运行构建命令: npm run build
    pause
    exit /b 1
)

echo ✅ dist目录检查通过
echo.

REM 检查PM2是否安装
pm2 --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到PM2
    echo 💡 请先安装PM2: npm install -g pm2
    pause
    exit /b 1
)

echo 🔍 检查现有admin服务...
pm2 describe admin-frontend >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  发现现有admin-frontend服务
    set /p RESTART_SERVICE="是否要重启服务？(y/n): "
    if /i "!RESTART_SERVICE!"=="y" (
        pm2 restart admin-frontend
        echo ✅ 服务已重启
        goto show_status
    ) else (
        pm2 stop admin-frontend
        pm2 delete admin-frontend
    )
)

echo 📦 创建PM2配置文件...
echo { > pm2.config.js
echo   "name": "admin-frontend", >> pm2.config.js
echo   "script": "node_modules/vite/bin/vite.js", >> pm2.config.js
echo   "args": "preview --port 3001 --host 0.0.0.0", >> pm2.config.js
echo   "cwd": "%~dp0admin", >> pm2.config.js
echo   "env": { >> pm2.config.js
echo     "NODE_ENV": "production" >> pm2.config.js
echo   }, >> pm2.config.js
echo   "log_file": "logs/admin-frontend.log", >> pm2.config.js
echo   "out_file": "logs/admin-frontend-out.log", >> pm2.config.js
echo   "error_file": "logs/admin-frontend-error.log", >> pm2.config.js
echo   "log_date_format": "YYYY-MM-DD HH:mm:ss Z" >> pm2.config.js
echo } >> pm2.config.js

REM 创建日志目录
if not exist "logs" mkdir "logs"

echo 🚀 启动admin服务...
pm2 start pm2.config.js

echo.
echo ✅ admin服务启动成功！
echo.

:show_status
echo 📊 服务状态：
pm2 status

echo.
echo 🌐 访问地址：
echo   本地访问: http://localhost:3001
echo   远程访问: http://223.93.139.87:3001
echo.

echo 💡 常用命令：
echo   查看日志: pm2 logs admin-frontend
echo   重启服务: pm2 restart admin-frontend
echo   停止服务: pm2 stop admin-frontend
echo   删除服务: pm2 delete admin-frontend
echo.

echo 按任意键退出...
pause >nul
