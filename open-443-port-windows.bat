@echo off
chcp 65001 >nul
title Windows服务器开启443端口

echo 🔧 Windows服务器开启443端口
echo.

echo 📋 问题诊断:
echo ❌ 443端口在Windows服务器上关闭
echo ❌ 外部无法访问HTTPS服务
echo ✅ 本地服务正常运行
echo.

echo 🎯 解决方案:
echo 1. 配置Windows防火墙
echo 2. 检查云服务商安全组
echo 3. 验证端口开放状态
echo.

echo 🔄 开始修复...
echo.

echo 步骤1: 检查当前防火墙状态...
netsh advfirewall show allprofiles state

echo.
echo 步骤2: 添加443端口防火墙规则...
echo 添加入站规则...
netsh advfirewall firewall add rule name="HTTPS-Inbound" dir=in action=allow protocol=TCP localport=443
if errorlevel 1 (
    echo ❌ 添加入站规则失败
) else (
    echo ✅ 443端口入站规则已添加
)

echo 添加入站规则（备用）...
netsh advfirewall firewall add rule name="HTTPS-Inbound-2" dir=in action=allow protocol=TCP localport=443 profile=any
if errorlevel 1 (
    echo ❌ 添加备用入站规则失败
) else (
    echo ✅ 443端口备用入站规则已添加
)

echo.
echo 步骤3: 检查防火墙规则...
echo 检查443端口规则...
netsh advfirewall firewall show rule name="HTTPS-Inbound"
netsh advfirewall firewall show rule name="HTTPS-Inbound-2"

echo.
echo 步骤4: 检查端口监听状态...
echo 检查443端口是否监听...
netstat -an | findstr :443
if errorlevel 1 (
    echo ❌ 443端口未监听
    echo 💡 需要启动Nginx服务
) else (
    echo ✅ 443端口正在监听
)

echo.
echo 步骤5: 启动Nginx服务（如果未运行）...
tasklist | findstr nginx.exe >nul
if errorlevel 1 (
    echo Nginx未运行，正在启动...
    cd /d C:\nginx
    start nginx.exe
    timeout /t 3 >nul
    echo ✅ Nginx已启动
) else (
    echo ✅ Nginx已在运行
)

echo.
echo 步骤6: 检查服务状态...
echo 检查Nginx进程...
tasklist | findstr nginx.exe
if errorlevel 1 (
    echo ❌ Nginx未运行
) else (
    echo ✅ Nginx运行正常
)

echo.
echo 检查443端口监听...
netstat -an | findstr :443 | findstr LISTENING
if errorlevel 1 (
    echo ❌ 443端口未监听
) else (
    echo ✅ 443端口正在监听
)

echo.
echo 步骤7: 测试本地HTTPS连接...
timeout /t 5 >nul
echo 测试本地HTTPS连接...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://practice.insightdata.top/api/' -Method Head -TimeoutSec 10; Write-Host '✅ 本地HTTPS连接成功 - 状态码:' $response.StatusCode } catch { Write-Host '❌ 本地HTTPS连接失败:' $_.Exception.Message }"

echo.
echo 🎉 Windows防火墙443端口配置完成！
echo.
echo 📋 下一步操作:
echo.
echo 1. 云服务商安全组设置:
echo    - 登录云服务商控制台
echo    - 找到安全组设置
echo    - 添加入站规则: 端口443，协议TCP，源地址0.0.0.0/0
echo    - 保存设置
echo.
echo 2. 验证端口开放:
echo    - 使用在线工具: https://www.yougetsignal.com/tools/open-ports/
echo    - 输入服务器IP: 223.93.139.87
echo    - 输入端口: 443
echo    - 检查端口是否开放
echo.
echo 3. 常见云服务商设置:
echo    - 阿里云ECS: 安全组 -> 入方向规则
echo    - 腾讯云CVM: 安全组 -> 入站规则
echo    - AWS EC2: Security Groups -> Inbound rules
echo    - 华为云ECS: 安全组 -> 入方向规则
echo.
echo 💡 重要提示:
echo 1. Windows防火墙只是第一步
echo 2. 云服务商安全组是必须的
echo 3. 两个都配置完成后才能外网访问
echo 4. 配置后需要等待几分钟生效
echo.
echo 🌐 在线验证工具:
echo - 端口检查: https://www.yougetsignal.com/tools/open-ports/
echo - 域名解析: https://dnschecker.org/
echo - SSL证书检查: https://www.ssllabs.com/ssltest/
echo.
pause
