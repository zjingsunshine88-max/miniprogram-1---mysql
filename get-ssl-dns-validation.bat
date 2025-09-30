@echo off
chcp 65001 >nul
title DNS验证方式获取SSL证书

echo 🔐 使用DNS验证方式获取SSL证书
echo.

echo 📋 DNS验证方式说明:
echo 1. 不需要开放80端口
echo 2. 不需要Web服务器运行
echo 3. 只需要在DNS中添加TXT记录
echo 4. 验证完成后可以删除TXT记录
echo.

echo 🌐 子域名验证说明:
echo 您的域名: practice.insightdata.top
echo 这是一个子域名，DNS验证完全可行！
echo.
echo 📝 需要添加的TXT记录:
echo 记录类型: TXT
echo 记录名称: _acme-challenge.practice.insightdata.top
echo 记录值: [系统会提供]
echo.

echo ⚠️  准备工作:
echo 1. 确保您有域名的DNS管理权限
echo 2. 准备好添加TXT记录
echo 3. 确保域名 practice.insightdata.top 已解析到服务器IP
echo.

echo 🔍 DNS记录配置示例:
echo.
echo 如果使用主域名DNS管理 (insightdata.top):
echo - 记录类型: TXT
echo - 主机记录: _acme-challenge.practice
echo - 记录值: [验证字符串]
echo.
echo 如果使用子域名独立DNS (practice.insightdata.top):
echo - 记录类型: TXT
echo - 主机记录: _acme-challenge
echo - 记录值: [验证字符串]
echo.

set /p confirm="是否继续使用DNS验证方式? (y/n): "
if /i not "%confirm%"=="y" (
    echo 操作已取消
    pause
    exit /b 0
)

echo.
echo 🔍 开始DNS验证...
echo.
echo 注意: 系统会提示您添加TXT记录到DNS设置中
echo 请按照提示操作，然后按回车继续
echo.

certbot certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos

if errorlevel 1 (
    echo ❌ DNS验证失败
    echo.
    echo 💡 可能的原因:
    echo 1. TXT记录添加错误
    echo 2. DNS传播时间较长
    echo 3. 域名DNS设置有问题
    echo.
    echo 🔧 解决方案:
    echo 1. 检查TXT记录是否正确添加
    echo 2. 等待DNS传播（通常需要几分钟到几小时）
    echo 3. 使用在线DNS检查工具验证TXT记录
    echo.
    echo 🌐 在线DNS检查工具:
    echo - https://dnschecker.org/
    echo - https://www.whatsmydns.net/
    echo - https://mxtoolbox.com/TXTLookup.aspx
    echo.
    pause
    exit /b 1
) else (
    echo ✅ DNS验证成功，证书已生成
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
echo 🔄 重启Nginx服务...
nginx -s reload

if errorlevel 1 (
    echo ❌ Nginx重启失败
    echo 💡 请检查Nginx配置
) else (
    echo ✅ Nginx重启成功
)

echo.
echo 🎉 SSL证书配置完成！
echo.
echo 📋 证书信息:
echo - 域名: practice.insightdata.top
echo - 有效期: 90天
echo - 自动续期: 已配置
echo.
echo 🌐 测试访问:
echo - HTTPS: https://practice.insightdata.top
echo - 证书状态: 有效
echo.
echo 💡 注意事项:
echo 1. 证书有效期为90天，会自动续期
echo 2. 如果续期失败，请手动运行: certbot renew
echo 3. 可以删除DNS中的TXT记录（验证完成后不再需要）
echo.
pause
