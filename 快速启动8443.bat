@echo off
chcp 65001 >nul
title 快速启动8443端口服务

echo ================================================
echo           快速启动8443端口服务
echo ================================================
echo.

echo 📋 服务配置:
echo - 域名: practice.insightdata.top
echo - 端口: 8443 (HTTPS)
echo - API: 3002端口
echo - 访问: https://practice.insightdata.top:8443
echo.

cd /d "%~dp0"

:: 1. 检查SSL证书
echo [1/4] 检查SSL证书...
if not exist "C:\certificates\practice.insightdata.top.pem" (
    echo [错误] SSL证书不存在
    pause
    exit /b 1
)
echo [✓] SSL证书正常

:: 2. 配置nginx
echo.
echo [2/4] 配置nginx...
cd /d C:\nginx
if exist "%~dp0nginx-8443.conf" (
    copy "%~dp0nginx-8443.conf" "conf\practice.insightdata.top.conf" >nul
    echo [✓] nginx配置已更新
)

:: 重启nginx
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul
start "" "C:\nginx\nginx.exe"
timeout /t 3 >nul
echo [✓] nginx已启动

:: 3. 启动API服务
echo.
echo [3/4] 启动API服务...
cd /d "%~dp0"

:: 检查API服务是否已运行
netstat -an | findstr ":3002" >nul
if errorlevel 1 (
    if exist "start-server.bat" (
        start "" "start-server.bat"
        echo [信息] 正在启动API服务...
        timeout /t 5 >nul
    ) else if exist "server\package.json" (
        cd server
        start "API Server" cmd /c "set NODE_ENV=production && set DB_PASSWORD=LOVEjing96.. && npm run start:prod"
        cd ..
        echo [信息] 正在启动API服务...
        timeout /t 5 >nul
    )
)

:: 检查API服务状态
netstat -an | findstr ":3002" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] API服务运行正常
) else (
    echo [警告] API服务可能未启动
)

:: 4. 检查admin文件
echo.
echo [4/4] 检查admin文件...
if exist "C:\admin\dist\index.html" (
    echo [✓] Admin文件已部署
) else (
    echo [警告] Admin文件未部署，请运行部署脚本
)

:: 测试连接
echo.
echo [测试] 检查8443端口...
netstat -an | findstr ":8443" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 8443端口监听正常
) else (
    echo [错误] 8443端口未监听
)

echo.
echo ================================================
echo           服务启动完成！
echo ================================================
echo.
echo [访问地址]
echo - 管理后台: https://practice.insightdata.top:8443
echo - API接口: https://practice.insightdata.top:8443/api/
echo - 健康检查: https://practice.insightdata.top:8443/health
echo.

:: 询问是否打开浏览器
set /p choice="是否打开浏览器测试? (Y/N): "
if /i "%choice%"=="Y" (
    start "" "https://practice.insightdata.top:8443"
)

echo.
echo 按任意键退出...
pause >nul
