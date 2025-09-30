@echo off
chcp 65001 >nul
title 强制重新构建Admin项目

echo 🔨 强制重新构建Admin项目
echo.

echo 📋 构建信息:
echo - 项目: 刷题小程序后台管理系统
echo - 环境: 生产环境
echo - API地址: https://practice.insightdata.top
echo.

echo 🔄 开始强制重新构建...
echo.

echo 步骤1: 进入admin目录...
cd /d "%~dp0admin"

echo 步骤2: 清理所有构建文件...
if exist "dist" (
    echo 删除旧的构建文件...
    rmdir /s /q dist
    echo ✅ 旧构建文件已删除
)

if exist "node_modules\.vite" (
    echo 清理Vite缓存...
    rmdir /s /q node_modules\.vite
    echo ✅ Vite缓存已清理
)

echo.
echo 步骤3: 检查环境变量配置...
if exist "env.production" (
    echo ✅ 生产环境配置文件存在
    echo 当前配置:
    type env.production
) else (
    echo ❌ 生产环境配置文件不存在
    echo 创建生产环境配置文件...
    echo # 生产环境配置 > env.production
    echo VITE_SERVER_URL=https://practice.insightdata.top >> env.production
    echo VITE_APP_TITLE=刷题小程序后台管理系统 >> env.production
    echo VITE_APP_VERSION=1.0.0 >> env.production
    echo ✅ 生产环境配置文件已创建
)

echo.
echo 步骤4: 设置环境变量...
set VITE_SERVER_URL=https://practice.insightdata.top
set VITE_APP_TITLE=刷题小程序后台管理系统
set VITE_APP_VERSION=1.0.0

echo 环境变量已设置:
echo VITE_SERVER_URL=https://practice.insightdata.top
echo VITE_APP_TITLE=刷题小程序后台管理系统
echo VITE_APP_VERSION=1.0.0

echo.
echo 步骤5: 安装依赖（如果需要）...
if not exist "node_modules" (
    echo 安装依赖包...
    npm install
    if errorlevel 1 (
        echo ❌ 依赖安装失败
        pause
        exit /b 1
    ) else (
        echo ✅ 依赖安装成功
    )
) else (
    echo ✅ 依赖包已存在
)

echo.
echo 步骤6: 强制重新构建项目...
echo 使用生产环境配置构建...
npm run build

if errorlevel 1 (
    echo ❌ 构建失败
    echo 显示错误信息:
    npm run build
    pause
    exit /b 1
) else (
    echo ✅ 构建成功
)

echo.
echo 步骤7: 检查构建结果...
if exist "dist" (
    echo ✅ 构建目录存在
    echo 构建文件列表:
    dir dist
) else (
    echo ❌ 构建目录不存在
    pause
    exit /b 1
)

echo.
echo 步骤8: 验证API地址配置...
echo 检查构建文件中的API地址...
findstr /S /I "practice.insightdata.top" dist\*.js
if errorlevel 1 (
    echo ⚠️  未找到HTTPS域名配置，检查环境变量
    echo 检查环境变量配置:
    echo VITE_SERVER_URL=%VITE_SERVER_URL%
) else (
    echo ✅ 找到HTTPS域名配置
)

echo.
echo 步骤9: 复制构建文件到Nginx目录...
if not exist "C:\admin\dist" mkdir C:\admin\dist
echo 复制构建文件...
xcopy /E /Y "dist\*" "C:\admin\dist\"

if errorlevel 1 (
    echo ❌ 文件复制失败
    pause
    exit /b 1
) else (
    echo ✅ 构建文件复制成功
)

echo.
echo 步骤10: 重启Nginx服务...
cd /d C:\nginx
nginx -s reload
if errorlevel 1 (
    echo 停止Nginx...
    taskkill /F /IM nginx.exe >nul 2>&1
    timeout /t 2 >nul
    echo 启动Nginx...
    start nginx.exe
    timeout /t 3 >nul
) else (
    echo ✅ Nginx重新加载成功
)

echo.
echo 🎉 Admin项目强制重新构建完成！
echo.
echo 📋 构建结果:
echo - 构建目录: admin/dist
echo - 部署目录: C:\admin\dist
echo - API地址: https://practice.insightdata.top
echo.
echo 📋 访问地址:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
echo 💡 测试步骤:
echo 1. 访问管理后台: https://practice.insightdata.top/
echo 2. 登录系统
echo 3. 点击"题库管理"
echo 4. 点击"智能上传"
echo 5. 检查网络请求是否使用HTTPS域名
echo.
echo 🔍 如果仍然使用IP地址，请检查:
echo 1. 浏览器缓存 - 清除缓存后重试
echo 2. 环境变量 - 确保VITE_SERVER_URL正确设置
echo 3. 构建文件 - 确保使用最新的构建文件
echo.
pause
