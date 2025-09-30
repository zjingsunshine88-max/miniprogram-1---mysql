@echo off
chcp 65001 >nul
title 检查Admin和API部署状态

echo ================================================
echo           检查Admin和API部署状态
echo ================================================
echo.

:: 1. 检查Admin文件部署状态
echo [1/6] 检查Admin文件部署状态...
if exist "C:\admin\dist\index.html" (
    echo [✓] Admin文件已部署到: C:\admin\dist
    echo [信息] 文件大小: 
    for %%A in ("C:\admin\dist\index.html") do echo [信息]   index.html: %%~zA bytes
    
    if exist "C:\admin\dist\assets" (
        echo [信息]  assets目录: 已存在
        for /f %%i in ('dir "C:\admin\dist\assets" /b 2^>nul ^| find /c /v ""') do echo [信息]   包含 %%i 个文件
    ) else (
        echo [警告] assets目录: 不存在
    )
) else (
    echo [错误] Admin文件未部署
    echo [信息] C:\admin\dist\index.html 不存在
)

:: 2. 检查本地构建文件
echo.
echo [2/6] 检查本地构建文件...
if exist "admin\dist\index.html" (
    echo [✓] 本地构建文件存在: admin\dist
    for %%A in ("admin\dist\index.html") do echo [信息]   index.html: %%~zA bytes
) else (
    echo [警告] 本地构建文件不存在
)

:: 3. 检查Node.js进程
echo.
echo [3/6] 检查Node.js进程...
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [✓] Node.js进程正在运行
    echo [信息] Node.js进程详情:
    tasklist /FI "IMAGENAME eq node.exe" /FO TABLE
) else (
    echo [错误] 未找到Node.js进程
)

:: 4. 检查Nginx进程
echo.
echo [4/6] 检查Nginx进程...
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [✓] Nginx进程正在运行
    echo [信息] Nginx进程详情:
    tasklist /FI "IMAGENAME eq nginx.exe" /FO TABLE
) else (
    echo [错误] 未找到Nginx进程
)

:: 5. 检查端口监听状态
echo.
echo [5/6] 检查端口监听状态...

:: 检查3002端口 (API)
netstat -an | findstr ":3002" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 3002端口正在监听 (API服务)
    echo [信息] 3002端口详情:
    netstat -an | findstr ":3002"
) else (
    echo [错误] 3002端口未监听 (API服务未启动)
)

:: 检查8443端口 (HTTPS)
netstat -an | findstr ":8443" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 8443端口正在监听 (HTTPS服务)
    echo [信息] 8443端口详情:
    netstat -an | findstr ":8443"
) else (
    echo [错误] 8443端口未监听 (HTTPS服务未启动)
)

:: 检查80端口 (HTTP)
netstat -an | findstr ":80 " >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 80端口正在监听 (HTTP服务)
) else (
    echo [信息] 80端口未监听
)

:: 检查443端口 (标准HTTPS)
netstat -an | findstr ":443 " >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 443端口正在监听 (标准HTTPS服务)
) else (
    echo [信息] 443端口未监听
)

:: 6. 测试服务连接
echo.
echo [6/6] 测试服务连接...

:: 测试本地API连接
echo [测试] 本地API连接...
curl -s -o nul -w "HTTP状态码: %%{http_code}" http://localhost:3002/api/health 2>nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 本地API连接正常
) else (
    echo [错误] 本地API连接失败
)

:: 测试本地Admin连接
echo [测试] 本地Admin连接...
curl -s -k -o nul -w "HTTP状态码: %%{http_code}" https://localhost:8443 2>nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 本地Admin连接正常
) else (
    echo [错误] 本地Admin连接失败
)

:: 测试外网Admin连接
echo [测试] 外网Admin连接...
curl -s -k -o nul -w "HTTP状态码: %%{http_code}" https://practice.insightdata.top:8443 2>nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 外网Admin连接正常
) else (
    echo [错误] 外网Admin连接失败
)

echo.
echo ================================================
echo           检查完成
echo ================================================
echo.

:: 总结部署状态
echo [总结] 部署状态:
if exist "C:\admin\dist\index.html" (
    echo [✓] Admin文件: 已部署
) else (
    echo [✗] Admin文件: 未部署
)

tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [✓] API服务: 运行中
) else (
    echo [✗] API服务: 未运行
)

tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [✓] Nginx服务: 运行中
) else (
    echo [✗] Nginx服务: 未运行
)

netstat -an | findstr ":8443" >nul
if "%ERRORLEVEL%"=="0" (
    echo [✓] 8443端口: 监听中
) else (
    echo [✗] 8443端口: 未监听
)

echo.
echo [访问地址]
echo [信息] Admin后台: https://practice.insightdata.top:8443
echo [信息] API接口: https://practice.insightdata.top:8443/api/
echo.

pause
