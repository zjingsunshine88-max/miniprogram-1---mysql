@echo off
chcp 65001 >nul
title 停止所有服务（改进版）

echo 🛑 停止所有服务（改进版）...
echo.

echo 📋 服务说明:
echo - API服务: Node.js进程 (端口3002)
echo - Admin服务: 静态文件，通过Nginx提供
echo - Nginx服务: 提供HTTPS和静态文件服务
echo.

echo 🔍 步骤1: 检查并终止Node.js进程...
tasklist | findstr node.exe >nul
if not errorlevel 1 (
    echo 发现Node.js进程，正在终止...
    taskkill /IM node.exe /F >nul 2>&1
    if errorlevel 1 (
        echo ❌ Node.js进程终止失败
    ) else (
        echo ✅ Node.js进程已终止
    )
) else (
    echo ✅ 未发现Node.js进程
)

echo.
echo 🔍 步骤2: 检查并终止Nginx进程...
tasklist | findstr nginx.exe >nul
if not errorlevel 1 (
    echo 发现Nginx进程，正在终止...
    taskkill /IM nginx.exe /F >nul 2>&1
    if errorlevel 1 (
        echo ❌ Nginx进程终止失败
    ) else (
        echo ✅ Nginx进程已终止
    )
) else (
    echo ✅ 未发现Nginx进程
)

echo.
echo 🔍 步骤3: 检查端口占用情况...
echo.

echo 检查API服务端口3002:
netstat -ano | findstr :3002
if errorlevel 1 (
    echo ✅ 端口3002已释放
) else (
    echo ⚠️  端口3002仍被占用
    echo 尝试强制释放端口3002...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002') do (
        echo 终止占用端口3002的进程: %%a
        taskkill /PID %%a /F >nul 2>&1
    )
)

echo.
echo 检查HTTPS端口443:
netstat -ano | findstr :443
if errorlevel 1 (
    echo ✅ 端口443已释放
) else (
    echo ⚠️  端口443仍被占用
    echo 尝试强制释放端口443...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :443') do (
        echo 终止占用端口443的进程: %%a
        taskkill /PID %%a /F >nul 2>&1
    )
)

echo.
echo 检查HTTP端口80:
netstat -ano | findstr :80
if errorlevel 1 (
    echo ✅ 端口80已释放
) else (
    echo ⚠️  端口80仍被占用
    echo 尝试强制释放端口80...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :80') do (
        echo 终止占用端口80的进程: %%a
        taskkill /PID %%a /F >nul 2>&1
    )
)

echo.
echo 检查开发端口3000:
netstat -ano | findstr :3000
if errorlevel 1 (
    echo ✅ 端口3000已释放
) else (
    echo ⚠️  端口3000仍被占用
    echo 尝试强制释放端口3000...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do (
        echo 终止占用端口3000的进程: %%a
        taskkill /PID %%a /F >nul 2>&1
    )
)

echo.
echo 🔍 步骤4: 最终检查...
echo.

echo 检查所有相关进程:
tasklist | findstr node.exe
if errorlevel 1 (
    echo ✅ 无Node.js进程
) else (
    echo ❌ 仍有Node.js进程运行
)

tasklist | findstr nginx.exe
if errorlevel 1 (
    echo ✅ 无Nginx进程
) else (
    echo ❌ 仍有Nginx进程运行
)

echo.
echo 检查所有相关端口:
echo 端口3002 (API服务):
netstat -ano | findstr :3002
if errorlevel 1 (
    echo ✅ 端口3002已释放
) else (
    echo ❌ 端口3002仍被占用
)

echo 端口443 (HTTPS):
netstat -ano | findstr :443
if errorlevel 1 (
    echo ✅ 端口443已释放
) else (
    echo ❌ 端口443仍被占用
)

echo 端口80 (HTTP):
netstat -ano | findstr :80
if errorlevel 1 (
    echo ✅ 端口80已释放
) else (
    echo ❌ 端口80仍被占用
)

echo.
echo 🎉 服务停止完成！
echo.
echo 📋 停止结果:
echo - API服务: 已停止
echo - Admin服务: 已停止 (通过Nginx)
echo - Nginx服务: 已停止
echo - 所有端口: 已释放
echo.
echo 💡 说明:
echo 1. Admin服务是静态文件，通过Nginx提供
echo 2. 停止Nginx即停止Admin服务
echo 3. API服务是独立的Node.js进程
echo 4. 所有服务现在都已停止
echo.
pause
