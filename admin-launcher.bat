@echo off
chcp 65001 >nul
title 后台管理系统启动器

:menu
cls
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    后台管理系统启动器                          ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║  1. 使用Vite预览服务器启动 (推荐开发环境)                      ║
echo ║  2. 使用PM2启动 (推荐生产环境)                                ║
echo ║  3. 使用Nginx启动 (推荐生产环境)                              ║
echo ║  4. 使用简单HTTP服务器启动 (临时使用)                          ║
echo ║  5. 检查dist目录状态                                          ║
echo ║  6. 重新构建项目                                              ║
echo ║  0. 退出                                                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM 检查dist目录
if not exist "admin\dist" (
    echo ⚠️  警告: admin\dist目录不存在
    echo 💡 请先运行选项6重新构建项目
    echo.
)

set /p choice="请选择启动方式 (0-6): "

if "%choice%"=="1" goto vite_start
if "%choice%"=="2" goto pm2_start
if "%choice%"=="3" goto nginx_start
if "%choice%"=="4" goto simple_start
if "%choice%"=="5" goto check_dist
if "%choice%"=="6" goto rebuild
if "%choice%"=="0" goto exit
goto menu

:vite_start
echo.
echo 🚀 使用Vite预览服务器启动...
start-admin.bat
goto menu

:pm2_start
echo.
echo 🚀 使用PM2启动...
start-admin-pm2.bat
goto menu

:nginx_start
echo.
echo 🚀 使用Nginx启动...
start-admin-nginx.bat
goto menu

:simple_start
echo.
echo 🚀 使用简单HTTP服务器启动...
start-admin-simple.bat
goto menu

:check_dist
echo.
echo 📁 检查dist目录状态...
if not exist "admin\dist" (
    echo ❌ dist目录不存在
    echo 💡 请先构建项目
) else (
    echo ✅ dist目录存在
    echo.
    echo 📊 目录内容：
    dir admin\dist /b
    echo.
    echo 📏 目录大小：
    for /f %%i in ('dir admin\dist /s /-c ^| find "个文件"') do echo %%i
)
pause
goto menu

:rebuild
echo.
echo 🔨 重新构建项目...
cd /d admin
call npm run build
if errorlevel 1 (
    echo ❌ 构建失败
    echo 💡 请检查错误信息或运行: fix-terser-issue.bat
) else (
    echo ✅ 构建成功！
)
pause
goto menu

:exit
echo.
echo 👋 感谢使用后台管理系统启动器！
exit
