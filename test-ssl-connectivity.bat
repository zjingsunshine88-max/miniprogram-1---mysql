@echo off
chcp 65001 >nul
title SSL连接性测试工具

echo 🔍 SSL证书连接性测试工具
echo.

echo 📋 测试项目:
echo 1. 域名DNS解析
echo 2. 端口占用检查
echo 3. 防火墙状态
echo 4. 网络连通性
echo.

echo ========================================
echo 1. 域名DNS解析测试
echo ========================================
echo 正在测试 practice.insightdata.top 的DNS解析...
nslookup practice.insightdata.top
echo.

echo 检查是否解析到正确的IP地址...
for /f "tokens=2" %%a in ('nslookup practice.insightdata.top ^| findstr "Address"') do (
    echo 域名解析到: %%a
)

echo.
echo ========================================
echo 2. 端口占用检查
echo ========================================
echo 检查80端口占用情况...
netstat -ano | findstr :80
if errorlevel 1 (
    echo ✅ 80端口未被占用
) else (
    echo ⚠️  80端口被占用，需要停止相关服务
)

echo.
echo 检查443端口占用情况...
netstat -ano | findstr :443
if errorlevel 1 (
    echo ✅ 443端口未被占用
) else (
    echo ⚠️  443端口被占用
)

echo.
echo ========================================
echo 3. 防火墙状态检查
echo ========================================
echo 检查Windows防火墙状态...
netsh advfirewall show allprofiles state

echo.
echo 检查80端口防火墙规则...
netsh advfirewall firewall show rule name="HTTP" >nul 2>&1
if errorlevel 1 (
    echo ❌ 80端口防火墙规则不存在
    echo 💡 需要添加防火墙规则: netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80
) else (
    echo ✅ 80端口防火墙规则已存在
)

echo.
echo 检查443端口防火墙规则...
netsh advfirewall firewall show rule name="HTTPS" >nul 2>&1
if errorlevel 1 (
    echo ❌ 443端口防火墙规则不存在
    echo 💡 需要添加防火墙规则: netsh advfirewall firewall add rule name="HTTPS" dir=in action=allow protocol=TCP localport=443
) else (
    echo ✅ 443端口防火墙规则已存在
)

echo.
echo ========================================
echo 4. 网络连通性测试
echo ========================================
echo 测试本地80端口监听...
netstat -an | findstr ":80.*LISTENING"
if errorlevel 1 (
    echo ❌ 本地80端口未监听
    echo 💡 需要启动Web服务器或临时监听80端口
) else (
    echo ✅ 本地80端口正在监听
)

echo.
echo 测试外网连通性...
echo 正在测试从外网访问80端口...
echo 注意: 这个测试需要从外网进行，建议使用在线工具测试
echo 推荐测试工具: https://www.yougetsignal.com/tools/open-ports/

echo.
echo ========================================
echo 5. 服务器配置检查
echo ========================================
echo 检查当前服务器IP地址...
ipconfig | findstr "IPv4"

echo.
echo 检查Nginx状态...
nginx -t >nul 2>&1
if errorlevel 1 (
    echo ❌ Nginx配置有误
    echo 💡 请检查Nginx配置文件
) else (
    echo ✅ Nginx配置正常
)

echo.
echo ========================================
echo 6. 解决方案建议
echo ========================================
echo.
echo 如果DNS解析正常但连接超时，可能的原因:
echo 1. 防火墙阻止了80端口入站连接
echo 2. 服务器提供商限制了端口访问
echo 3. 域名解析到错误的IP地址
echo 4. 网络路由问题
echo.
echo 推荐解决方案:
echo.
echo 方案A: 使用DNS验证（最简单）
echo certbot certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos
echo.
echo 方案B: 修复网络配置
echo 1. 添加防火墙规则
echo 2. 确保80端口可访问
echo 3. 重新尝试HTTP验证
echo.
echo 方案C: 使用其他证书服务
echo 1. 阿里云免费SSL证书
echo 2. 腾讯云免费SSL证书
echo 3. Cloudflare SSL证书
echo.

echo ========================================
echo 测试完成
echo ========================================
echo.
echo 💡 下一步操作建议:
echo 1. 如果DNS解析正常，尝试DNS验证方式
echo 2. 如果网络有问题，联系服务器提供商
echo 3. 考虑使用其他SSL证书服务
echo.
pause
