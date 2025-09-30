@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title 一键HTTPS部署 - 8443端口

echo ================================================
echo           一键HTTPS部署 - 8443端口
echo ================================================
echo.

:: 设置错误处理
set "ERROR_OCCURRED=0"

echo 📋 服务配置:
echo - 域名: practice.insightdata.top
echo - 协议: HTTPS
echo - 端口: 8443
echo - API端口: 3002
echo - 访问地址: https://practice.insightdata.top:8443
echo - API地址: https://practice.insightdata.top:8443/api/
echo.

REM 进入项目根目录
cd /d "%~dp0"

:: 检查是否在正确的目录
echo [1/8] 检查项目目录...
if not exist "admin\package.json" (
    echo [错误] 未找到admin\package.json文件
    echo [信息] 当前目录: %CD%
    echo [信息] 请确保在项目根目录运行此脚本
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] 项目目录验证通过

:: 检查Node.js环境
echo.
echo [2/8] 检查Node.js环境...
where node >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到Node.js
    echo [信息] 请先安装Node.js: https://nodejs.org/
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] Node.js已安装

:: 检查npm环境
echo [检查] npm环境...
where npm >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到npm
    echo [信息] 请重新安装Node.js
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] npm已安装

:: 检查SSL证书
echo.
echo [3/8] 检查SSL证书...
if not exist "C:\certificates\practice.insightdata.top.pem" (
    echo [错误] SSL证书文件不存在: C:\certificates\practice.insightdata.top.pem
    echo [信息] 请按照 WINDOWS_SSL_SETUP_GUIDE.md 配置SSL证书
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)

if not exist "C:\certificates\practice.insightdata.top.key" (
    echo [错误] SSL私钥文件不存在: C:\certificates\practice.insightdata.top.key
    echo [信息] 请按照 WINDOWS_SSL_SETUP_GUIDE.md 配置SSL证书
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] SSL证书文件检查通过

:: 配置Nginx 8443端口
echo.
echo [4/8] 配置Nginx 8443端口...
cd /d C:\nginx

:: 复制8443端口配置文件
if not exist "conf\practice.insightdata.top.conf" (
    echo [信息] 复制8443端口配置文件...
    if exist "%~dp0nginx-8443.conf" (
        copy "%~dp0nginx-8443.conf" "conf\practice.insightdata.top.conf" >nul
        echo [✓] 8443端口配置文件已复制
    ) else (
        echo [错误] 未找到nginx-8443.conf配置文件
        set "ERROR_OCCURRED=1"
        goto :ERROR_HANDLER
    )
) else (
    echo [信息] 更新8443端口配置文件...
    copy "%~dp0nginx-8443.conf" "conf\practice.insightdata.top.conf" >nul
    echo [✓] 8443端口配置文件已更新
)

:: 停止并重启nginx
echo [信息] 重启nginx服务...
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul

if exist "C:\nginx\nginx.exe" (
    start "" "C:\nginx\nginx.exe"
    timeout /t 3 >nul
    
    :: 检查nginx是否启动成功
    tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
    if errorlevel 1 (
        echo [警告] nginx可能未正常启动
    ) else (
        echo [✓] nginx已启动
    )
) else (
    echo [错误] 未找到nginx.exe
    echo [信息] 请手动启动nginx: C:\nginx\nginx.exe
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)

:: 启动API服务
echo.
echo [5/8] 启动API服务...
echo [信息] 检查API服务状态...

:: 检查是否已有API服务在运行
netstat -an | findstr ":3002" >nul
if "%ERRORLEVEL%"=="0" (
    echo [信息] API服务已在运行
) else (
    echo [信息] 正在启动API服务...
    
    :: 设置生产环境变量
    set NODE_ENV=production
    set DB_PASSWORD=LOVEjing96..
    
    :: 检查启动脚本
    if exist "%~dp0start-server.bat" (
        echo [信息] 使用start-server.bat启动API服务...
        cd /d "%~dp0"
        start "" "start-server.bat"
        timeout /t 5 >nul
    ) else if exist "%~dp0server\package.json" (
        echo [信息] 直接启动server目录下的API服务...
        cd /d "%~dp0server"
        start "API Server" cmd /c "set NODE_ENV=production && set DB_PASSWORD=LOVEjing96.. && npm run start:prod"
        timeout /t 5 >nul
    ) else (
        echo [错误] 未找到API服务启动脚本
        echo [信息] 请手动启动API服务
        set "ERROR_OCCURRED=1"
        goto :ERROR_HANDLER
    )
    
    :: 检查API服务是否启动成功
    netstat -an | findstr ":3002" >nul
    if "%ERRORLEVEL%"=="0" (
        echo [✓] API服务启动成功
    ) else (
        echo [警告] API服务可能未正常启动
    )
)

:: 构建Admin项目
echo.
echo [6/8] 构建Admin项目...
cd /d "%~dp0"

