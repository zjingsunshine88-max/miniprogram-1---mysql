@echo off
chcp 65001 >nul
title HTTPS诊断工具

echo 🔍 HTTPS服务诊断工具
echo.

echo 📋 1. 检查服务状态:
echo.
tasklist | findstr nginx.exe >nul
if errorlevel 1 (
    echo ❌ Nginx未运行
) else (
    echo ✅ Nginx运行正常
)

tasklist | findstr node.exe >nul
if errorlevel 1 (
    echo ❌ Node.js服务未运行
) else (
    echo ✅ Node.js服务运行正常
)

echo.
echo 📋 2. 检查端口监听:
echo.
netstat -ano | findstr ":443" | findstr "LISTENING"
if errorlevel 1 (
    echo ❌ 443端口未监听
) else (
    echo ✅ 443端口正在监听
)

netstat -ano | findstr ":3002" | findstr "LISTENING"
if errorlevel 1 (
    echo ❌ 3002端口未监听
) else (
    echo ✅ 3002端口正在监听
)

echo.
echo 📋 3. 检查SSL证书:
echo.
if exist "C:\certificates\practice.insightdata.top.pem" (
    echo ✅ SSL证书文件存在
) else (
    echo ❌ SSL证书文件不存在
)

if exist "C:\certificates\practice.insightdata.top.key" (
    echo ✅ SSL私钥文件存在
) else (
    echo ❌ SSL私钥文件不存在
)

echo.
echo 📋 4. 检查admin静态文件:
echo.
if exist "C:\admin\dist\index.html" (
    echo ✅ Admin静态文件存在
) else (
    echo ❌ Admin静态文件不存在
)

echo.
echo 📋 5. 测试本地API访问:
echo.
curl -s http://localhost:3002/health >nul
if errorlevel 1 (
    echo ❌ 本地API访问失败
) else (
    echo ✅ 本地API访问正常
)

echo.
echo 📋 6. 测试域名解析:
echo.
nslookup practice.insightdata.top | findstr "223.93.139.87" >nul
if errorlevel 1 (
    echo ❌ 域名解析失败
) else (
    echo ✅ 域名解析正常
)

echo.
echo 📋 7. 测试HTTPS连接:
echo.
echo 尝试连接HTTPS...
curl -k -s -o nul -w "状态码: %%{http_code}\n" https://practice.insightdata.top/health
if errorlevel 1 (
    echo ❌ HTTPS连接失败
) else (
    echo ✅ HTTPS连接成功
)

echo.
echo 📋 8. 检查防火墙:
echo.
netsh advfirewall firewall show rule name="HTTPS" >nul
if errorlevel 1 (
    echo ⚠️  未找到HTTPS防火墙规则
) else (
    echo ✅ HTTPS防火墙规则存在
)

echo.
echo 📋 9. 检查Nginx配置:
echo.
type C:\nginx\conf\practice.insightdata.top.conf | findstr "server_name practice.insightdata.top" >nul
if errorlevel 1 (
    echo ❌ Nginx配置中未找到正确的server_name
) else (
    echo ✅ Nginx配置正确
)

echo.
echo 📋 10. 建议的解决方案:
echo.
echo 1. 如果HTTPS连接失败，请检查SSL证书是否有效
echo 2. 如果域名解析正常但无法访问，请检查防火墙设置
echo 3. 如果所有服务正常但无法访问，可能是SSL证书信任问题
echo 4. 尝试使用IP地址直接访问: https://223.93.139.87/
echo.
echo 💡 详细日志请查看: C:\nginx\logs\error.log
echo.
pause
