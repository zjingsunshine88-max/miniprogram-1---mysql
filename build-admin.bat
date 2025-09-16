@echo off
chcp 65001 >nul
title 构建后台管理系统

echo 🔨 构建后台管理系统...
echo.

REM 进入admin目录
cd /d "%~dp0admin"

echo 📦 安装依赖...
call npm install
if errorlevel 1 (
    echo ❌ 依赖安装失败，尝试使用淘宝镜像...
    call npm install --registry https://registry.npmmirror.com
    if errorlevel 1 (
        echo ❌ 使用镜像源安装也失败
        pause
        exit /b 1
    )
)

echo.
echo 🔍 检查terser是否可用...
call npx terser --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Terser不可用，尝试安装...
    call npm install terser --save-dev
    if errorlevel 1 (
        echo ❌ Terser安装失败，使用esbuild构建...
        goto build_with_esbuild
    )
)

echo ✅ Terser可用，使用terser构建...
call npm run build
if errorlevel 1 (
    echo ❌ Terser构建失败，尝试esbuild...
    goto build_with_esbuild
)

echo ✅ 构建成功！
goto end

:build_with_esbuild
echo 🔧 使用esbuild构建...
REM 备份原配置
if exist "vite.config.js" copy "vite.config.js" "vite.config.js.backup"
REM 使用esbuild配置
copy "vite.config.esbuild.js" "vite.config.js"

call npm run build
if errorlevel 1 (
    echo ❌ esbuild构建也失败
    REM 恢复原配置
    if exist "vite.config.js.backup" copy "vite.config.js.backup" "vite.config.js"
    pause
    exit /b 1
)

echo ✅ 使用esbuild构建成功！
REM 恢复原配置
if exist "vite.config.js.backup" copy "vite.config.js.backup" "vite.config.js"

:end
echo.
echo 📁 构建文件位置: dist/
echo.
echo 按任意键退出...
pause >nul
