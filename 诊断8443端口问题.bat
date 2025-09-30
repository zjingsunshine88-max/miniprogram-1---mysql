@echo off
chcp 65001 >nul
title 诊断8443端口访问问题

echo ================================================
echo           诊断8443端口访问问题
echo ================================================
echo.

echo 🔍 目标地址:
echo - Admin: https://practice.insightdata.top:8443/
echo - API: https://practice.insightdata.top:8443/api/
echo.

cd /d "%~dp0"

:: 1. 检查本地服务状态
echo [1/8] 检查本地服务状态...
echo.

:: 检查nginx进程
echo 📋 检查nginx进程:
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ nginx进程正在运行
    tasklist /FI "IMAGENAME eq nginx.exe" /FO TABLE
) else (
    echo ❌ nginx进程未运行
)

echo.

:: 检查8443端口监听
echo 📋 检查8443端口监听:
netstat -an | findstr ":8443" >nul
if "%ERRORLEVEL%"=="0" (
    echo ✅ 8443端口正在监听
    echo [详细信息:]
    netstat -an | findstr ":8443"
) else (
    echo ❌ 8443端口未监听
)

echo.

:: 检查API服务
echo 📋 检查API服务:
netstat -an | findstr ":3002" >nul
if "%ERRORLEVEL%"=="0" (
    echo ✅ API服务3002端口正在监听
    echo [详细信息:]
    netstat -an | findstr ":3002"
) else (
    echo ❌ API服务3002端口未监听
)

echo.

:: 2. 检查nginx配置
echo [2/8] 检查nginx配置...
echo.

if exist "C:\nginx\conf\practice.insightdata.top.conf" (
    echo ✅ nginx配置文件存在
    echo [检查配置内容:]
    findstr "8443" "C:\nginx\conf\practice.insightdata.top.conf"
    if errorlevel 1 (
        echo ❌ 配置文件中未找到8443端口
    ) else (
        echo ✅ 配置文件中包含8443端口
    )
) else (
    echo ❌ nginx配置文件不存在
)

echo.

:: 3. 检查SSL证书
echo [3/8] 检查SSL证书...
echo.

if exist "C:\certificates\practice.insightdata.top.pem" (
    echo ✅ SSL证书文件存在
    for %%A in ("C:\certificates\practice.insightdata.top.pem") do echo [信息] 证书文件大小: %%~zA bytes
) else (
    echo ❌ SSL证书文件不存在: C:\certificates\practice.insightdata.top.pem
)

if exist "C:\certificates\practice.insightdata.top.key" (
    echo ✅ SSL私钥文件存在
    for %%A in ("C:\certificates\practice.insightdata.top.key") do echo [信息] 私钥文件大小: %%~zA bytes
) else (
    echo ❌ SSL私钥文件不存在: C:\certificates\practice.insightdata.top.key
)

echo.

:: 4. 检查admin文件
echo [4/8] 检查admin文件...
echo.

if exist "C:\admin\dist\index.html" (
    echo ✅ admin文件已部署
    for %%A in ("C:\admin\dist\index.html") do echo [信息] index.html大小: %%~zA bytes
) else (
    echo ❌ admin文件未部署
)

if exist "C:\admin\dist\assets" (
    echo ✅ assets目录存在
    for /f %%i in ('dir "C:\admin\dist\assets" /b 2^>nul ^| find /c /v ""') do echo [信息] assets包含 %%i 个文件
) else (
    echo ❌ assets目录不存在
)

echo.

:: 5. 检查防火墙设置
echo [5/8] 检查防火墙设置...
echo.

echo 📋 检查Windows防火墙规则:
netsh advfirewall firewall show rule name="8443" >nul 2>&1
if errorlevel 1 (
    echo ❌ 未找到8443端口防火墙规则
    echo [建议] 添加防火墙规则: netsh advfirewall firewall add rule name="8443" dir=in action=allow protocol=TCP localport=8443
) else (
    echo ✅ 找到8443端口防火墙规则
    netsh advfirewall firewall show rule name="8443"
)

echo.

:: 6. 测试本地连接
echo [6/8] 测试本地连接...
echo.

