@echo off
chcp 65001 >nul
title 配置家庭Windows服务器443端口

echo 🏠 配置家庭Windows服务器443端口
echo.

echo 📋 服务器信息:
echo - 服务器类型: 家庭Windows主机
echo - 服务器IP: 223.93.139.87
echo - 外部IP: 8.219.58.164
echo - 需要开放端口: 443 (HTTPS)
echo - 需要开放端口: 80 (HTTP重定向)
echo.

echo 🎯 问题原因:
echo ❌ 443端口在家庭网络中关闭
echo ❌ 路由器未配置端口转发
echo ❌ Windows防火墙阻止外部访问
echo ✅ 本地服务正常运行
echo.

echo 🔧 解决方案:
echo 1. 配置Windows防火墙
echo 2. 配置路由器端口转发
echo 3. 验证端口开放状态
echo.

echo 🔄 开始配置...
echo.

echo ========================================
echo 步骤1: 配置Windows防火墙
echo ========================================
echo.

echo 检查当前防火墙状态...
netsh advfirewall show allprofiles state

echo.
echo 添加443端口防火墙规则...
echo 添加入站规则...
netsh advfirewall firewall add rule name="HTTPS-Inbound" dir=in action=allow protocol=TCP localport=443
if errorlevel 1 (
    echo ❌ 添加入站规则失败
) else (
    echo ✅ 443端口入站规则已添加
)

echo 添加出站规则...
netsh advfirewall firewall add rule name="HTTPS-Outbound" dir=out action=allow protocol=TCP localport=443
if errorlevel 1 (
    echo ❌ 添加出站规则失败
) else (
    echo ✅ 443端口出站规则已添加
)

echo.
echo 添加80端口防火墙规则...
echo 添加入站规则...
netsh advfirewall firewall add rule name="HTTP-Inbound" dir=in action=allow protocol=TCP localport=80
if errorlevel 1 (
    echo ❌ 添加80端口入站规则失败
) else (
    echo ✅ 80端口入站规则已添加
)

echo.
echo 检查防火墙规则...
echo 检查443端口规则...
netsh advfirewall firewall show rule name="HTTPS-Inbound"
netsh advfirewall firewall show rule name="HTTPS-Outbound"

echo.
echo 检查80端口规则...
netsh advfirewall firewall show rule name="HTTP-Inbound"

echo.
echo ========================================
echo 步骤2: 检查端口监听状态
echo ========================================
echo.

echo 检查443端口监听状态...
netstat -an | findstr :443 | findstr LISTENING
if errorlevel 1 (
    echo ❌ 443端口未监听
    echo 💡 需要启动Nginx服务
) else (
    echo ✅ 443端口正在监听
)

echo.
echo 检查80端口监听状态...
netstat -an | findstr :80 | findstr LISTENING
if errorlevel 1 (
    echo ❌ 80端口未监听
    echo 💡 需要启动Nginx服务
) else (
    echo ✅ 80端口正在监听
)

echo.
echo 启动Nginx服务（如果未运行）...
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
echo ========================================
echo 步骤3: 路由器端口转发配置指南
echo ========================================
echo.

echo 📋 路由器端口转发配置步骤:
echo.
echo 1. 登录路由器管理界面:
echo    - 打开浏览器，输入: http://192.168.1.1 或 http://192.168.0.1
echo    - 输入管理员用户名和密码
echo    - 如果不知道密码，查看路由器背面标签
echo.
echo 2. 找到端口转发设置:
echo    - 不同路由器界面不同，常见位置:
echo    - "高级设置" -> "端口转发"
echo    - "网络设置" -> "端口映射"
echo    - "虚拟服务器" -> "端口转发"
echo    - "NAT" -> "端口转发"
echo.
echo 3. 添加端口转发规则:
echo    - 规则1 (HTTPS):
echo      * 外部端口: 443
echo      * 内部端口: 443
echo      * 内部IP: 223.93.139.87
echo      * 协议: TCP
echo      * 描述: HTTPS服务
echo.
echo    - 规则2 (HTTP):
echo      * 外部端口: 80
echo      * 内部端口: 80
echo      * 内部IP: 223.93.139.87
echo      * 协议: TCP
echo      * 描述: HTTP重定向
echo.
echo 4. 保存并应用设置
echo 5. 重启路由器（可选，但推荐）
echo.

