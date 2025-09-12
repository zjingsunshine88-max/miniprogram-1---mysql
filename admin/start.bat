@echo off
echo 刷题小程序后台管理系统启动脚本
echo ================================

echo 检查Node.js安装...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未检测到Node.js，请先安装Node.js
    echo 下载地址：https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js已安装，版本：
node --version

echo.
echo 安装依赖包...
npm install

if %errorlevel% neq 0 (
    echo 错误：依赖安装失败
    pause
    exit /b 1
)

echo.
echo 启动开发服务器...
npm run dev

pause 