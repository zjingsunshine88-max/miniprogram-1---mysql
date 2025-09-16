@echo off
chcp 65001 >nul
title 修复Terser问题

echo 🔧 修复Terser依赖问题...
echo.

REM 进入admin目录
cd /d "%~dp0admin"

echo 📋 当前状态检查...
echo 1. 检查Node.js版本...
node --version

echo 2. 检查npm版本...
npm --version

echo 3. 检查当前依赖...
if exist "package.json" (
    echo ✅ package.json 存在
) else (
    echo ❌ package.json 不存在
    pause
    exit /b 1
)

echo.
echo 🔧 开始修复...

echo 步骤1: 清理现有依赖...
if exist "node_modules" (
    echo 删除 node_modules...
    rmdir /s /q "node_modules"
)
if exist "package-lock.json" (
    echo 删除 package-lock.json...
    del "package-lock.json"
)

echo 步骤2: 安装terser依赖...
call npm install terser --save-dev
if errorlevel 1 (
    echo ❌ 使用默认源安装失败，尝试淘宝镜像...
    call npm install terser --save-dev --registry https://registry.npmmirror.com
    if errorlevel 1 (
        echo ❌ 淘宝镜像也失败，尝试全局安装...
        call npm install -g terser
    )
)

echo 步骤3: 验证terser安装...
call npx terser --version
if errorlevel 1 (
    echo ❌ Terser验证失败，尝试替代方案...
    goto use_esbuild
) else (
    echo ✅ Terser安装成功！
)

echo 步骤4: 测试构建...
call npm run build
if errorlevel 1 (
    echo ❌ 构建失败，使用esbuild替代...
    goto use_esbuild
) else (
    echo ✅ 构建成功！
    goto success
)

:use_esbuild
echo 🔄 使用esbuild替代方案...
REM 备份原配置
if exist "vite.config.js" copy "vite.config.js" "vite.config.js.backup"

REM 使用esbuild配置
if exist "vite.config.esbuild.js" (
    copy "vite.config.esbuild.js" "vite.config.js"
    echo ✅ 已切换到esbuild配置
) else (
    echo ❌ esbuild配置文件不存在
    pause
    exit /b 1
)

call npm run build
if errorlevel 1 (
    echo ❌ esbuild构建也失败
    REM 恢复原配置
    if exist "vite.config.js.backup" copy "vite.config.js.backup" "vite.config.js"
    pause
    exit /b 1
) else (
    echo ✅ esbuild构建成功！
    REM 恢复原配置
    if exist "vite.config.js.backup" copy "vite.config.js.backup" "vite.config.js"
)

:success
echo.
echo ✅ 问题修复完成！
echo.
echo 📁 构建文件位置: dist/
echo.
echo 💡 如果问题仍然存在，请尝试：
echo    1. 重新安装Node.js
echo    2. 清理npm缓存: npm cache clean --force
echo    3. 使用管理员权限运行此脚本
echo.
echo 按任意键退出...
pause >nul