echo 📋 测试本地HTTPS连接:
curl -s -k -o nul -w "HTTP状态码: %%{http_code}" https://localhost:8443 2>nul
if errorlevel 1 (
    echo ❌ 本地HTTPS连接失败
) else (
    echo ✅ 本地HTTPS连接成功
)

echo 📋 测试本地API连接:
curl -s -o nul -w "HTTP状态码: %%{http_code}" http://localhost:3002/api/health 2>nul
if errorlevel 1 (
    echo ❌ 本地API连接失败
) else (
    echo ✅ 本地API连接成功
)

echo.

:: 7. 检查域名解析
echo [7/8] 检查域名解析...
echo.

echo 📋 检查域名解析:
nslookup practice.insightdata.top 2>nul | findstr "Address"
if errorlevel 1 (
    echo ❌ 域名解析失败
) else (
    echo ✅ 域名解析成功
    nslookup practice.insightdata.top
)

echo.

:: 8. 检查云服务器配置
echo [8/8] 检查云服务器配置...
echo.

echo 📋 云服务器安全组检查:
echo [信息] 请手动检查以下项目:
echo 1. 云服务器安全组是否开放8443端口
echo 2. 入方向规则: 端口8443, 协议TCP, 源0.0.0.0/0
echo 3. 云服务器防火墙是否允许8443端口
echo 4. 域名DNS解析是否正确指向服务器IP

echo.

:: 9. 生成诊断报告
echo ================================================
echo           诊断报告
echo ================================================
echo.

:: 总结问题
echo 📋 问题总结:
set "ISSUES=0"

tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if errorlevel 1 (
    echo ❌ nginx服务未运行
    set /a ISSUES+=1
)

netstat -an | findstr ":8443" >nul
if errorlevel 1 (
    echo ❌ 8443端口未监听
    set /a ISSUES+=1
)

netstat -an | findstr ":3002" >nul
if errorlevel 1 (
    echo ❌ API服务未运行
    set /a ISSUES+=1
)

if not exist "C:\certificates\practice.insightdata.top.pem" (
    echo ❌ SSL证书文件缺失
    set /a ISSUES+=1
)

if not exist "C:\admin\dist\index.html" (
    echo ❌ admin文件未部署
    set /a ISSUES+=1
)

netsh advfirewall firewall show rule name="8443" >nul 2>&1
if errorlevel 1 (
    echo ❌ 防火墙规则缺失
    set /a ISSUES+=1
)

echo.
echo 📊 发现 %ISSUES% 个问题

if %ISSUES% GTR 0 (
    echo.
    echo 🔧 建议解决方案:
    echo.
    if %ISSUES% GTR 0 (
        echo 1. 运行一键HTTPS部署脚本:
        echo    - 一键HTTPS部署8443.bat
        echo.
        echo 2. 或者分步解决:
        echo    - 更新nginx配置8443.bat
        echo    - 一键重新部署admin-稳定版.bat
        echo    - 快速启动8443.bat
        echo.
        echo 3. 添加防火墙规则:
        echo    netsh advfirewall firewall add rule name="8443" dir=in action=allow protocol=TCP localport=8443
        echo.
        echo 4. 检查云服务器安全组设置
        echo.
    )
) else (
    echo.
    echo ✅ 本地服务配置正常
    echo [提示] 如果外网仍无法访问，请检查:
    echo 1. 云服务器安全组设置
    echo 2. 域名DNS解析
    echo 3. 云服务器防火墙设置
)

echo.
echo ================================================
echo           诊断完成
echo ================================================
echo.

:: 提供快速修复选项
set /p fix="是否自动添加防火墙规则? (Y/N): "
if /i "%fix%"=="Y" (
    echo [信息] 正在添加防火墙规则...
    netsh advfirewall firewall add rule name="8443" dir=in action=allow protocol=TCP localport=8443
    if errorlevel 1 (
        echo [错误] 添加防火墙规则失败，请以管理员身份运行
    ) else (
        echo [✓] 防火墙规则添加成功
    )
)

echo.
echo 按任意键退出...
pause >nul
