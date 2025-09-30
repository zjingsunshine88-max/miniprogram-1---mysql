@echo off
chcp 65001 >nul
title 显示TXT记录获取过程

echo 🔐 显示TXT记录获取过程
echo.

echo 📋 新的TXT记录获取步骤:
echo.

echo 步骤1: 运行DNS验证命令
echo 命令: C:\Certbot\certbot.exe certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos
echo.

echo 步骤2: 系统会显示类似以下内容:
echo.
echo ========================================
echo Please deploy a DNS TXT record under the name
echo _acme-challenge.practice.insightdata.top with the following value:
echo.
echo [这里会显示新的验证字符串]
echo.
echo Before continuing, verify the record is deployed.
echo.
echo Press Enter to Continue
echo ========================================
echo.

echo 步骤3: 复制显示的验证字符串
echo 步骤4: 在DNS管理面板中添加TXT记录
echo 步骤5: 等待DNS传播
echo 步骤6: 按回车继续验证
echo.

echo 📝 DNS记录格式:
echo - 记录类型: TXT
echo - 主机记录: _acme-challenge.practice
echo - 记录值: [系统提供的验证字符串]
echo.

echo 🌐 验证TXT记录是否生效:
echo 使用在线工具检查: https://dnschecker.org/
echo 输入: _acme-challenge.practice.insightdata.top
echo 选择: TXT
echo.

set /p confirm="是否开始获取新的TXT记录? (y/n): "
if /i not "%confirm%"=="y" (
    echo 操作已取消
    pause
    exit /b 0
)

echo.
echo 🔄 开始DNS验证...
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
echo 注意: 系统会提示您添加TXT记录，请按照提示操作
echo.

REM 使用DNS验证方式
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
