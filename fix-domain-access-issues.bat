@echo off
chcp 65001 >nul
title 修复域名访问问题

echo 🔧 修复域名访问问题
echo ========================================
echo.

set DOMAIN=practice.insightdata.top
set IP=223.93.139.87

echo 📋 问题分析:
echo 域名: %DOMAIN%
echo IP地址: %IP%
echo 问题: 生产服务器能访问，其他电脑无法访问
echo.

echo 🎯 解决方案:
echo.

echo 方案1: 配置DNS服务器
echo ========================================
echo 1. 打开"网络和Internet设置"
echo 2. 点击"更改适配器选项"
echo 3. 右键点击网络连接 - 属性
echo 4. 选择"Internet协议版本4(TCP/IPv4)" - 属性
echo 5. 选择"使用下面的DNS服务器地址"
echo 6. 首选DNS服务器: 8.8.8.8
echo 7. 备用DNS服务器: 223.5.5.5
echo 8. 点击确定保存
echo.

echo 方案2: 修改hosts文件 (临时解决)
echo ========================================
echo 1. 以管理员身份运行记事本
echo 2. 打开文件: C:\Windows\System32\drivers\etc\hosts
echo 3. 在文件末尾添加:
echo    %IP% %DOMAIN%
echo 4. 保存文件
echo.

echo 是否要自动修改hosts文件? (Y/N)
set /p choice=
if /i "%choice%"=="Y" (
    echo 正在修改hosts文件...
    echo %IP% %DOMAIN% >> C:\Windows\System32\drivers\etc\hosts
    echo ✅ hosts文件已修改
    echo 现在可以测试: ping %DOMAIN%
) else (
    echo 跳过hosts文件修改
)
echo.

echo 方案3: 检查服务器配置
echo ========================================
echo 在服务器上需要检查:
echo 1. Nginx配置中的server_name
echo 2. SSL证书是否包含正确域名
echo 3. 防火墙是否允许443端口
echo 4. 域名DNS记录是否正确指向服务器IP
echo.

echo 方案4: 临时使用IP访问
echo ========================================
echo 如果域名暂时无法访问，可以临时修改配置使用IP:
echo 1. 修改 miniprogram/config/production.js
echo 2. 将 BASE_URL 改为: https://%IP%:443
echo 3. 或使用HTTP: http://%IP%:3002
echo.

echo 方案5: 检查域名解析
echo ========================================
echo 使用在线工具检查域名解析:
echo 1. https://www.whatsmydns.net/
echo 2. 输入域名: %DOMAIN%
echo 3. 选择记录类型: A
echo 4. 检查全球DNS解析是否一致
echo.

echo 🔍 验证修复效果:
echo ========================================
echo 修复后请测试:
echo 1. ping %DOMAIN%
echo 2. nslookup %DOMAIN%
echo 3. 浏览器访问: https://%DOMAIN%/
echo 4. 浏览器访问: https://%DOMAIN%/api/
echo.

echo 📞 如果问题仍然存在:
echo ========================================
echo 请联系域名服务商检查:
echo 1. DNS记录是否正确
echo 2. 域名是否已正确绑定到IP: %IP%
echo 3. 是否有CDN或代理服务干扰
echo.

echo 🎉 修复完成！
echo 按任意键退出...
pause >nul
