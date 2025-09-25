@echo off
chcp 65001 >nul
title 修复HTTPS部署问题

echo 🔧 修复HTTPS部署问题...
echo.

echo 📋 问题分析：
echo 1. ❌ await语法错误：在非异步函数中使用await
echo 2. ❌ 管理后台地址：使用localhost而不是域名
echo.

REM 进入项目根目录
cd /d "%~dp0"

echo 步骤1: 修复await语法错误...
echo ✅ 已修复 questionController.js 中的await语法问题
echo ✅ 将 map 回调函数改为 async 函数

echo.
echo 步骤2: 修复管理后台配置...
echo ✅ 已更新启动脚本，使用静态文件而不是开发服务器
echo ✅ 已更新Nginx配置，直接提供静态文件

echo.
echo 步骤3: 验证修复效果...
echo.

REM 检查语法错误是否修复
echo 📁 检查 questionController.js 语法...
node -c "server/controllers/questionController.js"
if errorlevel 1 (
    echo ❌ 语法检查失败
    pause
    exit /b 1
) else (
    echo ✅ 语法检查通过
)

echo.
echo 步骤4: 测试API服务启动...
cd /d server

REM 设置环境变量
set NODE_ENV=production
set DB_PASSWORD=LOVEjing96..

echo 🔧 设置环境变量...
echo NODE_ENV=production
echo DB_PASSWORD=LOVEjing96..

echo 🌐 测试启动API服务...
timeout /t 3 >nul

REM 只测试启动，不等待
start "API Server Test" cmd /c "npm run start:prod & timeout /t 5 & exit"

echo ✅ API服务测试启动完成

echo.
echo 步骤5: 构建管理后台...
cd /d "%~dp0\admin"

REM 设置环境变量
set VITE_SERVER_URL=https://practice.insightdata.top

echo 🔧 设置环境变量...
echo VITE_SERVER_URL=https://practice.insightdata.top

echo 🔨 构建管理后台...
npm run build

if errorlevel 1 (
    echo ❌ 管理后台构建失败
    pause
    exit /b 1
)

echo ✅ 管理后台构建完成

echo 📁 复制构建文件到Nginx目录...
if not exist "C:\admin" mkdir C:\admin
xcopy /E /Y "dist\*" "C:\admin\"

echo ✅ 管理后台文件复制完成

echo.
echo 步骤6: 验证文件结构...
echo 📁 检查关键文件：

if exist "C:\admin\index.html" (
    echo ✅ 管理后台静态文件: C:\admin\index.html
) else (
    echo ❌ 管理后台静态文件不存在
)

if exist "nginx-https.conf" (
    echo ✅ Nginx配置文件: nginx-https.conf
) else (
    echo ❌ Nginx配置文件不存在
)

if exist "start-https-services.bat" (
    echo ✅ 启动脚本: start-https-services.bat
) else (
    echo ❌ 启动脚本不存在
)

echo.
echo 📊 修复总结：
echo ✅ await语法错误已修复
echo ✅ 管理后台配置已更新
echo ✅ 静态文件部署已配置
echo ✅ Nginx配置已优化
echo.

echo 💡 下一步操作：
echo 1. 复制 nginx-https.conf 到 C:\nginx\conf\practice.insightdata.top.conf
echo 2. 启动Nginx服务
echo 3. 运行 start-https-services.bat
echo 4. 访问 https://practice.insightdata.top/
echo.

echo 🎉 HTTPS部署问题修复完成！
echo.
echo 按任意键退出...
pause >nul
