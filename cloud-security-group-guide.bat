@echo off
chcp 65001 >nul
title 云服务商安全组配置指南

echo 🌐 云服务商安全组配置指南
echo.

echo 📋 当前服务器信息:
echo - 服务器IP: 223.93.139.87
echo - 外部IP: 8.219.58.164
echo - 需要开放端口: 443 (HTTPS)
echo - 需要开放端口: 80 (HTTP重定向)
echo.

echo 🎯 问题原因:
echo ❌ 443端口在云服务商安全组中关闭
echo ❌ 外部无法访问HTTPS服务
echo ✅ 本地服务正常运行
echo.

echo 🔧 解决方案:
echo 需要在云服务商控制台配置安全组规则
echo.

echo ========================================
echo 阿里云ECS安全组配置
echo ========================================
echo.
echo 1. 登录阿里云控制台
echo 2. 进入ECS实例管理
echo 3. 找到实例: 223.93.139.87
echo 4. 点击"更多" -> "网络和安全组" -> "安全组配置"
echo 5. 添加入方向规则:
echo    - 端口范围: 443/443
echo    - 协议类型: TCP
echo    - 授权对象: 0.0.0.0/0
echo    - 描述: HTTPS服务
echo 6. 添加HTTP重定向规则:
echo    - 端口范围: 80/80
echo    - 协议类型: TCP
echo    - 授权对象: 0.0.0.0/0
echo    - 描述: HTTP重定向
echo 7. 保存规则
echo.

echo ========================================
echo 腾讯云CVM安全组配置
echo ========================================
echo.
echo 1. 登录腾讯云控制台
echo 2. 进入CVM实例管理
echo 3. 找到实例: 223.93.139.87
echo 4. 点击"更多" -> "安全组" -> "配置安全组"
echo 5. 添加入站规则:
echo    - 类型: 自定义
echo    - 协议端口: TCP:443
echo    - 来源: 0.0.0.0/0
echo    - 策略: 允许
echo 6. 添加HTTP重定向规则:
echo    - 类型: 自定义
echo    - 协议端口: TCP:80
echo    - 来源: 0.0.0.0/0
echo    - 策略: 允许
echo 7. 保存规则
echo.

echo ========================================
echo AWS EC2安全组配置
echo ========================================
echo.
echo 1. 登录AWS控制台
echo 2. 进入EC2实例管理
echo 3. 找到实例: 223.93.139.87
echo 4. 点击"Security Groups" -> "Edit inbound rules"
echo 5. 添加规则:
echo    - Type: Custom TCP
echo    - Port range: 443
echo    - Source: 0.0.0.0/0
echo    - Description: HTTPS service
echo 6. 添加HTTP重定向规则:
echo    - Type: Custom TCP
echo    - Port range: 80
echo    - Source: 0.0.0.0/0
echo    - Description: HTTP redirect
echo 7. 保存规则
echo.

echo ========================================
echo 华为云ECS安全组配置
echo ========================================
echo.
echo 1. 登录华为云控制台
echo 2. 进入ECS实例管理
echo 3. 找到实例: 223.93.139.87
echo 4. 点击"更多" -> "网络和安全组" -> "安全组"
echo 5. 添加入方向规则:
echo    - 端口: 443
echo    - 协议: TCP
echo    - 源地址: 0.0.0.0/0
echo    - 描述: HTTPS服务
echo 6. 添加HTTP重定向规则:
echo    - 端口: 80
echo    - 协议: TCP
echo    - 源地址: 0.0.0.0/0
echo    - 描述: HTTP重定向
echo 7. 保存规则
echo.

echo ========================================
echo 通用配置步骤
echo ========================================
echo.
echo 1. 登录云服务商控制台
echo 2. 找到ECS/CVM/EC2实例
echo 3. 进入安全组/防火墙设置
echo 4. 添加入站规则:
echo    - 端口: 443 (HTTPS)
echo    - 端口: 80 (HTTP重定向)
echo    - 协议: TCP
echo    - 源地址: 0.0.0.0/0 (允许所有IP)
echo 5. 保存并应用规则
echo 6. 等待规则生效 (通常1-5分钟)
echo.

echo ========================================
echo 验证端口开放
echo ========================================
echo.
echo 配置完成后，使用以下工具验证:
echo.
echo 1. 在线端口检查:
echo    - https://www.yougetsignal.com/tools/open-ports/
echo    - 输入服务器IP: 223.93.139.87
echo    - 输入端口: 443
echo    - 检查端口是否开放
echo.
echo 2. 命令行检查:
echo    - telnet 223.93.139.87 443
echo    - 如果连接成功，端口已开放
echo.
echo 3. 浏览器测试:
echo    - https://practice.insightdata.top/api/
echo    - 如果能够访问，配置成功
echo.

echo ========================================
echo 常见问题解决
echo ========================================
echo.
echo ❌ 问题1: 配置后仍然无法访问
echo 💡 解决: 等待5-10分钟让规则生效
echo.
echo ❌ 问题2: 端口检查显示关闭
echo 💡 解决: 检查安全组规则是否正确添加
echo.
echo ❌ 问题3: 本地可以访问，外网不行
echo 💡 解决: 检查云服务商安全组设置
echo.
echo ❌ 问题4: 防火墙阻止访问
echo 💡 解决: 运行 open-443-port-windows.bat
echo.

echo ========================================
echo 配置完成检查清单
echo ========================================
echo.
echo ✅ Windows防火墙已配置
echo ✅ 云服务商安全组已配置
echo ✅ 443端口规则已添加
echo ✅ 80端口规则已添加
echo ✅ 规则已保存并生效
echo ✅ 在线工具验证端口开放
echo ✅ 浏览器可以访问HTTPS
echo.

echo 🎉 配置完成后，HTTPS服务应该可以正常访问！
echo.
echo 📋 测试访问地址:
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo - 管理后台: https://practice.insightdata.top/
echo.
pause
