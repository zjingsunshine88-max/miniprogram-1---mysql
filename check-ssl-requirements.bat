@echo off
chcp 65001 >nul
title SSL证书环境检查

echo 🔍 SSL证书环境检查工具
echo.

echo 📋 检查Let's Encrypt证书生成条件...
echo.

echo 1. 检查域名解析...
nslookup practice.insightdata.top | findstr "223.93.139.87" >nul
if errorlevel 1 (
    echo ❌ 域名解析失败
    echo 💡 请确保 practice.insightdata.top 解析到 223.93.139.87
) else (
    echo ✅ 域名解析正常
)

echo.
echo 2. 检查80端口...
netstat -ano | findstr ":80" | findstr "LISTENING" >nul
if errorlevel 1 (
    echo ✅ 80端口可用
) else (
    echo ⚠️  80端口被占用
    echo 💡 生成证书时需要临时停止占用80端口的服务
)

echo.
echo 3. 检查443端口...
netstat -ano | findstr ":443" | findstr "LISTENING" >nul
if errorlevel 1 (
    echo ✅ 443端口可用
) else (
    echo ⚠️  443端口被占用
    echo 💡 这不会影响证书生成，但可能影响HTTPS访问
)

echo.
echo 4. 检查Python环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python未安装
    echo 💡 需要安装Python来使用Certbot
) else (
    echo ✅ Python已安装
    python --version
)

echo.
echo 5. 检查pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip未安装
    echo 💡 需要pip来安装Certbot
) else (
    echo ✅ pip已安装
)

echo.
echo 6. 检查网络连接...
ping -n 1 8.8.8.8 >nul
if errorlevel 1 (
    echo ❌ 网络连接失败
    echo 💡 需要网络连接来验证域名和生成证书
) else (
    echo ✅ 网络连接正常
)

echo.
echo 7. 检查防火墙...
netsh advfirewall firewall show rule name="HTTP" >nul
if errorlevel 1 (
    echo ⚠️  未找到HTTP防火墙规则
    echo 💡 请确保防火墙允许80和443端口
) else (
    echo ✅ HTTP防火墙规则存在
)

echo.
echo 📋 总结和建议:
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 无法使用Certbot（需要Python）
    echo 💡 建议使用在线工具生成证书
    echo    1. 访问 https://www.sslforfree.com/
    echo    2. 输入域名: practice.insightdata.top
    echo    3. 选择手动验证
    echo    4. 下载证书文件
) else (
    echo ✅ 可以使用Certbot生成证书
    echo 💡 运行 setup-letsencrypt.bat 开始配置
)

echo.
echo 🌐 当前可用的访问方式:
echo - HTTP: http://practice.insightdata.top/
echo - 本地API: http://localhost:3002/health
echo.
echo 按任意键退出...
pause >nul
