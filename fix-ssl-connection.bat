@echo off
chcp 65001 >nul
title SSL证书连接问题修复工具

echo 🔧 SSL证书连接问题诊断和修复工具
echo.

echo 📋 问题分析:
echo 错误信息显示: Timeout during connect (likely firewall problem)
echo 这表明Let's Encrypt无法通过HTTP验证您的域名
echo.

echo 🔍 开始诊断...
echo.

echo 步骤1: 检查域名解析...
echo 正在检查 practice.insightdata.top 的DNS解析...
nslookup practice.insightdata.top

echo.
echo 步骤2: 检查80端口占用...
echo 正在检查80端口是否被占用...
netstat -ano | findstr :80

echo.
echo 步骤3: 检查防火墙状态...
echo 正在检查Windows防火墙状态...
netsh advfirewall show allprofiles state

echo.
echo 步骤4: 测试端口连通性...
echo 正在测试80端口是否可以从外部访问...
echo 请确保您的服务器IP可以从外网访问80端口

echo.
echo 🔧 修复方案:
echo.
echo 方案1: 使用DNS验证（推荐）
echo 如果HTTP验证失败，可以使用DNS验证方式
echo.
echo 方案2: 检查并修复网络配置
echo 1. 确保域名正确解析到服务器IP
echo 2. 确保80端口没有被其他服务占用
echo 3. 确保防火墙允许80端口入站连接
echo 4. 确保服务器可以从外网访问
echo.
echo 方案3: 使用手动验证
echo 如果自动验证失败，可以手动下载验证文件
echo.

set /p choice="请选择修复方案 (1=DNS验证, 2=网络修复, 3=手动验证): "

if "%choice%"=="1" goto dns_validation
if "%choice%"=="2" goto network_fix
if "%choice%"=="3" goto manual_validation
goto end

:dns_validation
echo.
echo 🔐 使用DNS验证方式...
echo.
echo 注意: DNS验证需要您手动添加TXT记录到域名DNS设置中
echo.
echo 运行DNS验证命令:
certbot certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos
echo.
echo 按照提示添加TXT记录到您的DNS设置中
goto end

:network_fix
echo.
echo 🔧 网络配置修复...
echo.
echo 1. 检查并停止占用80端口的服务...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :80') do (
    echo 发现进程ID %%a 占用80端口
    echo 正在尝试停止进程...
    taskkill /PID %%a /F
)

echo.
echo 2. 配置Windows防火墙...
echo 正在添加防火墙规则允许80和443端口...
netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="HTTPS" dir=in action=allow protocol=TCP localport=443

echo.
echo 3. 检查域名解析...
echo 请确认 practice.insightdata.top 解析到正确的IP地址
echo 当前服务器IP应该是: 
ipconfig | findstr "IPv4"

echo.
echo 4. 重新尝试获取证书...
echo 现在可以重新运行证书获取命令:
echo certbot certonly --standalone -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos --non-interactive
goto end

:manual_validation
echo.
echo 📝 手动验证方式...
echo.
echo 1. 首先获取验证文件:
certbot certonly --manual --preferred-challenges http -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos

echo.
echo 2. 按照提示:
echo - 将验证文件放到网站根目录的 .well-known/acme-challenge/ 目录
echo - 确保文件可以通过 http://practice.insightdata.top/.well-known/acme-challenge/ 访问
echo - 然后按回车继续验证

goto end

:end
echo.
echo 💡 其他解决方案:
echo.
echo 1. 使用Cloudflare等CDN服务:
echo    - 在Cloudflare中启用"Full SSL"模式
echo    - 使用Cloudflare的SSL证书
echo.
echo 2. 使用自签名证书进行测试:
echo    - 生成自签名证书用于开发测试
echo    - 生产环境仍需要有效证书
echo.
echo 3. 联系服务器提供商:
echo    - 确认服务器网络配置
echo    - 检查是否有端口限制
echo.
echo 4. 使用其他证书提供商:
echo    - 考虑使用其他SSL证书服务
echo    - 如阿里云、腾讯云等提供的免费证书
echo.
pause
