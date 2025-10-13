@echo off
chcp 65001 >nul
title 检查和修复Nginx端口

echo 🔍 检查和修复Nginx端口
echo ========================================
echo.

echo 步骤1: 检查443端口占用...
echo.
netstat -ano | findstr :443
echo.

echo 步骤2: 查找可用端口...
echo.
set AVAILABLE_PORT=

echo 🔍 检查端口8443:
netstat -ano | findstr :8443 >nul
if errorlevel 1 (
    echo ✅ 端口8443可用
    set AVAILABLE_PORT=8443
    goto :port_found
)

echo 🔍 检查端口9443:
netstat -ano | findstr :9443 >nul
if errorlevel 1 (
    echo ✅ 端口9443可用
    set AVAILABLE_PORT=9443
    goto :port_found
)

echo 🔍 检查端口10443:
netstat -ano | findstr :10443 >nul
if errorlevel 1 (
    echo ✅ 端口10443可用
    set AVAILABLE_PORT=10443
    goto :port_found
)

echo 🔍 检查端口3003:
netstat -ano | findstr :3003 >nul
if errorlevel 1 (
    echo ✅ 端口3003可用
    set AVAILABLE_PORT=3003
    goto :port_found
)

echo 🔍 检查端口4003:
netstat -ano | findstr :4003 >nul
if errorlevel 1 (
    echo ✅ 端口4003可用
    set AVAILABLE_PORT=4003
    goto :port_found
)

echo ❌ 所有常用端口都被占用，请手动选择端口
goto :manual_port

:port_found
echo.
echo ✅ 找到可用端口: %AVAILABLE_PORT%
echo.

echo 📝 推荐配置:
echo ========================================
echo.
echo 1. Nginx配置:
echo    listen %AVAILABLE_PORT% ssl;
echo.
echo 2. 小程序配置:
echo    BASE_URL: 'https://practice.insightdata.top:%AVAILABLE_PORT%'
echo.
echo 3. 访问地址:
echo    https://practice.insightdata.top:%AVAILABLE_PORT%/
echo.

echo 🔧 是否要自动更新配置文件? (Y/N)
set /p choice=
if /i "%choice%"=="Y" (
    call :update_configs
) else (
    echo 请手动更新配置文件
)

echo.
echo 💡 端口选择建议:
echo.
echo 8443 - 最常用的HTTPS替代端口
echo 9443 - 另一个常用的HTTPS端口  
echo 10443 - 较少冲突的端口
echo 3003 - 与API端口3002相近
echo 4003 - 自定义端口
echo.
echo 避免使用:
echo 80 - HTTP端口
echo 443 - 标准HTTPS端口（已被占用）
echo 3002 - API服务端口
echo.

goto :eof

:manual_port
echo.
echo 🔧 手动端口配置:
echo.
echo 请选择要使用的端口 (建议8443-9443之间):
set /p MANUAL_PORT=
echo.
echo 您选择的端口: %MANUAL_PORT%
echo.
echo 配置信息:
echo Nginx: listen %MANUAL_PORT% ssl;
echo 小程序: BASE_URL: 'https://practice.insightdata.top:%MANUAL_PORT%'
echo.
goto :eof

:update_configs
echo.
echo 🔧 正在更新配置文件...
echo.

echo 1. 更新Nginx配置...
if exist "nginx-https.conf" (
    copy "nginx-https.conf" "nginx-https.conf.backup"
    powershell -Command "(Get-Content 'nginx-https.conf') -replace 'listen 443 ssl', 'listen %AVAILABLE_PORT% ssl' | Set-Content 'nginx-https.conf'"
    echo ✅ Nginx配置已更新
) else (
    echo ❌ nginx-https.conf文件不存在
)

echo.
echo 2. 更新小程序配置...
if exist "miniprogram/config/production.js" (
    copy "miniprogram/config/production.js" "miniprogram/config/production.js.backup"
    powershell -Command "(Get-Content 'miniprogram/config/production.js') -replace 'https://practice.insightdata.top', 'https://practice.insightdata.top:%AVAILABLE_PORT%' | Set-Content 'miniprogram/config/production.js'"
    echo ✅ 小程序配置已更新
) else (
    echo ❌ miniprogram/config/production.js文件不存在
)

echo.
echo 3. 更新管理后台配置...
if exist "admin/env.production" (
    copy "admin/env.production" "admin/env.production.backup"
    powershell -Command "(Get-Content 'admin/env.production') -replace 'https://practice.insightdata.top', 'https://practice.insightdata.top:%AVAILABLE_PORT%' | Set-Content 'admin/env.production'"
    echo ✅ 管理后台配置已更新
) else (
    echo ❌ admin/env.production文件不存在
)

echo.
echo ✅ 配置文件更新完成！
echo.
echo 📝 更新内容:
echo - Nginx监听端口: %AVAILABLE_PORT%
echo - 小程序API地址: https://practice.insightdata.top:%AVAILABLE_PORT%
echo - 管理后台地址: https://practice.insightdata.top:%AVAILABLE_PORT%
echo.
echo 🔄 下一步:
echo 1. 重启Nginx服务
echo 2. 重新构建管理后台
echo 3. 测试新端口访问
echo.
goto :eof