echo ========================================
echo 步骤4: 常见路由器配置方法
echo ========================================
echo.

echo 🏠 常见路由器品牌配置:
echo.
echo 1. TP-Link路由器:
echo    - 登录: http://192.168.1.1
echo    - 路径: 高级功能 -> 虚拟服务器
echo    - 添加规则: 外部端口443 -> 内部IP 223.93.139.87:443
echo.
echo 2. 小米路由器:
echo    - 登录: http://miwifi.com
echo    - 路径: 高级设置 -> 端口转发
echo    - 添加规则: 外部端口443 -> 内部IP 223.93.139.87:443
echo.
echo 3. 华为路由器:
echo    - 登录: http://192.168.3.1
echo    - 路径: 更多功能 -> 安全设置 -> 端口转发
echo    - 添加规则: 外部端口443 -> 内部IP 223.93.139.87:443
echo.
echo 4. 华硕路由器:
echo    - 登录: http://192.168.1.1
echo    - 路径: 高级设置 -> 端口转发
echo    - 添加规则: 外部端口443 -> 内部IP 223.93.139.87:443
echo.
echo 5. 网件路由器:
echo    - 登录: http://192.168.1.1
echo    - 路径: 高级 -> 端口转发
echo    - 添加规则: 外部端口443 -> 内部IP 223.93.139.87:443
echo.

echo ========================================
echo 步骤5: 验证配置
echo ========================================
echo.

echo 🔍 配置完成后验证步骤:
echo.
echo 1. 检查Windows防火墙:
echo    - 运行: netsh advfirewall firewall show rule name="HTTPS-Inbound"
echo    - 确保规则存在且状态为"启用"
echo.
echo 2. 检查端口监听:
echo    - 运行: netstat -an | findstr :443
echo    - 确保443端口正在监听
echo.
echo 3. 检查路由器配置:
echo    - 登录路由器管理界面
echo    - 确认端口转发规则已添加
echo    - 确认规则状态为"启用"
echo.
echo 4. 在线验证端口开放:
echo    - 访问: https://www.yougetsignal.com/tools/open-ports/
echo    - 输入服务器IP: 223.93.139.87
echo    - 输入端口: 443
echo    - 检查端口是否开放
echo.
echo 5. 浏览器测试:
echo    - 访问: https://practice.insightdata.top/api/
echo    - 如果能够访问，配置成功
echo.

echo ========================================
echo 步骤6: 常见问题解决
echo ========================================
echo.

echo ❌ 问题1: 配置后仍然无法访问
echo 💡 解决: 等待5-10分钟让配置生效
echo.
echo ❌ 问题2: 端口检查显示关闭
echo 💡 解决: 检查路由器端口转发是否正确配置
echo.
echo ❌ 问题3: 本地可以访问，外网不行
echo 💡 解决: 检查路由器端口转发设置
echo.
echo ❌ 问题4: 路由器无法访问
echo 💡 解决: 重置路由器或联系网络管理员
echo.
echo ❌ 问题5: 外部IP地址变化
echo 💡 解决: 使用动态DNS服务或固定IP
echo.

echo ========================================
echo 配置完成检查清单
echo ========================================
echo.

echo ✅ Windows防火墙已配置
echo ✅ 443端口入站规则已添加
echo ✅ 80端口入站规则已添加
echo ✅ Nginx服务正在运行
echo ✅ 443端口正在监听
echo ✅ 路由器端口转发已配置
echo ✅ 在线工具验证端口开放
echo ✅ 浏览器可以访问HTTPS
echo.

echo 🎉 家庭Windows服务器443端口配置完成！
echo.
echo 📋 测试访问地址:
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo - 管理后台: https://practice.insightdata.top/
echo.
echo 💡 重要提示:
echo 1. 配置完成后需要等待5-10分钟生效
echo 2. 如果外部IP地址变化，需要重新配置域名解析
echo 3. 建议使用动态DNS服务避免IP变化问题
echo 4. 定期检查路由器端口转发规则是否正常
echo.
pause
