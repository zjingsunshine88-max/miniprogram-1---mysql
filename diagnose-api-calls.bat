@echo off
chcp 65001 >nul
title 诊断API调用问题

echo 🔍 诊断API调用问题
echo.

echo 📋 问题描述:
echo - 点击"题库管理"时，API请求仍使用IP地址: 223.93.139.87:3002
echo - 期望使用HTTPS域名: https://practice.insightdata.top
echo.

echo ========================================
echo 1. 检查源代码配置
echo ========================================
echo.

echo 检查questionBank.js配置:
findstr /N "practice.insightdata.top" "admin\src\api\questionBank.js"
if errorlevel 1 (
    echo ❌ questionBank.js中未找到HTTPS域名
) else (
    echo ✅ questionBank.js已配置HTTPS域名
)

echo.
echo 检查环境变量文件:
findstr /N "VITE_SERVER_URL" "admin\env.production"
if errorlevel 1 (
    echo ❌ 环境变量文件未找到
) else (
    echo ✅ 环境变量文件存在
    type "admin\env.production"
)

echo.
echo ========================================
echo 2. 检查构建文件
echo ========================================
echo.

echo 检查构建文件中的API地址:
findstr /S /I "practice.insightdata.top" "admin\dist\*.js"
if errorlevel 1 (
    echo ❌ 构建文件中未找到HTTPS域名
) else (
    echo ✅ 构建文件中找到HTTPS域名
)

echo.
echo 检查构建文件中是否还有IP地址:
findstr /S /I "223.93.139.87" "admin\dist\*.js"
if errorlevel 1 (
    echo ✅ 构建文件中未找到IP地址
) else (
    echo ❌ 构建文件中仍存在IP地址
    echo 详细信息:
    findstr /S /I "223.93.139.87" "admin\dist\*.js"
)

echo.
echo ========================================
echo 3. 检查Nginx配置
echo ========================================
echo.

echo 检查Nginx配置文件:
if exist "C:\nginx\conf\practice.insightdata.top.conf" (
    echo ✅ Nginx配置文件存在
    echo 配置文件内容:
    type "C:\nginx\conf\practice.insightdata.top.conf"
) else (
    echo ❌ Nginx配置文件不存在
)

echo.
echo ========================================
echo 4. 检查服务状态
echo ========================================
echo.

echo 检查Nginx进程:
tasklist | findstr nginx.exe
if errorlevel 1 (
    echo ❌ Nginx未运行
) else (
    echo ✅ Nginx正在运行
)

echo.
echo 检查API服务:
netstat -ano | findstr :3002
if errorlevel 1 (
    echo ❌ API服务未运行
) else (
    echo ✅ API服务正在运行
)

echo.
echo ========================================
echo 5. 测试API访问
echo ========================================
echo.

echo 测试本地API访问:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3002/api/question-bank?page=1&limit=10' -Method Head -TimeoutSec 5; Write-Host '✅ 本地API可访问 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 本地API不可访问:' $_.Exception.Message }"

echo.
echo 测试HTTPS API访问:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/question-bank?page=1&limit=10' -Method Head -TimeoutSec 10; Write-Host '✅ HTTPS API可访问 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTPS API不可访问:' $_.Exception.Message }"

echo.
echo ========================================
echo 6. 可能的问题和解决方案
echo ========================================
echo.

echo 🎯 可能的问题:
echo 1. 浏览器缓存问题
echo 2. 构建文件未更新
echo 3. 环境变量未生效
echo 4. 服务未重启
echo 5. 配置文件问题
echo.

echo 🔧 解决方案:
echo 1. 运行: force-clean-rebuild-admin.bat
echo 2. 清除浏览器缓存 (Ctrl+Shift+Delete)
echo 3. 强制刷新页面 (Ctrl+F5)
echo 4. 检查网络请求是否使用HTTPS域名
echo 5. 确认所有服务都已重启
echo.

echo 💡 下一步操作:
echo 1. 如果构建文件有问题，运行强制重建
echo 2. 如果服务有问题，重启所有服务
echo 3. 如果浏览器有问题，清除缓存
echo.

pause
