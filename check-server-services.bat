@echo off
chcp 65001 >nul
title 服务器服务状态检查

echo 🔍 服务器服务状态检查
echo ========================================
echo.

set DOMAIN=practice.insightdata.top
set IP=223.93.139.87

echo 📋 检查目标:
echo 域名: %DOMAIN%
echo IP地址: %IP%
echo.

echo 步骤1: 检查服务器端口监听状态...
echo.
echo 🔌 检查端口443 (HTTPS):
powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%IP%', 443); $tcp.Close(); Write-Host '✅ 端口443监听正常' } catch { Write-Host '❌ 端口443未监听:' $_.Exception.Message }"
echo.

echo 🔌 检查端口3002 (API):
powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%IP%', 3002); $tcp.Close(); Write-Host '✅ 端口3002监听正常' } catch { Write-Host '❌ 端口3002未监听:' $_.Exception.Message }"
echo.

echo 🔌 检查端口80 (HTTP):
powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%IP%', 80); $tcp.Close(); Write-Host '✅ 端口80监听正常' } catch { Write-Host '❌ 端口80未监听:' $_.Exception.Message }"
echo.

echo 步骤2: 测试API端点响应...
echo.
echo 🌐 测试HTTPS API根路径:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/api/' -Method GET -TimeoutSec 10; Write-Host '✅ HTTPS API根路径响应:' $response.StatusCode; Write-Host '响应内容长度:' $response.Content.Length } catch { Write-Host '❌ HTTPS API根路径失败:' $_.Exception.Message }"
echo.

echo 🌐 测试HTTP API根路径:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://%IP%:3002/api/' -Method GET -TimeoutSec 10; Write-Host '✅ HTTP API根路径响应:' $response.StatusCode; Write-Host '响应内容长度:' $response.Content.Length } catch { Write-Host '❌ HTTP API根路径失败:' $_.Exception.Message }"
echo.

echo 🌐 测试健康检查端点:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/health' -Method GET -TimeoutSec 10; Write-Host '✅ 健康检查响应:' $response.StatusCode; Write-Host '响应内容:' $response.Content } catch { Write-Host '❌ 健康检查失败:' $_.Exception.Message }"
echo.

echo 🌐 测试管理后台:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/' -Method GET -TimeoutSec 10; Write-Host '✅ 管理后台响应:' $response.StatusCode; Write-Host '响应内容长度:' $response.Content.Length } catch { Write-Host '❌ 管理后台失败:' $_.Exception.Message }"
echo.

echo 步骤3: 检查SSL证书...
echo.
echo 🔐 检查SSL证书信息:
powershell -Command "try { $request = [System.Net.WebRequest]::Create('https://%DOMAIN%/'); $request.GetResponse() | Out-Null; $cert = $request.ServicePoint.Certificate; $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert); Write-Host '✅ SSL证书有效'; Write-Host '证书主题:' $cert2.Subject; Write-Host '证书颁发者:' $cert2.Issuer; Write-Host '有效期至:' $cert2.NotAfter } catch { Write-Host '❌ SSL证书检查失败:' $_.Exception.Message }"
echo.

echo 步骤4: 测试具体API端点...
echo.
echo 🌐 测试用户API:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/api/user/info' -Method GET -TimeoutSec 10; Write-Host '✅ 用户API响应:' $response.StatusCode } catch { Write-Host '❌ 用户API失败:' $_.Exception.Message }"
echo.

echo 🌐 测试题库API:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/api/question-bank/list' -Method GET -TimeoutSec 10; Write-Host '✅ 题库API响应:' $response.StatusCode } catch { Write-Host '❌ 题库API失败:' $_.Exception.Message }"
echo.

echo 🌐 测试激活码API:
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://%DOMAIN%/api/activation-code/verify' -Method POST -ContentType 'application/json' -Body '{\"code\":\"test\"}' -TimeoutSec 10; Write-Host '✅ 激活码API响应:' $response.StatusCode } catch { Write-Host '❌ 激活码API失败:' $_.Exception.Message }"
echo.

echo 步骤5: 分析结果...
echo.
echo 📊 检查结果分析:
echo.
echo 如果端口443未监听:
echo - 检查Nginx服务是否启动
echo - 检查防火墙是否阻止443端口
echo - 检查SSL证书配置
echo.
echo 如果端口3002未监听:
echo - 检查Node.js API服务是否启动
echo - 检查服务是否绑定到正确的端口
echo - 检查防火墙是否阻止3002端口
echo.
echo 如果API响应失败:
echo - 检查API服务内部错误
echo - 检查数据库连接
echo - 检查CORS配置
echo.
echo 如果SSL证书无效:
echo - 检查证书文件是否存在
echo - 检查证书是否过期
echo - 检查域名是否匹配
echo.

echo 💡 服务器端需要检查的服务:
echo.
echo 1. Nginx服务状态:
echo    netstat -an | findstr :443
echo    tasklist | findstr nginx.exe
echo.
echo 2. Node.js API服务状态:
echo    netstat -an | findstr :3002
echo    tasklist | findstr node.exe
echo.
echo 3. 防火墙设置:
echo    - Windows防火墙 - 入站规则
echo    - 确保443和3002端口开放
echo.
echo 4. 服务日志:
echo    - Nginx错误日志
echo    - API服务控制台输出
echo.

echo 🎯 下一步操作:
echo.
echo 1. 如果所有测试都失败，说明服务器服务未启动
echo 2. 如果部分测试失败，说明特定服务有问题
echo 3. 如果所有测试都成功，说明问题在客户端网络环境
echo.

echo 按任意键退出...
pause >nul
