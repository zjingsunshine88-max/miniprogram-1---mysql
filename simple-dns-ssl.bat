@echo off
chcp 65001 >nul
title 简单DNS验证SSL证书

echo 🔐 简单DNS验证SSL证书工具
echo.

echo 📋 当前问题分析:
echo ❌ HTTP验证失败: 防火墙阻止80端口
echo ✅ DNS解析正常: practice.insightdata.top → 223.93.139.87
echo ✅ TXT记录存在: _acme-challenge.practice.insightdata.top
echo.

echo 🎯 解决方案: 使用DNS验证（推荐）
echo.

echo 📝 操作步骤:
echo 1. 系统会提示您添加新的TXT记录
echo 2. 请按照提示在DNS中添加TXT记录
echo 3. 等待DNS传播（通常需要几分钟）
echo 4. 按回车继续验证
echo.

set /p confirm="是否开始DNS验证? (y/n): "
if /i not "%confirm%"=="y" (
    echo 操作已取消
    pause
    exit /b 0
)

echo.
echo 🔄 开始DNS验证...
echo.

REM 清理之前的验证记录
if exist "C:\Certbot\live\practice.insightdata.top" (
    echo 清理旧的验证记录...
    rmdir /s /q "C:\Certbot\live\practice.insightdata.top"
)

REM 使用DNS验证方式
C:\Certbot\certbot.exe certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos

if errorlevel 1 (
    echo.
    echo ❌ DNS验证失败
    echo.
    echo 💡 常见问题解决方案:
    echo.
    echo 1. TXT记录格式错误
    echo    - 确保记录类型是TXT
    echo    - 主机记录: _acme-challenge.practice
    echo    - 记录值: [系统提供的完整字符串]
    echo.
    echo 2. DNS传播时间
    echo    - 等待5-10分钟让DNS传播
    echo    - 使用在线工具检查: https://dnschecker.org/
    echo.
    echo 3. 域名解析问题
    echo    - 确保域名正确解析到服务器IP
    echo    - 检查DNS设置是否正确
    echo.
    echo 🌐 在线验证工具:
    echo - https://dnschecker.org/
    echo - https://www.whatsmydns.net/
    echo - https://mxtoolbox.com/TXTLookup.aspx
    echo.
    pause
    exit /b 1
) else (
    echo ✅ DNS验证成功！
)

echo.
echo 📁 证书文件位置:
echo - 证书: C:\Certbot\live\practice.insightdata.top\fullchain.pem
echo - 私钥: C:\Certbot\live\practice.insightdata.top\privkey.pem
echo.

echo 🔄 复制证书到项目目录...
if not exist "C:\certificates" mkdir C:\certificates

copy "C:\Certbot\live\practice.insightdata.top\fullchain.pem" "C:\certificates\practice.insightdata.top.pem"
copy "C:\Certbot\live\practice.insightdata.top\privkey.pem" "C:\certificates\practice.insightdata.top.key"

if errorlevel 1 (
    echo ❌ 证书复制失败，请手动复制
) else (
    echo ✅ 证书复制成功
)

echo.
echo 🎉 SSL证书配置完成！
echo.
echo 🌐 测试访问:
echo - HTTPS: https://practice.insightdata.top
echo.
echo 💡 注意事项:
echo 1. 证书有效期为90天
echo 2. 可以删除DNS中的TXT记录
echo 3. 证书会自动续期
echo.
pause
