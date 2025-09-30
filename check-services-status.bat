@echo off
chcp 65001 >nul
title 检查服务状态

echo 🔍 检查服务状态
echo.

echo 📋 服务架构说明:
echo - API服务: Node.js进程，端口3002
echo - Admin服务: 静态文件，通过Nginx提供
echo - Nginx服务: 提供HTTPS和静态文件服务
echo.

echo ========================================
echo 1. 检查进程状态
echo ========================================
echo.

echo 检查Node.js进程:
tasklist | findstr node.exe
if errorlevel 1 (
    echo ❌ 无Node.js进程 (API服务未运行)
) else (
    echo ✅ 发现Node.js进程 (API服务正在运行)
)

echo.
echo 检查Nginx进程:
tasklist | findstr nginx.exe
if errorlevel 1 (
    echo ❌ 无Nginx进程 (Admin服务未运行)
) else (
    echo ✅ 发现Nginx进程 (Admin服务正在运行)
)

echo.
echo ========================================
echo 2. 检查端口状态
echo ========================================
echo.

echo 检查API服务端口3002:
netstat -ano | findstr :3002
if errorlevel 1 (
    echo ❌ 端口3002未监听 (API服务未运行)
) else (
    echo ✅ 端口3002正在监听 (API服务正在运行)
)

echo.
echo 检查HTTPS端口443:
netstat -ano | findstr :443
if errorlevel 1 (
    echo ❌ 端口443未监听 (HTTPS服务未运行)
) else (
    echo ✅ 端口443正在监听 (HTTPS服务正在运行)
)

echo.
echo 检查HTTP端口80:
netstat -ano | findstr :80
if errorlevel 1 (
    echo ❌ 端口80未监听 (HTTP重定向未运行)
) else (
    echo ✅ 端口80正在监听 (HTTP重定向正在运行)
)

echo.
echo 检查开发端口3000:
netstat -ano | findstr :3000
if errorlevel 1 (
    echo ❌ 端口3000未监听 (开发服务未运行)
) else (
    echo ✅ 端口3000正在监听 (开发服务正在运行)
)

echo.
echo ========================================
echo 3. 检查服务访问
echo ========================================
echo.

echo 测试API服务访问:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3002/api/' -Method Head -TimeoutSec 5; Write-Host '✅ API服务可访问 - 状态码:' $response.StatusCode } catch { Write-Host '❌ API服务不可访问:' $_.Exception.Message }"

echo.
echo 测试HTTPS服务访问:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ HTTPS服务可访问 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTPS服务不可访问:' $_.Exception.Message }"

echo.
echo 测试Admin服务访问:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/' -Method Head -TimeoutSec 10; Write-Host '✅ Admin服务可访问 - 状态码:' $response.StatusCode } catch { Write-Host '❌ Admin服务不可访问:' $_.Exception.Message }"

echo.
echo ========================================
echo 4. 服务状态总结
echo ========================================
echo.

echo 📋 服务状态总结:
echo.

REM 检查API服务
netstat -ano | findstr :3002 >nul
if errorlevel 1 (
    echo ❌ API服务: 未运行
) else (
    echo ✅ API服务: 正在运行
)

REM 检查Nginx服务
tasklist | findstr nginx.exe >nul
if errorlevel 1 (
    echo ❌ Admin服务: 未运行 (Nginx未运行)
) else (
    echo ✅ Admin服务: 正在运行 (Nginx正在运行)
)

REM 检查HTTPS服务
netstat -ano | findstr :443 >nul
if errorlevel 1 (
    echo ❌ HTTPS服务: 未运行
) else (
    echo ✅ HTTPS服务: 正在运行
)

echo.
echo 💡 服务说明:
echo 1. API服务: 独立的Node.js进程
echo 2. Admin服务: 静态文件，通过Nginx提供
echo 3. 停止Nginx即停止Admin服务
echo 4. 所有服务都通过HTTPS访问
echo.
echo 🔧 如果服务未运行:
echo 1. 运行: start-https-services-updated.bat
echo 2. 检查SSL证书是否存在
echo 3. 检查防火墙设置
echo 4. 检查域名解析
echo.
pause
