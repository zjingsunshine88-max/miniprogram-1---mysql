@echo off
chcp 65001 >nul
title 立即修复8443端口

echo ================================================
echo           立即修复8443端口
echo ================================================
echo.

cd /d "%~dp0"

:: 1. 启动nginx
echo [1/3] 启动nginx服务...
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul

if exist "C:\nginx\nginx.exe" (
    start "" "C:\nginx\nginx.exe"
    timeout /t 3 >nul
    echo [✓] nginx已启动
) else (
    echo [错误] 未找到nginx.exe
    pause
    exit /b 1
)

:: 2. 检查8443端口
echo.
echo [2/3] 检查8443端口...
timeout /t 2 >nul
netstat -an | findstr ":8443" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 8443端口正在监听
) else (
    echo [错误] 8443端口仍未监听
    echo [信息] 请检查nginx配置文件
    pause
    exit /b 1
)

:: 3. 测试连接
echo.
echo [3/3] 测试连接...
curl -s -k -o nul -w "HTTPS状态: %%{http_code}" https://localhost:8443 2>nul
if errorlevel 1 (
    echo [警告] 本地HTTPS连接测试失败
) else (
    echo [✓] 本地HTTPS连接测试成功
)

echo.
echo ================================================
echo           修复完成！
echo ================================================
echo.
echo [信息] 现在可以访问:
echo - https://practice.insightdata.top:8443/
echo - https://practice.insightdata.top:8443/api/
echo.

:: 询问是否打开浏览器
set /p choice="是否打开浏览器测试? (Y/N): "
if /i "%choice%"=="Y" (
    start "" "https://practice.insightdata.top:8443"
)

pause
