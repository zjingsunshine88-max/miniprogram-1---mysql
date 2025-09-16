@echo off
chcp 65001 >nul
title API服务器启动器

:menu
cls
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                      API服务器启动器                          ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║  1. 开发环境启动服务器 (nodemon自动重启)                       ║
echo ║  2. 直接启动服务器 (普通模式)                                 ║
echo ║  3. 生产环境启动服务器                                        ║
echo ║  4. 使用PM2启动服务器 (推荐生产环境)                          ║
echo ║  5. 设置环境变量                                              ║
echo ║  6. 检查服务器状态                                            ║
echo ║  7. 查看服务器日志                                            ║
echo ║  0. 退出                                                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM 检查server目录
if not exist "server\app.js" (
    echo ❌ 错误: server\app.js文件不存在
    echo 💡 请确认项目结构正确
    pause
    exit /b 1
)

set /p choice="请选择启动方式 (0-7): "

if "%choice%"=="1" goto dev_start
if "%choice%"=="2" goto direct_start
if "%choice%"=="3" goto prod_start
if "%choice%"=="4" goto pm2_start
if "%choice%"=="5" goto set_env
if "%choice%"=="6" goto check_status
if "%choice%"=="7" goto show_logs
if "%choice%"=="0" goto exit
goto menu

:dev_start
echo.
echo 🚀 开发环境启动服务器 (nodemon自动重启)...
cd /d server
set NODE_ENV=development
set DB_PASSWORD=1234
echo NODE_ENV=development
echo DB_PASSWORD=1234

REM 检查nodemon是否安装
call npm list nodemon >nul 2>&1
if errorlevel 1 (
    echo 📦 安装nodemon...
    call npm install nodemon --save-dev
)

echo 🌐 启动开发服务器...
echo 访问地址: http://localhost:3002
echo 特性: 文件变化时自动重启
echo 按 Ctrl+C 停止服务
echo.
call npm run dev
pause
goto menu

:direct_start
echo.
echo 🚀 直接启动服务器 (开发模式)...
cd /d server
echo 启动地址: http://localhost:3002
echo 按 Ctrl+C 停止服务
echo.
node app.js
pause
goto menu

:prod_start
echo.
echo 🚀 生产环境启动服务器...
cd /d server
set NODE_ENV=production
echo NODE_ENV=production
echo 启动地址: http://223.93.139.87:3002
echo 按 Ctrl+C 停止服务
echo.
node app.js
pause
goto menu

:pm2_start
echo.
echo 🚀 使用PM2启动服务器...

REM 检查PM2是否安装
pm2 --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到PM2
    echo 💡 请先安装PM2: npm install -g pm2
    pause
    goto menu
)

cd /d server
set NODE_ENV=production

echo 🔍 检查现有服务...
pm2 describe question-bank-api >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  发现现有服务，正在重启...
    pm2 restart question-bank-api
) else (
    echo 🚀 启动新服务...
    pm2 start app.js --name "question-bank-api" --env production
)

pm2 save
echo ✅ PM2服务启动完成！
echo.
echo 📊 服务状态：
pm2 status
echo.
echo 💡 管理命令：
echo   查看日志: pm2 logs question-bank-api
echo   重启服务: pm2 restart question-bank-api
echo   停止服务: pm2 stop question-bank-api
pause
goto menu

:set_env
echo.
echo 🔧 设置环境变量...
call set-env-windows.bat
pause
goto menu

:check_status
echo.
echo 📊 检查服务器状态...
echo.
echo 🔍 端口占用情况：
netstat -an | findstr :3002
if errorlevel 1 (
    echo ❌ 端口3002未被占用，服务器可能未启动
) else (
    echo ✅ 端口3002已被占用，服务器可能正在运行
)

echo.
echo 🔍 PM2服务状态：
pm2 --version >nul 2>&1
if not errorlevel 1 (
    pm2 status
) else (
    echo PM2未安装
)

echo.
echo 🔍 Node.js进程：
tasklist | findstr node
pause
goto menu

:show_logs
echo.
echo 📋 查看服务器日志...
pm2 --version >nul 2>&1
if not errorlevel 1 (
    pm2 logs question-bank-api --lines 50
) else (
    echo PM2未安装，无法查看日志
    echo 💡 请安装PM2或查看控制台输出
)
pause
goto menu

:exit
echo.
echo 👋 感谢使用API服务器启动器！
exit
