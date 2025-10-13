@echo off
chcp 65001 >nul
title 快速API测试

echo 🚀 快速API测试
echo ========================================
echo.

set DOMAIN=practice.insightdata.top
set IP=223.93.139.87

echo 📋 测试目标:
echo HTTPS域名: https://%DOMAIN%/api/
echo HTTP直连: http://%IP%:3002/api/
echo.

echo 步骤1: 测试网络连通性...
ping %DOMAIN% -n 2 >nul
if errorlevel 1 (
    echo ❌ 网络连通失败
    pause
    exit /b 1
) else (
    echo ✅ 网络连通正常
)
echo.

echo 步骤2: 测试HTTPS API...
echo 🌐 正在测试HTTPS API...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/api/' -Method GET -TimeoutSec 5; Write-Host '✅ HTTPS API正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTPS API失败:' $_.Exception.Message }"
echo.

echo 步骤3: 测试HTTP API...
echo 🌐 正在测试HTTP API...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://%IP%:3002/api/' -Method GET -TimeoutSec 5; Write-Host '✅ HTTP API正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTP API失败:' $_.Exception.Message }"
echo.

echo 步骤4: 测试健康检查...
echo 🌐 正在测试健康检查...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/health' -Method GET -TimeoutSec 5; Write-Host '✅ 健康检查正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 健康检查失败:' $_.Exception.Message }"
echo.

echo 步骤5: 测试管理后台...
echo 🌐 正在测试管理后台...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/' -Method GET -TimeoutSec 5; Write-Host '✅ 管理后台正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 管理后台失败:' $_.Exception.Message }"
echo.

echo 📊 测试总结:
echo.
echo 如果HTTPS API失败但HTTP API成功:
echo - 问题在于SSL/HTTPS配置
echo - 检查Nginx SSL配置
echo - 检查SSL证书
echo.
echo 如果两个API都失败:
echo - 问题在于服务器服务未启动
echo - 检查API服务状态
echo - 检查端口监听
echo.
echo 如果都成功:
echo - 网络和服务都正常
echo - 问题可能在客户端配置
echo.

echo 💡 微信小程序配置检查:
echo.
echo 当前小程序配置:
echo BASE_URL: https://%DOMAIN%
echo.
echo 如果HTTPS失败，可以临时改为:
echo BASE_URL: http://%IP%:3002
echo.

echo 按任意键退出...
pause >nul
