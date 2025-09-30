@echo off
chcp 65001 >nul
title 正确的SSL证书获取方式

echo 🔐 正确的SSL证书获取方式
echo.

echo 📋 说明:
echo 1. 系统会显示新的TXT记录值
echo 2. 您需要将这个字符串添加到DNS中
echo 3. 等待DNS传播后继续验证
echo.

echo ⚠️  重要提示:
echo 请准备好您的DNS管理面板，以便添加TXT记录
echo.

echo 按任意键开始...
pause >nul

echo.
echo 🔄 开始DNS验证...
echo 注意: 系统会提示您添加TXT记录，请按照提示操作
echo.

REM 清理旧的验证记录
if exist "C:\Certbot\live\practice.insightdata.top" (
    echo 清理旧的验证记录...
    rmdir /s /q "C:\Certbot\live\practice.insightdata.top"
)

echo.
echo 📋 系统将显示新的TXT记录，请按照以下步骤操作:
echo.
echo 1. 复制系统提供的TXT记录值
echo 2. 登录您的DNS管理面板
echo 3. 添加TXT记录:
echo    - 记录类型: TXT
echo    - 主机记录: _acme-challenge.practice
echo    - 记录值: [系统提供的值]
echo 4. 保存DNS设置
echo 5. 等待DNS传播（通常需要5-30分钟）
echo 6. 按回车继续验证
echo.

echo 按回车开始DNS验证...
pause >nul

echo.
echo 🔄 开始DNS验证...
echo.

REM 使用正确的Python模块调用方式
python -c "import certbot.main; certbot.main.main()" certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos

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
    echo 1. 检查TXT记录是否正确添加
    echo 2. 等待DNS传播（通常需要几分钟）
    echo 3. 使用在线工具验证TXT记录
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
pause