:: 进入admin目录
pushd admin
if errorlevel 1 (
    echo [错误] 无法进入admin目录
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)

:: 设置环境变量 - 使用8443端口
set VITE_SERVER_URL=https://practice.insightdata.top:8443
set VITE_APP_TITLE=刷题小程序后台管理系统
set VITE_APP_VERSION=1.0.0

echo [信息] 设置环境变量...
echo [信息] VITE_SERVER_URL=https://practice.insightdata.top:8443

:: 安装依赖
if not exist "node_modules" (
    echo [信息] 正在安装依赖，请稍候...
    call npm install --silent
    if errorlevel 1 (
        echo [错误] 依赖安装失败
        set "ERROR_OCCURRED=1"
        goto :ERROR_HANDLER
    )
    echo [✓] 依赖安装完成
) else (
    echo [✓] 依赖已存在
)

:: 构建项目
echo [信息] 正在构建生产版本，请稍候...
call npm run build
if errorlevel 1 (
    echo [错误] 构建失败
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)

:: 检查构建结果
if not exist "dist" (
    echo [错误] 构建后未找到dist目录
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] 构建完成

:: 返回项目根目录
popd

:: 复制文件
echo.
echo [7/8] 复制Admin文件...
if not exist "C:\admin" (
    mkdir "C:\admin" 2>nul
    if errorlevel 1 (
        echo [错误] 无法创建C:\admin目录
        set "ERROR_OCCURRED=1"
        goto :ERROR_HANDLER
    )
    echo [信息] 创建目录: C:\admin
)

:: 复制dist文件
if exist "C:\admin\dist" (
    rmdir /s /q "C:\admin\dist" 2>nul
)
xcopy "admin\dist" "C:\admin\dist\" /E /I /Q /Y >nul
if errorlevel 1 (
    echo [错误] 文件复制失败
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] 文件复制完成

:: 检查复制结果
if not exist "C:\admin\dist\index.html" (
    echo [警告] 复制可能不完整，未找到index.html
)

:: 验证服务状态
echo.
echo [8/8] 验证服务状态...
timeout /t 3 >nul

echo [测试] 检查服务状态...

:: 检查nginx进程
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [✓] Nginx服务正在运行
) else (
    echo [错误] Nginx服务未运行
    set "ERROR_OCCURRED=1"
)

:: 检查8443端口
netstat -an | findstr ":8443" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 8443端口正在监听
) else (
    echo [错误] 8443端口未监听
    set "ERROR_OCCURRED=1"
)

:: 检查API服务
netstat -an | findstr ":3002" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] API服务端口3002监听正常
) else (
    echo [错误] API服务端口3002未监听
    set "ERROR_OCCURRED=1"
)

:: 测试连接
echo [测试] 测试服务连接...
curl -s -k -o nul -w "HTTPS状态: %%{http_code}" https://localhost:8443 2>nul
if errorlevel 1 (
    echo [警告] HTTPS连接测试失败
) else (
    echo [✓] HTTPS连接测试成功
)

if "%ERROR_OCCURRED%"=="1" (
    goto :ERROR_HANDLER
)

echo.
echo ================================================
echo           HTTPS部署完成！
echo ================================================
echo.
echo [信息] 服务配置:
echo        - Admin管理后台: C:\admin\dist
echo        - API服务: 3002端口
echo        - Nginx代理: 8443端口
echo.
echo [信息] 访问地址:
echo        - 管理后台: https://practice.insightdata.top:8443
echo        - API接口: https://practice.insightdata.top:8443/api/
echo        - 健康检查: https://practice.insightdata.top:8443/health
echo.
echo [提示] 服务状态:
echo        - Admin前端: 已部署到C:\admin\dist
echo        - API后端: 已启动在3002端口
echo        - Nginx代理: 已配置8443端口
echo        - SSL证书: 已配置
echo.

:: 询问是否打开浏览器
set /p choice="是否打开浏览器测试? (Y/N): "
if /i "%choice%"=="Y" (
    start "" "https://practice.insightdata.top:8443"
)

echo.
echo [提示] 如果外网无法访问，请检查:
echo        1. 防火墙设置 (8443端口)
echo        2. 云服务器安全组设置
echo        3. SSL证书是否有效
echo        4. 域名解析是否正确
echo.

echo 按任意键退出...
pause >nul
exit /b 0

:ERROR_HANDLER
echo.
echo ================================================
echo           部署失败！
echo ================================================
echo.
echo [错误] 部署过程中发生错误
echo [信息] 请检查上述错误信息并重试
echo.
echo [提示] 常见问题解决:
echo        1. 检查SSL证书文件是否存在
echo        2. 检查Node.js和npm是否正确安装
echo        3. 检查端口是否被占用
echo        4. 检查nginx配置文件是否正确
echo.
echo 按任意键退出...
pause >nul
exit /b 1
