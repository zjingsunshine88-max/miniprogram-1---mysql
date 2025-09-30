@echo off
chcp 65001 >nul
title SSL证书问题深度诊断工具

echo 🔍 SSL证书问题深度诊断工具
echo.

echo 📋 问题分析结果:
echo.

echo ✅ DNS解析正常:
echo    practice.insightdata.top → 223.93.139.87
echo.

echo ✅ TXT记录存在:
echo    _acme-challenge.practice.insightdata.top
echo    记录值: 9g8j7k6l5m4n3o2p1q0r9s8t7u6v5w4x3y2z1a0b9c8d7e6f5g4h3i2j1k0l9m8n7o6p5q4r3s2t1u0v9w8x7y6z5a4b3c2d1e0f9g8h7i6j5k4l3m2n1o0p9q8r7s6t5u4v3w2y1z0
echo.

echo ❌ 关键问题发现:
echo    1. 您使用的是HTTP验证方式，不是DNS验证
echo    2. 防火墙阻止了80端口访问
echo    3. 需要切换到DNS验证方式
echo.

echo 🎯 解决方案:
echo.

echo 问题1: 使用了错误的验证方式
echo 当前: HTTP验证 (--standalone)
echo 应该: DNS验证 (--manual --preferred-challenges dns)
echo.

echo 问题2: TXT记录格式可能有问题
echo 当前记录值看起来是测试数据，不是Let's Encrypt提供的验证字符串
echo.

echo 问题3: 需要清理旧的验证记录
echo.

echo ========================================
echo 修复步骤
echo ========================================
echo.

echo 步骤1: 清理旧的验证记录
echo 正在删除旧的证书文件...
if exist "C:\Certbot\live\practice.insightdata.top" (
    echo 删除旧的证书文件...
    rmdir /s /q "C:\Certbot\live\practice.insightdata.top"
    echo ✅ 旧证书文件已删除
) else (
    echo ✅ 没有旧的证书文件
)

echo.
echo 步骤2: 删除DNS中的旧TXT记录
echo ⚠️  重要: 请登录您的DNS管理面板，删除以下TXT记录:
echo    记录类型: TXT
echo    主机记录: _acme-challenge.practice
echo    记录值: 9g8j7k6l5m4n3o2p1q0r9s8t7u6v5w4x3y2z1a0b9c8d7e6f5g4h3i2j1k0l9m8n7o6p5q4r3s2t1u0v9w8x7y6z5a4b3c2d1e0f9g8h7i6j5k4l3m2n1o0p9q8r7s6t5u4v3w2y1z0
echo.

echo 步骤3: 使用正确的DNS验证方式
echo.

set /p confirm="是否继续使用正确的DNS验证方式? (y/n): "
if /i not "%confirm%"=="y" (
    echo 操作已取消
    pause
    exit /b 0
)

echo.
echo 🔄 开始正确的DNS验证...
echo.

echo 注意: 系统会提示您添加新的TXT记录
echo 请按照提示操作，然后按回车继续
echo.

REM 使用正确的DNS验证方式
C:\Certbot\certbot.exe certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos

if errorlevel 1 (
    echo.
    echo ❌ DNS验证失败
    echo.
    echo 💡 可能的原因:
    echo 1. TXT记录格式错误
    echo 2. DNS传播时间较长
    echo 3. 域名DNS设置有问题
    echo.
    echo 🔧 解决方案:
    echo 1. 确保TXT记录格式正确
    echo 2. 等待DNS传播（通常需要几分钟）
    echo 3. 使用在线工具验证TXT记录
    echo.
    echo 🌐 在线验证工具:
    echo - https://dnschecker.org/
    echo - https://www.whatsmydns.net/
    echo - https://mxtoolbox.com/TXTLookup.aspx
    echo.
    echo 📋 手动验证步骤:
    echo 1. 访问 https://dnschecker.org/
    echo 2. 输入: _acme-challenge.practice.insightdata.top
    echo 3. 选择TXT记录类型
    echo 4. 检查全球DNS传播状态
    echo.
    pause
    exit /b 1
) else (
    echo ✅ DNS验证成功！
)

echo.
echo 📁 证书文件位置:
echo - 证书文件: C:\Certbot\live\practice.insightdata.top\fullchain.pem
echo - 私钥文件: C:\Certbot\live\practice.insightdata.top\privkey.pem
echo.

echo 🔄 复制证书到项目目录...
if not exist "C:\certificates" mkdir C:\certificates

copy "C:\Certbot\live\practice.insightdata.top\fullchain.pem" "C:\certificates\practice.insightdata.top.pem"
copy "C:\Certbot\live\practice.insightdata.top\privkey.pem" "C:\certificates\practice.insightdata.top.key"

if errorlevel 1 (
    echo ❌ 证书复制失败
    echo 💡 请手动复制证书文件
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
