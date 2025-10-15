@echo off
chcp 65001 >nul
echo ========================================
echo Nginx启动调试
echo ========================================
echo.

echo [信息] 当前工作目录: %CD%
echo [信息] 脚本所在目录: %~dp0
echo.

:: 检查nginx安装
echo [信息] 检查nginx安装...
if exist "C:\nginx\nginx.exe" (
    echo [OK] nginx.exe存在: C:\nginx\nginx.exe
) else (
    echo [ERROR] nginx.exe不存在: C:\nginx\nginx.exe
    goto :end
)

:: 检查nginx配置文件
echo [信息] 检查nginx配置文件...
if exist "C:\nginx\conf\nginx.conf" (
    echo [OK] nginx.conf存在: C:\nginx\conf\nginx.conf
) else (
    echo [ERROR] nginx.conf不存在: C:\nginx\conf\nginx.conf
    goto :end
)

:: 检查SSL配置文件
echo [信息] 检查SSL配置文件...
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    echo [OK] admin-ssl.conf存在: C:\nginx\conf.d\admin-ssl.conf
) else (
    echo [WARNING] admin-ssl.conf不存在: C:\nginx\conf.d\admin-ssl.conf
)

:: 检查SSL证书
echo [信息] 检查SSL证书...
if exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [OK] SSL证书存在: C:\certificates\admin.practice.insightdata.top.pem
) else (
    echo [ERROR] SSL证书不存在: C:\certificates\admin.practice.insightdata.top.pem
)

if exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [OK] SSL私钥存在: C:\certificates\admin.practice.insightdata.top.key
) else (
    echo [ERROR] SSL私钥不存在: C:\certificates\admin.practice.insightdata.top.key
)

:: 停止现有nginx进程
echo [信息] 停止现有nginx进程...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: 检查端口占用
echo [信息] 检查端口占用...
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] 端口80被占用
    netstat -ano | find ":80 "
) else (
    echo [OK] 端口80未被占用
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] 端口8443被占用
    netstat -ano | find ":8443 "
) else (
    echo [OK] 端口8443未被占用
)

:: 尝试启动nginx
echo [信息] 尝试启动nginx...
cd /d C:\nginx
echo [信息] 当前目录: %CD%

echo [信息] 启动nginx...
start "Nginx Debug" nginx.exe
timeout /t 3 /nobreak >nul

:: 检查nginx进程
echo [信息] 检查nginx进程...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx进程已启动
    tasklist /fi "imagename eq nginx.exe" /fo table
) else (
    echo [ERROR] nginx进程未启动
)

:: 检查端口监听
echo [信息] 检查端口监听...
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 端口80正在监听
) else (
    echo [ERROR] 端口80未监听
)

netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 端口8443正在监听
) else (
    echo [ERROR] 端口8443未监听
)

:: 显示所有监听端口
echo [信息] 显示所有监听端口...
netstat -an | find "LISTENING" | find ":80\|:443\|:8443"

:: 检查nginx错误日志
echo [信息] 检查nginx错误日志...
if exist "C:\nginx\logs\error.log" (
    echo [信息] 错误日志内容:
    type C:\nginx\logs\error.log
) else (
    echo [WARNING] 错误日志文件不存在
)

cd /d "%~dp0"

:end
echo.
echo ========================================
echo 调试完成
echo ========================================
echo.
echo 如果nginx未启动，请检查:
echo 1. 配置文件语法是否正确
echo 2. 端口是否被其他程序占用
echo 3. SSL证书文件是否存在
echo 4. 是否有足够的权限启动nginx
echo.
echo 按任意键退出...
pause >nul
