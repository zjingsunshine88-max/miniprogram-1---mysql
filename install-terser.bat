@echo off
chcp 65001 >nul
title 安装Terser依赖

echo 🔧 安装Terser依赖...
echo.

REM 检查Node.js是否安装
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Node.js，请先安装Node.js
    pause
    exit /b 1
)

echo 📦 安装Terser依赖...

REM 进入admin目录
cd /d "%~dp0admin"

echo 1. 全局安装terser...
call npm install -g terser
if errorlevel 1 (
    echo ❌ 全局安装terser失败，尝试使用淘宝镜像...
    call npm install -g terser --registry https://registry.npmmirror.com
)

echo 2. 本地安装terser到admin项目...
call npm install terser --save-dev
if errorlevel 1 (
    echo ❌ 本地安装terser失败，尝试使用淘宝镜像...
    call npm install terser --save-dev --registry https://registry.npmmirror.com
)

echo 3. 验证terser安装...
call npx terser --version
if errorlevel 1 (
    echo ❌ Terser安装验证失败
    echo 💡 尝试手动验证...
    node -e "console.log(require('terser/package.json').version)"
)

echo.
echo ✅ Terser依赖安装完成！
echo.

REM 测试构建
echo 🧪 测试构建...
call npm run build
if errorlevel 1 (
    echo ❌ 构建测试失败
    echo 💡 建议使用esbuild压缩器
    echo 修改 vite.config.js 中的 minify: 'terser' 为 minify: 'esbuild'
) else (
    echo ✅ 构建测试成功！
)

echo.
echo 按任意键退出...
pause >nul
