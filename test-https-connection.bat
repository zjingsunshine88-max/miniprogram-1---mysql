@echo off
chcp 65001 >nul
title 测试HTTPS连接

echo 🔍 测试HTTPS连接
echo.

echo 📋 测试项目:
echo 1. 域名解析测试
echo 2. 本地API服务测试
echo 3. HTTPS连接测试
echo 4. 防火墙检查
echo.

echo ========================================
echo 1. 域名解析测试
echo ========================================
echo 检查域名解析...
nslookup practice.insightdata.top
echo.

echo ========================================
echo 2. 本地API服务测试
echo ========================================
echo 测试本地API服务...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3002/api/' -Method Head -TimeoutSec 5; Write-Host '✅ 本地API服务正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 本地API服务异常:' $_.Exception.Message }"

echo.
echo 测试外网API服务...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://223.93.139.87:3002/api/' -Method Head -TimeoutSec 10; Write-Host '✅ 外网API服务正常 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 外网API服务异常:' $_.Exception.Message }"

echo.
echo ========================================
echo 3. HTTPS连接测试
echo ========================================
echo 测试HTTPS连接...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ HTTPS连接成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ HTTPS连接失败:' $_.Exception.Message }"

echo.
echo ========================================
echo 4. 防火墙检查
echo ========================================
echo 检查443端口防火墙规则...
netsh advfirewall firewall show rule name="HTTPS" >nul 2>&1
if errorlevel 1 (
    echo ❌ 443端口防火墙规则不存在
    echo 添加防火墙规则...
    netsh advfirewall firewall add rule name="HTTPS" dir=in action=allow protocol=TCP localport=443
    echo ✅ 防火墙规则已添加
) else (
    echo ✅ 443端口防火墙规则已存在
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
echo 5. 解决方案建议
echo ========================================
echo.

echo 💡 如果HTTPS无法访问，可能的原因:
echo 1. 云服务商安全组未开放443端口
echo 2. 域名解析到错误的IP地址
echo 3. SSL证书配置问题
echo 4. Nginx代理配置问题
echo.

echo 🔧 推荐解决方案:
echo.
echo 方案A: 检查云服务商安全组
echo 1. 登录云服务商控制台
echo 2. 检查安全组设置
echo 3. 确保443端口对外开放
echo 4. 确保80端口对外开放
echo.
echo 方案B: 检查域名解析
echo 1. 确保域名解析到正确的IP: 223.93.139.87
echo 2. 等待DNS传播
echo 3. 使用在线工具验证: https://dnschecker.org/
echo.
echo 方案C: 重新配置SSL证书
echo 1. 运行: run-ssl-correct.bat
echo 2. 使用DNS验证方式
echo 3. 确保证书文件正确生成
echo.
echo 方案D: 使用在线工具测试
echo 1. 端口检查: https://www.yougetsignal.com/tools/open-ports/
echo 2. 输入服务器IP: 223.93.139.87
echo 3. 输入端口: 443
echo 4. 检查端口是否开放
echo.

echo ========================================
echo 测试完成
echo ========================================
echo.
echo 💡 下一步操作建议:
echo 1. 如果云服务商安全组有问题，联系服务商
echo 2. 如果域名解析有问题，检查DNS设置
echo 3. 如果SSL证书有问题，重新生成证书
echo 4. 如果网络有问题，使用在线工具测试
echo.
pause
