@echo off
chcp 65001 >nul
title 一键重新部署Admin和API

echo ================================================
echo           一键重新部署Admin和API
echo ================================================
echo.

:: 检查是否在正确的目录
if not exist "admin\package.json" (
    echo [错误] 请在项目根目录运行此脚本
    echo [信息] 当前目录: %CD%
    pause
    exit /b 1
)

:: 进入admin目录并构建
echo [1/3] 构建Admin项目...
cd admin

:: 检查并安装依赖
if not exist "node_modules" (
    echo [信息] 安装依赖...
    call npm install
)

:: 构建项目
echo [信息] 构建项目...
call npm run build

:: 检查构建结果
if not exist "dist" (
    echo [错误] 构建失败
    cd ..
    pause
    exit /b 1
)

cd ..

:: 复制文件
echo [2/3] 复制文件...
if not exist "C:\admin" mkdir "C:\admin"
xcopy "admin\dist\*" "C:\admin\dist\" /E /Y /Q

:: 重启nginx
echo [3/3] 重启Nginx...
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul

if exist "C:\nginx\nginx.exe" (
    start "" "C:\nginx\nginx.exe"
) else (
    echo [警告] 未找到nginx.exe
)

echo.
echo ================================================
echo           部署完成！
echo ================================================
echo.
echo [信息] Admin管理后台: C:\admin\dist
echo [信息] 访问地址: https://practice.insightdata.top:8443
echo.

pause
