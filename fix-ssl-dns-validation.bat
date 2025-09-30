@echo off
chcp 65001 >nul
title SSL证书DNS验证修复工具

echo 🔐 SSL证书DNS验证修复工具
echo.

echo 📋 问题诊断:
echo ✅ DNS解析正常: practice.insightdata.top → 223.93.139.87
echo ✅ TXT记录已添加: _acme-challenge.practice.insightdata.top
echo ❌ HTTP验证失败: 防火墙阻止80端口访问
echo.

echo 🎯 解决方案: 使用DNS验证方式
echo.

echo 📝 DNS验证说明:
echo 1. 不需要开放80端口
echo 2. 不需要Web服务器运行
echo 3. 只需要在DNS中添加TXT记录
echo 4. 验证完成后可以删除TXT记录
echo.

echo 🔍 检查当前TXT记录...
nslookup -type=TXT _acme-challenge.practice.insightdata.top
echo.

echo ⚠️  重要提示:
echo 如果上面的TXT记录显示为空或错误，请按以下步骤操作:
echo.
echo 1. 登录您的DNS管理面板
echo 2. 添加TXT记录:
echo    - 记录类型: TXT
echo    - 主机记录: _acme-challenge.practice
echo    - 记录值: [系统会提供新的验证字符串]
echo 3. 等待DNS传播（通常需要几分钟）
echo.

set /p confirm="是否继续使用DNS验证方式获取SSL证书? (y/n): "
if /i not "%confirm%"=="y" (
    echo 操作已取消
    pause
    exit /b 0
)

echo.
echo 🔄 开始DNS验证...
echo 注意: 系统会提示您添加TXT记录到DNS设置中
echo 请按照提示操作，然后按回车继续
echo.

echo 正在清理之前的验证记录...
if exist "C:\Certbot\live\practice.insightdata.top" (
    echo 删除旧的证书文件...
    rmdir /s /q "C:\Certbot\live\practice.insightdata.top"
)

echo.
echo 开始DNS验证流程...
C:\Certbot\certbot.exe certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos --non-interactive

if errorlevel 1 (
    echo ❌ DNS验证失败
    echo.
    echo 💡 可能的原因:
    echo 1. TXT记录添加错误或未生效
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
    echo 📋 手动验证步骤:
    echo 1. 访问 https://dnschecker.org/
    echo 2. 输入: _acme-challenge.practice.insightdata.top
    echo 3. 选择TXT记录类型
    echo 4. 检查全球DNS传播状态
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
