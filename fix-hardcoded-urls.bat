@echo off
chcp 65001 >nul
title 修复硬编码URL问题

echo 🔧 修复硬编码URL问题
echo.

echo 📋 问题分析:
echo - 源代码中硬编码了HTTPS域名
echo - 但构建后的文件却包含IP地址
echo - 可能是构建过程中的替换问题
echo.

echo 步骤1: 停止所有服务...
taskkill /IM nginx.exe /F >nul 2>&1
taskkill /IM node.exe /F >nul 2>&1
echo ✅ 服务已停止

echo.
echo 步骤2: 检查源代码中的硬编码URL...
cd /d "%~dp0\admin\src\api"

echo 检查questionBank.js:
findstr /N "practice.insightdata.top" questionBank.js
if errorlevel 1 (
    echo ❌ questionBank.js中未找到HTTPS域名
) else (
    echo ✅ questionBank.js中找到HTTPS域名
)

echo 检查activationCode.js:
findstr /N "practice.insightdata.top" activationCode.js
if errorlevel 1 (
    echo ❌ activationCode.js中未找到HTTPS域名
) else (
    echo ✅ activationCode.js中找到HTTPS域名
)

echo 检查subject.js:
findstr /N "practice.insightdata.top" subject.js
if errorlevel 1 (
    echo ❌ subject.js中未找到HTTPS域名
) else (
    echo ✅ subject.js中找到HTTPS域名
)

echo.
echo 步骤3: 检查是否有IP地址硬编码...
findstr /N "223.93.139.87" *.js
if errorlevel 1 (
    echo ✅ 源代码中未找到IP地址
) else (
    echo ❌ 源代码中找到IP地址
    echo 详细信息:
    findstr /N "223.93.139.87" *.js
)

echo.
echo 步骤4: 清理构建缓存...
cd /d "%~dp0\admin"

echo 清理dist目录...
if exist "dist" (
    rmdir /S /Q "dist"
    echo ✅ dist目录已删除
)

echo 清理node_modules缓存...
if exist "node_modules" (
    rmdir /S /Q "node_modules"
    echo ✅ node_modules已删除
)

echo 清理package-lock.json...
if exist "package-lock.json" (
    del "package-lock.json"
    echo ✅ package-lock.json已删除
)

echo.
echo 步骤5: 重新安装依赖...
npm install
if errorlevel 1 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)
echo ✅ 依赖安装完成

echo.
echo 步骤6: 设置环境变量并构建...
echo 设置环境变量:
set VITE_SERVER_URL=https://practice.insightdata.top
set VITE_APP_TITLE=刷题小程序后台管理系统
set VITE_APP_VERSION=1.0.0

echo 环境变量设置:
echo VITE_SERVER_URL=https://practice.insightdata.top
echo VITE_APP_TITLE=刷题小程序后台管理系统
echo VITE_APP_VERSION=1.0.0

echo.
echo 开始构建...
npm run build
if errorlevel 1 (
    echo ❌ 构建失败
    pause
    exit /b 1
)
echo ✅ 构建完成

echo.
echo 步骤7: 验证构建文件...
echo 检查构建文件中的API地址...
findstr /S /I "practice.insightdata.top" dist\*.js
if errorlevel 1 (
    echo ❌ 构建文件中未找到HTTPS域名
) else (
    echo ✅ 构建文件中找到HTTPS域名配置
)

echo 检查是否还有IP地址...
findstr /S /I "223.93.139.87" dist\*.js
if errorlevel 1 (
    echo ✅ 构建文件中未找到IP地址
) else (
    echo ❌ 构建文件中仍存在IP地址
    echo 详细信息:
    findstr /S /I "223.93.139.87" dist\*.js
)

echo.
echo 步骤8: 复制到Nginx目录...
if not exist "C:\admin\dist" mkdir C:\admin\dist
xcopy /E /Y "dist\*" "C:\admin\dist\"
echo ✅ 文件复制完成

echo.
echo 步骤9: 重启服务...
cd /d C:\nginx
start nginx.exe
echo ✅ Nginx已启动

cd /d "%~dp0\server"
set NODE_ENV=production
set DB_PASSWORD=LOVEjing96..
start "API Server" cmd /k "npm run start:prod"
echo ✅ API服务已启动

echo.
echo 🎉 修复完成！
echo.
echo 📋 验证步骤:
echo 1. 访问: https://practice.insightdata.top/
echo 2. 清除浏览器缓存 (Ctrl+Shift+Delete)
echo 3. 强制刷新页面 (Ctrl+F5)
echo 4. 检查网络请求是否使用HTTPS域名
echo.
echo 💡 如果仍有问题:
echo 1. 检查浏览器开发者工具网络请求
echo 2. 确认请求URL是否使用HTTPS域名
echo 3. 检查是否有其他缓存问题
echo.
pause
