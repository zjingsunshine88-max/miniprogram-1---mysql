@echo off
chcp 65001 >nul
title 刷题小程序服务管理

:menu
cls
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    刷题小程序服务管理                          ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║  1. 启动所有服务                                               ║
echo ║  2. 停止所有服务                                               ║
echo ║  3. 重启API服务                                                ║
echo ║  4. 查看服务状态                                               ║
echo ║  5. 查看服务日志                                               ║
echo ║  6. 部署更新                                                   ║
echo ║  7. 备份数据                                                   ║
echo ║  8. 安装为Windows服务                                          ║
echo ║  9. 卸载Windows服务                                            ║
echo ║  0. 退出                                                       ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

set /p choice="请选择操作 (0-9): "

if "%choice%"=="1" goto start_services
if "%choice%"=="2" goto stop_services
if "%choice%"=="3" goto restart_api
if "%choice%"=="4" goto show_status
if "%choice%"=="5" goto show_logs
if "%choice%"=="6" goto deploy_update
if "%choice%"=="7" goto backup_data
if "%choice%"=="8" goto install_service
if "%choice%"=="9" goto uninstall_service
if "%choice%"=="0" goto exit
goto menu

:start_services
echo.
echo 🚀 启动所有服务...
set NODE_ENV=production
cd /d C:\question-bank\api
pm2 start app.js --name "question-bank-api" --env production
pm2 save
echo ✅ 服务启动完成！
pause
goto menu

:stop_services
echo.
echo 🛑 停止所有服务...
pm2 stop question-bank-api
pm2 delete question-bank-api
taskkill /f /im nginx.exe >nul 2>&1
echo ✅ 服务停止完成！
pause
goto menu

:restart_api
echo.
echo 🔄 重启API服务...
pm2 restart question-bank-api
echo ✅ API服务重启完成！
pause
goto menu

:show_status
echo.
echo 📊 服务状态：
echo.
echo PM2服务状态：
pm2 status
echo.
echo 端口占用情况：
netstat -an | findstr :3002
netstat -an | findstr :80
echo.
echo 进程状态：
tasklist | findstr node
tasklist | findstr nginx
pause
goto menu

:show_logs
echo.
echo 📋 服务日志：
echo.
echo API服务日志 (最近50行)：
pm2 logs question-bank-api --lines 50
echo.
echo 按任意键继续...
pause >nul
goto menu

:deploy_update
echo.
echo 🔄 部署更新...
echo 1. 停止服务
pm2 stop question-bank-api

echo 2. 备份当前版本
set BACKUP_DIR=C:\backup\update_%date:~0,10%_%time:~0,2%-%time:~3,2%
if not exist C:\backup mkdir C:\backup
xcopy C:\question-bank C:\backup\update_%date:~0,10%_%time:~0,2%-%time:~3,2% /E /I

echo 3. 重新构建前端
cd /d C:\question-bank\admin
call npm run build

echo 4. 重启API服务
cd /d C:\question-bank\api
pm2 restart question-bank-api

echo ✅ 更新部署完成！
pause
goto menu

:backup_data
echo.
echo 💾 备份数据...
set BACKUP_DIR=C:\backup\data_%date:~0,10%_%time:~0,2%-%time:~3,2%
if not exist C:\backup mkdir C:\backup

echo 备份数据库...
mysqldump -u root -pLOVEjing96.. practice > "%BACKUP_DIR%_database.sql"

echo 备份代码...
xcopy C:\question-bank "%BACKUP_DIR%" /E /I

echo ✅ 数据备份完成！
echo 备份位置: %BACKUP_DIR%
pause
goto menu

:install_service
echo.
echo 🔧 安装为Windows服务...
pm2-startup install
pm2 start app.js --name "question-bank-api" --env production
pm2 save

REM 创建启动脚本的快捷方式到启动文件夹
copy "%~dp0start-services.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"

echo ✅ Windows服务安装完成！
pause
goto menu

:uninstall_service
echo.
echo 🗑️ 卸载Windows服务...
pm2 stop question-bank-api
pm2 delete question-bank-api
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\start-services.bat"

echo ✅ Windows服务卸载完成！
pause
goto menu

:exit
echo.
echo 👋 感谢使用刷题小程序服务管理工具！
exit
