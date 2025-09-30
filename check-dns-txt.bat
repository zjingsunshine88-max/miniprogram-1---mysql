@echo off
chcp 65001 >nul
title DNS TXT记录检查工具

echo 🔍 DNS TXT记录检查工具
echo.

echo 📋 检查项目:
echo 1. 域名解析状态
echo 2. TXT记录验证
echo 3. DNS传播状态
echo.

echo ========================================
echo 1. 域名解析检查
echo ========================================
echo 检查 practice.insightdata.top 解析状态...
nslookup practice.insightdata.top
echo.

echo ========================================
echo 2. TXT记录检查
echo ========================================
echo 检查 _acme-challenge.practice.insightdata.top TXT记录...
nslookup -type=TXT _acme-challenge.practice.insightdata.top
echo.

echo ========================================
echo 3. 全球DNS传播检查
echo ========================================
echo 🌐 请使用以下在线工具检查全球DNS传播状态:
echo.
echo 1. DNS Checker: https://dnschecker.org/
echo    - 输入: _acme-challenge.practice.insightdata.top
echo    - 选择: TXT
echo    - 检查全球传播状态
echo.
echo 2. What's My DNS: https://www.whatsmydns.net/
echo    - 输入: _acme-challenge.practice.insightdata.top
echo    - 选择: TXT
echo    - 查看传播状态
echo.
echo 3. MXToolbox: https://mxtoolbox.com/TXTLookup.aspx
echo    - 输入: _acme-challenge.practice.insightdata.top
echo    - 查看TXT记录详情
echo.

echo ========================================
echo 4. 常见问题诊断
echo ========================================
echo.
echo ❌ 如果TXT记录显示为空:
echo 1. 检查DNS设置中的TXT记录是否正确添加
echo 2. 确保记录类型是TXT
echo 3. 确保主机记录是 _acme-challenge.practice
echo 4. 确保记录值完整（不要截断）
echo.
echo ❌ 如果TXT记录存在但验证失败:
echo 1. 等待DNS传播（通常需要5-30分钟）
echo 2. 使用在线工具检查全球传播状态
echo 3. 确保记录值完全正确
echo.
echo ❌ 如果域名解析失败:
echo 1. 检查域名是否正确解析到服务器IP
echo 2. 确保DNS设置正确
echo 3. 等待DNS传播
echo.

echo ========================================
echo 5. 手动验证步骤
echo ========================================
echo.
echo 📝 如果自动验证失败，请按以下步骤手动验证:
echo.
echo 1. 运行DNS验证命令:
echo    C:\Certbot\certbot.exe certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos
echo.
echo 2. 系统会提示您添加TXT记录，格式如下:
echo    记录类型: TXT
echo    主机记录: _acme-challenge.practice
echo    记录值: [系统提供的完整字符串]
echo.
echo 3. 在DNS管理面板中添加TXT记录
echo.
echo 4. 等待DNS传播（通常需要几分钟）
echo.
echo 5. 使用在线工具验证TXT记录是否生效
echo.
echo 6. 按回车继续验证
echo.

echo ========================================
echo 6. 解决方案建议
echo ========================================
echo.
echo 🎯 推荐解决方案:
echo.
echo 方案A: 使用DNS验证（推荐）
echo - 优点: 不需要开放80端口
echo - 缺点: 需要手动添加TXT记录
echo - 适用: 所有情况
echo.
echo 方案B: 修复网络配置
echo - 开放80端口防火墙规则
echo - 确保80端口可访问
echo - 重新尝试HTTP验证
echo.
echo 方案C: 使用其他证书服务
echo - 阿里云免费SSL证书
echo - 腾讯云免费SSL证书
echo - Cloudflare SSL证书
echo.

echo ========================================
echo 检查完成
echo ========================================
echo.
echo 💡 下一步操作建议:
echo 1. 如果TXT记录正确，尝试运行: simple-dns-ssl.bat
echo 2. 如果TXT记录有问题，请修复DNS设置
echo 3. 如果网络有问题，考虑使用其他证书服务
echo.
pause
