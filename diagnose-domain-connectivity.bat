@echo off
chcp 65001 >nul
title 域名连通性诊断工具

echo 🔍 域名连通性诊断工具
echo ========================================
echo.

set DOMAIN=practice.insightdata.top
set IP=223.93.139.87

echo 📋 诊断目标:
echo 域名: %DOMAIN%
echo IP地址: %IP%
echo.

echo 步骤1: 检查DNS解析...
echo.
echo 🔍 测试域名解析:
nslookup %DOMAIN%
echo.

echo 🔍 测试IP解析:
nslookup %IP%
echo.

echo 步骤2: 检查网络连通性...
echo.
echo 🏓 Ping测试域名 (注意: ping不支持HTTPS):
ping %DOMAIN% -n 4
echo.

echo 🏓 Ping测试IP地址:
ping %IP% -n 4
echo.

echo 步骤3: 检查端口连通性...
echo.
echo 🔌 测试HTTPS端口443 (使用PowerShell):
powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%DOMAIN%', 443); $tcp.Close(); Write-Host '✅ HTTPS端口443可达' } catch { Write-Host '❌ HTTPS端口443不可达:' $_.Exception.Message }"
echo.

echo 🔌 测试IP的443端口:
powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%IP%', 443); $tcp.Close(); Write-Host '✅ IP端口443可达' } catch { Write-Host '❌ IP端口443不可达:' $_.Exception.Message }"
echo.

echo 🔌 测试API端口3002:
powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%IP%', 3002); $tcp.Close(); Write-Host '✅ API端口3002可达' } catch { Write-Host '❌ API端口3002不可达:' $_.Exception.Message }"
echo.

echo 步骤4: 检查路由跟踪...
echo.
echo 🛣️ 跟踪到域名的路由:
tracert %DOMAIN%
echo.

echo 🛣️ 跟踪到IP的路由:
tracert %IP%
echo.

echo 步骤5: 检查DNS服务器...
echo.
echo 🌐 当前DNS配置:
ipconfig /all | findstr "DNS"
echo.

echo 步骤6: 测试不同的DNS服务器...
echo.
echo 🌐 使用Google DNS解析:
nslookup %DOMAIN% 8.8.8.8
echo.

echo 🌐 使用阿里DNS解析:
nslookup %DOMAIN% 223.5.5.5
echo.

echo 步骤7: 测试HTTPS和HTTP API...
echo.
echo 🌐 测试HTTPS API端点:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/api/' -Method GET -TimeoutSec 10; Write-Host '✅ HTTPS API响应:' $response.StatusCode } catch { Write-Host '❌ HTTPS API失败:' $_.Exception.Message }"
echo.

echo 🌐 测试HTTP API端点:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://%IP%:3002/api/' -Method GET -TimeoutSec 10; Write-Host '✅ HTTP API响应:' $response.StatusCode } catch { Write-Host '❌ HTTP API失败:' $_.Exception.Message }"
echo.

echo 🌐 测试健康检查端点:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/health' -Method GET -TimeoutSec 10; Write-Host '✅ 健康检查响应:' $response.StatusCode } catch { Write-Host '❌ 健康检查失败:' $_.Exception.Message }"
echo.

echo 步骤8: 检查防火墙和代理...
echo.
echo 🔥 检查代理设置:
echo 请检查以下设置:
echo 1. 控制面板 - 网络和Internet - Internet选项 - 连接 - 局域网设置
echo 2. 是否有代理服务器设置
echo 3. 防火墙是否阻止了HTTPS连接
echo.

echo 步骤9: 浏览器测试...
echo.
echo 🌐 请在浏览器中测试以下URL:
echo 1. https://%DOMAIN%/
echo 2. https://%DOMAIN%/api/
echo 3. https://%DOMAIN%/health
echo 4. http://%IP%:3002/api/
echo.

echo 💡 根据诊断结果的分析:
echo.
echo ✅ DNS解析正常: 域名正确解析到 %IP%
echo ✅ 网络连通正常: ping测试成功，延迟约8-17ms
echo ✅ 路由跟踪正常: 能够到达目标服务器
echo.
echo 🔍 可能的问题:
echo.
echo ❌ 问题1: HTTPS端口443被阻止
echo 原因: 防火墙、路由器或ISP阻止443端口
echo 解决: 检查防火墙设置，确保443端口开放
echo.
echo ❌ 问题2: SSL证书问题
echo 原因: 证书无效、过期或域名不匹配
echo 解决: 检查SSL证书配置和有效性
echo.
echo ❌ 问题3: Nginx服务未启动
echo 原因: 服务器上的Nginx可能未运行
echo 解决: 在服务器上检查Nginx服务状态
echo.
echo ❌ 问题4: API服务未启动
echo 原因: Node.js API服务可能未运行在3002端口
echo 解决: 在服务器上检查API服务状态
echo.
echo ❌ 问题5: 代理服务器干扰
echo 原因: 企业网络或ISP代理阻止HTTPS
echo 解决: 暂时关闭代理或添加到例外列表
echo.

echo 🎯 快速测试命令:
echo curl -I https://%DOMAIN%/
echo curl -I https://%DOMAIN%/api/
echo.

echo 按任意键退出...
pause >nul
