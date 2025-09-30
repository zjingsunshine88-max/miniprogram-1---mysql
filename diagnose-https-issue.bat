@echo off
chcp 65001 >nul
title HTTPS服务诊断工具

echo 🔍 HTTPS服务诊断工具
echo.

echo 📋 诊断项目:
echo 1. SSL证书文件检查
echo 2. Nginx服务状态
echo 3. API服务状态
echo 4. 网络连接测试
echo 5. 配置文件检查
echo.

echo ========================================
echo 1. SSL证书文件检查
echo ========================================
if exist "C:\certificates\practice.insightdata.top.pem" (
    echo ✅ SSL证书文件存在: C:\certificates\practice.insightdata.top.pem
) else (
    echo ❌ SSL证书文件不存在: C:\certificates\practice.insightdata.top.pem
)

if exist "C:\certificates\practice.insightdata.top.key" (
    echo ✅ SSL私钥文件存在: C:\certificates\practice.insightdata.top.key
) else (
    echo ❌ SSL私钥文件不存在: C:\certificates\practice.insightdata.top.key
)

echo.
echo ========================================
echo 2. Nginx服务状态
echo ========================================
tasklist | findstr nginx.exe >nul
if errorlevel 1 (
    echo ❌ Nginx未运行
) else (
    echo ✅ Nginx正在运行
    tasklist | findstr nginx.exe
)

echo.
echo 检查443端口监听状态...
netstat -an | findstr :443 | findstr LISTENING
if errorlevel 1 (
    echo ❌ 443端口未监听
) else (
    echo ✅ 443端口正在监听
)

echo.
echo ========================================
echo 3. API服务状态
echo ========================================
netstat -an | findstr :3002 | findstr LISTENING
if errorlevel 1 (
    echo ❌ API服务端口3002未监听
) else (
    echo ✅ API服务端口3002正在监听
)

echo.
echo 测试本地API服务...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3002/api/' -Method Head -TimeoutSec 5; Write-Host '✅ 本地API服务正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 本地API服务异常:' $_.Exception.Message }"

echo.
echo ========================================
echo 4. 网络连接测试
echo ========================================
echo 测试HTTPS连接...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ HTTPS连接正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTPS连接失败:' $_.Exception.Message }"

echo.
echo 测试域名解析...
nslookup practice.insightdata.top
echo.

echo ========================================
echo 5. 配置文件检查
echo ========================================
if exist "C:\nginx\conf\practice.insightdata.top.conf" (
    echo ✅ Nginx配置文件存在
) else (
    echo ❌ Nginx配置文件不存在
)

echo.
echo 检查Nginx配置语法...
cd /d C:\nginx
nginx -t
if errorlevel 1 (
    echo ❌ Nginx配置有误
) else (
    echo ✅ Nginx配置正确
)

echo.
echo ========================================
echo 6. 解决方案建议
echo ========================================
echo.

echo 💡 如果HTTPS无法访问，可能的原因:
echo 1. SSL证书文件路径不正确
echo 2. Nginx配置有误
echo 3. 防火墙阻止443端口
echo 4. 域名解析问题
echo 5. 证书文件损坏
echo.

echo 🔧 推荐解决方案:
echo.
echo 方案A: 重新生成SSL证书
echo 1. 运行: run-ssl-correct.bat
echo 2. 使用DNS验证方式
echo 3. 确保证书文件正确生成
echo.
echo 方案B: 修复Nginx配置
echo 1. 检查证书文件路径
echo 2. 重新加载Nginx配置
echo 3. 检查防火墙设置
echo.
echo 方案C: 使用HTTP测试
echo 1. 临时使用HTTP访问
echo 2. 确认API服务正常
echo 3. 再配置HTTPS
echo.

echo ========================================
echo 7. 快速修复脚本
echo ========================================
echo.

set /p fix="是否运行快速修复? (y/n): "
if /i "%fix%"=="y" (
    echo.
    echo 🔄 开始快速修复...
    echo.
    
    echo 步骤1: 重启Nginx服务...
    cd /d C:\nginx
    nginx -s reload
    if errorlevel 1 (
        echo 停止Nginx...
        taskkill /F /IM nginx.exe >nul 2>&1
        timeout /t 2 >nul
        echo 启动Nginx...
        start nginx.exe
    )
    
    echo 步骤2: 检查服务状态...
    timeout /t 3 >nul
    
    echo 步骤3: 测试连接...
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ 修复成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 修复失败:' $_.Exception.Message }"
    
    echo.
    echo 🎉 快速修复完成！
) else (
    echo 跳过快速修复
)

echo.
echo ========================================
echo 诊断完成
echo ========================================
echo.
echo 💡 下一步操作建议:
echo 1. 如果证书文件不存在，运行SSL证书生成脚本
echo 2. 如果Nginx配置有误，检查配置文件
echo 3. 如果网络有问题，检查防火墙设置
echo 4. 如果仍有问题，考虑使用HTTP临时访问
echo.
pause
