@echo off
chcp 65001 >nul
title 检查Admin API调用配置

echo 🔍 检查Admin API调用配置
echo.

echo 📋 检查项目:
echo 1. 源代码API调用地址
echo 2. 环境变量配置
echo 3. 构建文件API调用地址
echo 4. 浏览器缓存问题
echo.

echo ========================================
echo 1. 检查源代码API调用地址
echo ========================================
echo.

echo 检查API文件中的调用地址...
echo.
echo 检查 activationCode.js:
findstr /N "practice.insightdata.top" admin\src\api\activationCode.js
if errorlevel 1 (
    echo ❌ 未找到HTTPS域名配置
) else (
    echo ✅ 找到HTTPS域名配置
)

echo.
echo 检查 questionBank.js:
findstr /N "practice.insightdata.top" admin\src\api\questionBank.js
if errorlevel 1 (
    echo ❌ 未找到HTTPS域名配置
) else (
    echo ✅ 找到HTTPS域名配置
)

echo.
echo 检查 subject.js:
findstr /N "practice.insightdata.top" admin\src\api\subject.js
if errorlevel 1 (
    echo ❌ 未找到HTTPS域名配置
) else (
    echo ✅ 找到HTTPS域名配置
)

echo.
echo 检查是否有旧的IP地址:
findstr /N "223.93.139.87" admin\src\api\*.js
if errorlevel 1 (
    echo ✅ 未找到旧IP地址
) else (
    echo ❌ 找到旧IP地址，需要清理
)

echo.
echo ========================================
echo 2. 检查环境变量配置
echo ========================================
echo.

echo 检查生产环境配置:
if exist "admin\env.production" (
    echo ✅ 生产环境配置文件存在
    echo 配置内容:
    type admin\env.production
) else (
    echo ❌ 生产环境配置文件不存在
)

echo.
echo 检查当前环境变量:
echo VITE_SERVER_URL=%VITE_SERVER_URL%
if "%VITE_SERVER_URL%"=="" (
    echo ⚠️  环境变量未设置
) else (
    echo ✅ 环境变量已设置: %VITE_SERVER_URL%
)

echo.
echo ========================================
echo 3. 检查构建文件API调用地址
echo ========================================
echo.

echo 检查构建文件中的API调用地址...
if exist "admin\dist" (
    echo ✅ 构建目录存在
    echo 检查构建文件中的API地址:
    findstr /S /I "practice.insightdata.top" admin\dist\*.js
    if errorlevel 1 (
        echo ❌ 构建文件中未找到HTTPS域名配置
    ) else (
        echo ✅ 构建文件中找到HTTPS域名配置
    )
    
    echo.
    echo 检查构建文件中是否有旧IP地址:
    findstr /S /I "223.93.139.87" admin\dist\*.js
    if errorlevel 1 (
        echo ✅ 构建文件中未找到旧IP地址
    ) else (
        echo ❌ 构建文件中找到旧IP地址，需要重新构建
    )
) else (
    echo ❌ 构建目录不存在，需要构建项目
)

echo.
echo ========================================
echo 4. 检查部署文件
echo ========================================
echo.

echo 检查Nginx部署目录:
if exist "C:\admin\dist" (
    echo ✅ Nginx部署目录存在
    echo 检查部署文件中的API地址:
    findstr /S /I "practice.insightdata.top" C:\admin\dist\*.js
    if errorlevel 1 (
        echo ❌ 部署文件中未找到HTTPS域名配置
    ) else (
        echo ✅ 部署文件中找到HTTPS域名配置
    )
    
    echo.
    echo 检查部署文件中是否有旧IP地址:
    findstr /S /I "223.93.139.87" C:\admin\dist\*.js
    if errorlevel 1 (
        echo ✅ 部署文件中未找到旧IP地址
    ) else (
        echo ❌ 部署文件中找到旧IP地址，需要重新部署
    )
) else (
    echo ❌ Nginx部署目录不存在
)

echo.
echo ========================================
echo 5. 解决方案建议
echo ========================================
echo.

echo 💡 如果仍然使用IP地址，可能的原因:
echo 1. 浏览器缓存 - 清除浏览器缓存
echo 2. 构建文件未更新 - 需要重新构建
echo 3. 环境变量未生效 - 需要重新设置
echo 4. 部署文件未更新 - 需要重新部署
echo.

echo 🔧 推荐解决步骤:
echo.
echo 步骤1: 清除浏览器缓存
echo - 按 Ctrl+Shift+Delete
echo - 选择"清除缓存和Cookie"
echo - 重新访问网站
echo.
echo 步骤2: 强制重新构建
echo - 运行: force-rebuild-admin.bat
echo - 确保使用最新的构建文件
echo.
echo 步骤3: 检查环境变量
echo - 确保 VITE_SERVER_URL=https://practice.insightdata.top
echo - 重新构建项目
echo.
echo 步骤4: 验证部署
echo - 检查 C:\admin\dist 目录
echo - 确保使用最新的构建文件
echo - 重启Nginx服务
echo.

echo ========================================
echo 检查完成
echo ========================================
echo.
echo 💡 下一步操作建议:
echo 1. 如果发现旧IP地址，运行: force-rebuild-admin.bat
echo 2. 清除浏览器缓存后重新测试
echo 3. 检查网络请求是否使用HTTPS域名
echo.
pause
