@echo off
chcp 65001 >nul
title 路由器端口转发配置指南

echo 🏠 路由器端口转发配置指南
echo.

echo 📋 配置信息:
echo - 服务器IP: 223.93.139.87
echo - 外部端口: 443 (HTTPS)
echo - 外部端口: 80 (HTTP)
echo - 内部端口: 443 (HTTPS)
echo - 内部端口: 80 (HTTP)
echo - 协议: TCP
echo.

echo 🎯 配置目标:
echo 将外部访问的443和80端口转发到内部服务器
echo.

echo ========================================
echo 通用配置步骤
echo ========================================
echo.

echo 步骤1: 登录路由器管理界面
echo.
echo 1. 打开浏览器
echo 2. 输入路由器IP地址:
echo    - 常见地址: http://192.168.1.1
echo    - 常见地址: http://192.168.0.1
echo    - 常见地址: http://192.168.3.1
echo    - 常见地址: http://10.0.0.1
echo 3. 输入管理员用户名和密码
echo 4. 如果不知道密码，查看路由器背面标签
echo.

echo 步骤2: 找到端口转发设置
echo.
echo 不同路由器界面不同，常见位置:
echo - "高级设置" -> "端口转发"
echo - "网络设置" -> "端口映射"
echo - "虚拟服务器" -> "端口转发"
echo - "NAT" -> "端口转发"
echo - "防火墙" -> "端口转发"
echo - "安全设置" -> "端口转发"
echo.

echo 步骤3: 添加端口转发规则
echo.
echo 规则1 (HTTPS服务):
echo - 外部端口: 443
echo - 内部端口: 443
echo - 内部IP: 223.93.139.87
echo - 协议: TCP
echo - 描述: HTTPS服务
echo - 状态: 启用
echo.
echo 规则2 (HTTP重定向):
echo - 外部端口: 80
echo - 内部端口: 80
echo - 内部IP: 223.93.139.87
echo - 协议: TCP
echo - 描述: HTTP重定向
echo - 状态: 启用
echo.

echo 步骤4: 保存并应用设置
echo 1. 点击"保存"或"应用"按钮
echo 2. 等待配置生效
echo 3. 重启路由器（推荐）
echo.

echo ========================================
echo 常见路由器品牌配置
echo ========================================
echo.

echo 🏠 TP-Link路由器配置:
echo.
echo 1. 登录: http://192.168.1.1
echo 2. 用户名: admin
echo 3. 密码: admin (或查看路由器标签)
echo 4. 路径: 高级功能 -> 虚拟服务器
echo 5. 点击"添加"按钮
echo 6. 填写信息:
echo    - 服务名称: HTTPS
echo    - 外部端口: 443
echo    - 内部端口: 443
echo    - 内部IP: 223.93.139.87
echo    - 协议: TCP
echo 7. 保存设置
echo 8. 重复步骤添加HTTP规则 (端口80)
echo.

echo 🏠 小米路由器配置:
echo.
echo 1. 登录: http://miwifi.com
echo 2. 输入管理员密码
echo 3. 路径: 高级设置 -> 端口转发
echo 4. 点击"添加规则"
echo 5. 填写信息:
echo    - 规则名称: HTTPS
echo    - 外部端口: 443
echo    - 内部端口: 443
echo    - 内部IP: 223.93.139.87
echo    - 协议: TCP
echo 6. 保存设置
echo 7. 重复步骤添加HTTP规则 (端口80)
echo.

echo 🏠 华为路由器配置:
echo.
echo 1. 登录: http://192.168.3.1
echo 2. 输入管理员密码
echo 3. 路径: 更多功能 -> 安全设置 -> 端口转发
echo 4. 点击"添加"
echo 5. 填写信息:
echo    - 规则名称: HTTPS
echo    - 外部端口: 443
echo    - 内部端口: 443
echo    - 内部IP: 223.93.139.87
echo    - 协议: TCP
echo 6. 保存设置
echo 7. 重复步骤添加HTTP规则 (端口80)
echo.

echo 🏠 华硕路由器配置:
echo.
echo 1. 登录: http://192.168.1.1
echo 2. 用户名: admin
echo 3. 密码: admin (或查看路由器标签)
echo 4. 路径: 高级设置 -> 端口转发
echo 5. 点击"添加规则"
echo 6. 填写信息:
echo    - 规则名称: HTTPS
echo    - 外部端口: 443
echo    - 内部端口: 443
echo    - 内部IP: 223.93.139.87
echo    - 协议: TCP
echo 7. 保存设置
echo 8. 重复步骤添加HTTP规则 (端口80)
echo.

echo 🏠 网件路由器配置:
echo.
echo 1. 登录: http://192.168.1.1
echo 2. 用户名: admin
echo 3. 密码: password (或查看路由器标签)
echo 4. 路径: 高级 -> 端口转发
echo 5. 点击"添加规则"
echo 6. 填写信息:
echo    - 规则名称: HTTPS
echo    - 外部端口: 443
echo    - 内部端口: 443
echo    - 内部IP: 223.93.139.87
echo    - 协议: TCP
echo 7. 保存设置
echo 8. 重复步骤添加HTTP规则 (端口80)
echo.

echo ========================================
echo 配置验证
echo ========================================
echo.

echo 🔍 配置完成后验证步骤:
echo.
echo 1. 检查路由器配置:
echo    - 登录路由器管理界面
echo    - 确认端口转发规则已添加
echo    - 确认规则状态为"启用"
echo.
echo 2. 检查Windows防火墙:
echo    - 运行: netsh advfirewall firewall show rule name="HTTPS-Inbound"
echo    - 确保规则存在且状态为"启用"
echo.
echo 3. 检查端口监听:
echo    - 运行: netstat -an | findstr :443
echo    - 确保443端口正在监听
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
echo 常见问题解决
echo ========================================
echo.

echo ❌ 问题1: 无法访问路由器管理界面
echo 💡 解决: 检查路由器IP地址，尝试常见地址
echo.
echo ❌ 问题2: 忘记路由器密码
echo 💡 解决: 查看路由器背面标签，或重置路由器
echo.
echo ❌ 问题3: 找不到端口转发设置
echo 💡 解决: 查看路由器说明书，或联系厂商客服
echo.
echo ❌ 问题4: 配置后仍然无法访问
echo 💡 解决: 等待5-10分钟让配置生效，重启路由器
echo.
echo ❌ 问题5: 外部IP地址变化
echo 💡 解决: 使用动态DNS服务或固定IP
echo.

echo ========================================
echo 配置完成检查清单
echo ========================================
echo.

echo ✅ 路由器端口转发已配置
echo ✅ 443端口转发规则已添加
echo ✅ 80端口转发规则已添加
echo ✅ Windows防火墙已配置
echo ✅ 443端口入站规则已添加
echo ✅ 80端口入站规则已添加
echo ✅ Nginx服务正在运行
echo ✅ 443端口正在监听
echo ✅ 在线工具验证端口开放
echo ✅ 浏览器可以访问HTTPS
echo.

echo 🎉 路由器端口转发配置完成！
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
