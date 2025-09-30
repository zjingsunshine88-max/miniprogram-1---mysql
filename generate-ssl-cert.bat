@echo off
chcp 65001 >nul
title 生成SSL证书

echo 🔐 生成Let's Encrypt SSL证书
echo.

echo ⚠️  需要管理员权限来生成SSL证书
echo 请以管理员身份运行此脚本
echo.

echo 📋 检查管理员权限...
net session >nul 2>&1
if errorlevel 1 (
    echo ❌ 需要管理员权限
    echo 💡 请右键点击此脚本，选择"以管理员身份运行"
    pause
    exit /b 1
) else (
    echo ✅ 管理员权限确认
)

echo.
echo 📋 停止Nginx服务...
cd /d C:\nginx
nginx.exe -s stop
timeout /t 2 >nul

echo.
echo 📋 生成SSL证书...
echo 域名: practice.insightdata.top
echo 邮箱: admin@practice.insightdata.top
echo.

"C:\Users\Administrator\AppData\Roaming\Python\Python313\Scripts\certbot.exe" certonly --standalone -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos --non-interactive

if errorlevel 1 (
    echo ❌ 证书生成失败
    echo.
    echo 💡 可能的原因:
    echo 1. 域名未正确解析到服务器IP
    echo 2. 80端口仍被占用
    echo 3. 网络连接问题
    echo 4. 防火墙阻止了连接
    echo.
    echo 🔧 故障排除:
    echo 1. 检查域名解析: nslookup practice.insightdata.top
    echo 2. 检查端口占用: netstat -ano | findstr :80
    echo 3. 检查网络连接: ping 8.8.8.8
    echo.
    echo 重启Nginx...
    nginx.exe
    pause
    exit /b 1
) else (
    echo ✅ 证书生成成功
)

echo.
echo 📋 复制证书文件...
if not exist "C:\certificates" mkdir C:\certificates

copy "C:\Certbot\live\practice.insightdata.top\fullchain.pem" "C:\certificates\practice.insightdata.top.pem"
copy "C:\Certbot\live\practice.insightdata.top\privkey.pem" "C:\certificates\practice.insightdata.top.key"

if errorlevel 1 (
    echo ❌ 证书复制失败
    echo 💡 请手动复制证书文件
    echo 源路径: C:\Certbot\live\practice.insightdata.top\
    echo 目标路径: C:\certificates\
    echo.
    echo 重启Nginx...
    nginx.exe
    pause
    exit /b 1
) else (
    echo ✅ 证书复制成功
)

echo.
echo 📋 重启Nginx服务...
nginx.exe

if errorlevel 1 (
    echo ❌ Nginx启动失败
    echo 💡 请检查Nginx配置
    pause
    exit /b 1
) else (
    echo ✅ Nginx启动成功
)

echo.
echo 📋 设置自动续期...
echo 创建续期脚本...

echo @echo off > C:\certbot\renew.bat
echo "C:\Users\Administrator\AppData\Roaming\Python\Python313\Scripts\certbot.exe" renew --quiet >> C:\certbot\renew.bat
echo cd /d C:\nginx >> C:\certbot\renew.bat
echo nginx.exe -s reload >> C:\certbot\renew.bat

echo 添加Windows计划任务...
schtasks /create /tn "Certbot Renewal" /tr "C:\certbot\renew.bat" /sc daily /st 02:00 /f

if errorlevel 1 (
    echo ⚠️  自动续期任务创建失败，请手动设置
) else (
    echo ✅ 自动续期任务创建成功
)

echo.
echo 🎉 SSL证书生成完成！
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
echo 按任意键退出...
pause >nul