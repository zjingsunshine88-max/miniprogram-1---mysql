@echo off
chcp 65001 >nul
title 强制更新Admin文件

echo 🔄 强制更新Admin文件
echo.

echo 📋 问题分析:
echo - 构建文件已更新，但Nginx目录中的文件未完全更新
echo - 存在新旧文件混合的情况
echo - 需要彻底清理并重新复制
echo.

echo 步骤1: 停止所有服务...
taskkill /IM nginx.exe /F >nul 2>&1
taskkill /IM node.exe /F >nul 2>&1
echo ✅ 服务已停止

echo.
echo 步骤2: 彻底清理Nginx目录...
if exist "C:\admin\dist" (
    rmdir /S /Q "C:\admin\dist"
    echo ✅ Nginx目录已删除
)

echo.
echo 步骤3: 重新创建目录...
mkdir "C:\admin\dist"
mkdir "C:\admin\dist\assets"
echo ✅ 目录已创建

echo.
echo 步骤4: 复制最新构建文件...
xcopy /E /Y "D:\code\miniprogram-1---mysql\admin\dist\*" "C:\admin\dist\"
echo ✅ 文件复制完成

echo.
echo 步骤5: 验证文件更新...
echo 检查文件时间戳:
Get-ChildItem "C:\admin\dist\assets" | Sort-Object LastWriteTime -Descending | Select-Object -First 3

echo.
echo 检查HTTPS域名配置:
findstr /S /I "practice.insightdata.top" "C:\admin\dist\assets\*.js"
if errorlevel 1 (
    echo ❌ 未找到HTTPS域名配置
) else (
    echo ✅ 找到HTTPS域名配置
)

echo.
echo 检查是否还有IP地址:
findstr /S /I "223.93.139.87" "C:\admin\dist\assets\*.js"
if errorlevel 1 (
    echo ✅ 未找到IP地址
) else (
    echo ❌ 仍存在IP地址
    echo 详细信息:
    findstr /S /I "223.93.139.87" "C:\admin\dist\assets\*.js"
)

echo.
echo 步骤6: 重启服务...
cd /d C:\nginx
start nginx.exe
echo ✅ Nginx已启动

cd /d "D:\code\miniprogram-1---mysql\server"
set NODE_ENV=production
set DB_PASSWORD=LOVEjing96..
start "API Server" cmd /k "npm run start:prod"
echo ✅ API服务已启动

echo.
echo 🎉 强制更新完成！
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
