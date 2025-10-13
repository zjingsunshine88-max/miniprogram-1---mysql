@echo off
chcp 65001 >nul
title 域名访问测试

echo 🔍 域名访问测试
echo ========================================
echo.

set DOMAIN=practice.insightdata.top
set IP=223.93.139.87

echo 📋 测试目标:
echo 域名: %DOMAIN%
echo IP地址: %IP%
echo.

echo 步骤1: 测试DNS解析...
echo.
nslookup %DOMAIN%
echo.
echo 如果上面显示"找不到主机"，说明DNS解析有问题
echo.

echo 步骤2: 测试IP连通性...
echo.
ping %IP% -n 2
echo.

echo 步骤3: 测试域名连通性...
echo.
ping %DOMAIN% -n 2
echo.

echo 步骤4: 测试端口443 (HTTPS)...
echo.
echo 正在测试HTTPS端口连通性...
powershell -Command "Test-NetConnection -ComputerName %DOMAIN% -Port 443"
echo.

echo 步骤5: 测试API端点...
echo.
echo 正在测试API端点...
powershell -Command "try { Invoke-WebRequest -Uri 'https://%DOMAIN%/api/' -Method GET -TimeoutSec 10 } catch { Write-Host 'API访问失败:' $_.Exception.Message }"
echo.

echo 💡 问题分析:
echo.
echo ✅ 如果步骤1失败: DNS解析问题
echo ✅ 如果步骤2成功但步骤3失败: 域名解析问题  
echo ✅ 如果步骤4失败: 端口443被阻止
echo ✅ 如果步骤5失败: SSL或API服务问题
echo.

echo 🛠️ 解决方案:
echo.
echo 1. 更换DNS服务器:
echo    - 网络设置 - 更改适配器选项 - 右键网络连接 - 属性 - IPv4 - DNS
echo    - 首选: 8.8.8.8
echo    - 备用: 223.5.5.5
echo.
echo 2. 检查防火墙:
echo    - Windows防火墙 - 允许应用通过防火墙
echo    - 确保浏览器和网络访问被允许
echo.
echo 3. 检查代理设置:
echo    - Internet选项 - 连接 - 局域网设置
echo    - 确保没有代理服务器干扰
echo.

echo 按任意键退出...
pause >nul
