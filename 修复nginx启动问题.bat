@echo off
chcp 65001 >nul
title 修复nginx启动问题

echo ================================================
echo           修复nginx启动问题
echo ================================================
echo.

cd /d "%~dp0"

:: 1. 停止nginx进程
echo [1/4] 停止nginx进程...
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul
echo [✓] nginx进程已停止

:: 2. 更新nginx配置文件
echo.
echo [2/4] 更新nginx配置文件...
if exist "nginx-8443.conf" (
    copy "nginx-8443.conf" "C:\nginx\conf\practice.insightdata.top.conf" >nul
    echo [✓] nginx配置文件已更新
) else (
    echo [错误] 未找到nginx-8443.conf配置文件
    pause
    exit /b 1
)

:: 3. 测试nginx配置
echo.
echo [3/4] 测试nginx配置...
cd /d C:\nginx
nginx.exe -t
if errorlevel 1 (
    echo [错误] nginx配置测试失败
    echo [信息] 请检查配置文件
    pause
    exit /b 1
) else (
    echo [✓] nginx配置测试通过
)

:: 4. 启动nginx
echo.
echo [4/4] 启动nginx服务...
start "" "C:\nginx\nginx.exe"
timeout /t 3 >nul

:: 检查nginx是否启动成功
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if errorlevel 1 (
    echo [错误] nginx启动失败
    echo [信息] 请检查错误日志: C:\nginx\logs\error.log
    pause
    exit /b 1
) else (
    echo [✓] nginx启动成功
)

:: 检查8443端口
echo.
echo [验证] 检查8443端口...
timeout /t 2 >nul
netstat -an | findstr ":8443" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 8443端口正在监听
    netstat -an | findstr ":8443"
) else (
    echo [错误] 8443端口未监听
)

:: 测试连接
echo.
echo [验证] 测试HTTPS连接...
curl -s -k -o nul -w "HTTPS状态: %%{http_code}" https://localhost:8443 2>nul
if errorlevel 1 (
    echo [警告] HTTPS连接测试失败
) else (
    echo [✓] HTTPS连接测试成功
)

echo.
echo ================================================
echo           修复完成！
echo ================================================
echo.
echo [信息] nginx已成功启动
echo [信息] 8443端口已监听
echo [信息] 访问地址: https://practice.insightdata.top:8443
echo.

:: 询问是否打开浏览器
set /p choice="是否打开浏览器测试? (Y/N): "
if /i "%choice%"=="Y" (
    start "" "https://practice.insightdata.top:8443"
)

echo.
echo 按任意键退出...
pause >nul
