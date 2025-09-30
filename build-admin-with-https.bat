@echo off
chcp 65001 >nul
title 构建Admin项目（HTTPS版本）

echo 🔨 构建Admin项目（HTTPS版本）
echo.

echo 📋 构建信息:
echo - 项目: 刷题小程序后台管理系统
echo - 环境: 生产环境
echo - API地址: https://practice.insightdata.top
echo.

echo 🔄 开始构建...
echo.

echo 步骤1: 进入admin目录...
cd /d "%~dp0admin"

echo 步骤2: 检查环境变量配置...
if exist "env.production" (
    echo ✅ 生产环境配置文件存在
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
echo 步骤3: 安装依赖（如果需要）...
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
echo 步骤4: 清理旧的构建文件...
if exist "dist" (
    echo 删除旧的构建文件...
    rmdir /s /q dist
    echo ✅ 旧构建文件已删除
)

echo.
echo 步骤5: 构建项目...
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
echo 步骤6: 检查构建结果...
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
echo 步骤7: 复制构建文件到Nginx目录...
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
echo 步骤8: 验证API地址配置...
echo 检查构建文件中的API地址...
findstr /S /I "practice.insightdata.top" dist\*.js
if errorlevel 1 (
    echo ⚠️  未找到HTTPS域名配置，可能使用环境变量
) else (
    echo ✅ 找到HTTPS域名配置
)

echo.
echo 🎉 Admin项目构建完成！
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
echo 💡 注意事项:
echo 1. 确保HTTPS服务正常运行
echo 2. 确保SSL证书有效
echo 3. 确保域名解析正确
echo 4. 如果无法访问，检查防火墙和端口配置
echo.
echo 🔄 下一步操作:
echo 1. 重启Nginx服务
echo 2. 测试管理后台访问
echo 3. 验证API调用是否正常
echo.
pause
