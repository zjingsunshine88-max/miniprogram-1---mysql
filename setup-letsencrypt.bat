@echo off
chcp 65001 >nul
title Let's Encrypt SSL证书配置

echo 🔐 Let's Encrypt SSL证书配置工具
echo.

echo 📋 配置步骤:
echo 1. 安装Python和pip
echo 2. 安装Certbot
echo 3. 生成SSL证书
echo 4. 更新Nginx配置
echo 5. 设置自动续期
echo.

echo 步骤1: 检查Python环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python未安装
    echo.
    echo 💡 请先安装Python:
    echo 1. 访问 https://www.python.org/downloads/
    echo 2. 下载Python 3.x版本
    echo 3. 安装时勾选 "Add Python to PATH"
    echo 4. 重新运行此脚本
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Python已安装
)

echo.
echo 步骤2: 检查pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip未安装
    echo 💡 请重新安装Python并确保包含pip
    pause
    exit /b 1
) else (
    echo ✅ pip已安装
)

echo.
echo 步骤3: 安装Certbot...
echo 正在安装certbot...
pip install certbot

if errorlevel 1 (
    echo ❌ Certbot安装失败
    echo 💡 请检查网络连接或使用管理员权限运行
    pause
    exit /b 1
) else (
    echo ✅ Certbot安装成功
)

echo.
echo 步骤4: 生成SSL证书...
echo.
echo ⚠️  重要提示:
echo 1. 确保域名 practice.insightdata.top 已解析到服务器IP
echo 2. 确保80端口可以访问（Let's Encrypt需要验证域名所有权）
echo 3. 确保防火墙允许80和443端口
echo.

set /p confirm="是否继续生成证书? (y/n): "
if /i not "%confirm%"=="y" (
    echo 操作已取消
    pause
    exit /b 0
)

echo.
echo 正在生成证书...
certbot certonly --standalone -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos --non-interactive

if errorlevel 1 (
    echo ❌ 证书生成失败
    echo.
    echo 💡 可能的原因:
    echo 1. 域名未正确解析到服务器IP
    echo 2. 80端口被占用或无法访问
    echo 3. 防火墙阻止了80端口
    echo 4. 域名验证失败
    echo.
    echo 🔧 解决方案:
    echo 1. 检查域名解析: nslookup practice.insightdata.top
    echo 2. 检查端口占用: netstat -ano | findstr :80
    echo 3. 临时停止Nginx: nginx -s stop
    echo 4. 重新运行证书生成
    echo.
    pause
    exit /b 1
) else (
    echo ✅ 证书生成成功
)

echo.
echo 步骤5: 复制证书到Nginx目录...
if not exist "C:\certificates" mkdir C:\certificates

copy "C:\Certbot\live\practice.insightdata.top\fullchain.pem" "C:\certificates\practice.insightdata.top.pem"
copy "C:\Certbot\live\practice.insightdata.top\privkey.pem" "C:\certificates\practice.insightdata.top.key"

if errorlevel 1 (
    echo ❌ 证书复制失败
    echo 💡 请手动复制证书文件
    echo 源路径: C:\Certbot\live\practice.insightdata.top\
    echo 目标路径: C:\certificates\
    pause
    exit /b 1
) else (
    echo ✅ 证书复制成功
)

echo.
echo 步骤6: 更新Nginx配置...
echo 正在重启Nginx...
nginx -s reload

if errorlevel 1 (
    echo ❌ Nginx重启失败
    echo 💡 请检查Nginx配置
    pause
    exit /b 1
) else (
    echo ✅ Nginx重启成功
)

echo.
echo 步骤7: 设置自动续期...
echo 创建自动续期任务...

echo @echo off > C:\certbot\renew.bat
echo certbot renew --quiet >> C:\certbot\renew.bat
echo nginx -s reload >> C:\certbot\renew.bat

echo 添加Windows计划任务...
schtasks /create /tn "Certbot Renewal" /tr "C:\certbot\renew.bat" /sc daily /st 02:00 /f

if errorlevel 1 (
    echo ⚠️  自动续期任务创建失败，请手动设置
) else (
    echo ✅ 自动续期任务创建成功
)

echo.
echo 🎉 Let's Encrypt SSL证书配置完成！
echo.
echo 📋 证书信息:
echo - 证书路径: C:\certificates\practice.insightdata.top.pem
echo - 私钥路径: C:\certificates\practice.insightdata.top.key
echo - 有效期: 90天（自动续期）
echo.
echo 🌐 测试访问:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
echo 💡 注意事项:
echo 1. 证书有效期为90天，会自动续期
echo 2. 如果续期失败，请手动运行: certbot renew
echo 3. 证书文件位置: C:\Certbot\live\practice.insightdata.top\
echo.
pause
