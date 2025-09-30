@echo off
chcp 65001 >nul
title 手动SSL证书配置

echo 🔐 手动SSL证书配置工具
echo.

echo 📋 由于Python环境问题，我们使用在线工具生成证书
echo.

echo 🌐 步骤1: 访问在线证书生成工具
echo.
echo 请打开浏览器访问以下网址:
echo https://www.sslforfree.com/
echo.
echo 输入域名: practice.insightdata.top
echo 选择验证方式: Manual Verification
echo.

pause

echo.
echo 📋 步骤2: 域名验证
echo.
echo 1. 下载验证文件
echo 2. 将验证文件放到以下目录:
echo    C:\nginx\html\.well-known\acme-challenge\
echo.

echo 创建验证目录...
if not exist "C:\nginx\html\.well-known\acme-challenge" (
    mkdir "C:\nginx\html\.well-known\acme-challenge"
    echo ✅ 验证目录已创建
) else (
    echo ✅ 验证目录已存在
)

echo.
echo 📋 步骤3: 配置Nginx支持验证
echo.
echo 正在更新Nginx配置以支持域名验证...

REM 创建临时的HTTP配置用于验证
echo # 临时HTTP配置用于SSL验证 > C:\nginx\conf\ssl-verify.conf
echo server { >> C:\nginx\conf\ssl-verify.conf
echo     listen 80; >> C:\nginx\conf\ssl-verify.conf
echo     server_name practice.insightdata.top; >> C:\nginx\conf\ssl-verify.conf
echo. >> C:\nginx\conf\ssl-verify.conf
echo     # SSL验证路径 >> C:\nginx\conf\ssl-verify.conf
echo     location /.well-known/acme-challenge/ { >> C:\nginx\conf\ssl-verify.conf
echo         root C:/nginx/html; >> C:\nginx\conf\ssl-verify.conf
echo     } >> C:\nginx\conf\ssl-verify.conf
echo. >> C:\nginx\conf\ssl-verify.conf
echo     # 其他请求重定向到HTTPS >> C:\nginx\conf\ssl-verify.conf
echo     location / { >> C:\nginx\conf\ssl-verify.conf
echo         return 301 https://$server_name$request_uri; >> C:\nginx\conf\ssl-verify.conf
echo     } >> C:\nginx\conf\ssl-verify.conf
echo } >> C:\nginx\conf\ssl-verify.conf

echo ✅ Nginx验证配置已创建

echo.
echo 📋 步骤4: 重启Nginx
echo.
nginx -s reload
if errorlevel 1 (
    echo ❌ Nginx重启失败
    pause
    exit /b 1
) else (
    echo ✅ Nginx重启成功
)

echo.
echo 📋 步骤5: 测试验证路径
echo.
echo 请确保可以通过以下URL访问验证文件:
echo http://practice.insightdata.top/.well-known/acme-challenge/
echo.

echo 按任意键继续验证过程...
pause

echo.
echo 📋 步骤6: 下载证书文件
echo.
echo 验证成功后，请下载以下文件:
echo 1. Certificate (证书文件)
echo 2. Private Key (私钥文件)
echo.
echo 将证书文件保存为: C:\certificates\practice.insightdata.top.pem
echo 将私钥文件保存为: C:\certificates\practice.insightdata.top.key
echo.

echo 创建证书目录...
if not exist "C:\certificates" mkdir C:\certificates

echo.
echo 📋 步骤7: 测试证书文件
echo.
if exist "C:\certificates\practice.insightdata.top.pem" (
    echo ✅ 证书文件存在
) else (
    echo ❌ 证书文件不存在，请先下载证书
)

if exist "C:\certificates\practice.insightdata.top.key" (
    echo ✅ 私钥文件存在
) else (
    echo ❌ 私钥文件不存在，请先下载私钥
)

echo.
echo 📋 步骤8: 重启Nginx使用新证书
echo.
if exist "C:\certificates\practice.insightdata.top.pem" (
    echo 重启Nginx使用新证书...
    nginx -s reload
    if errorlevel 1 (
        echo ❌ Nginx重启失败
    ) else (
        echo ✅ Nginx重启成功
    )
) else (
    echo ⚠️  请先完成证书下载
)

echo.
echo 🎉 SSL证书配置完成！
echo.
echo 📋 测试访问:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
echo 💡 注意事项:
echo 1. 证书有效期为90天
echo 2. 到期前需要手动续期
echo 3. 建议设置提醒续期
echo.
echo 按任意键退出...
pause >nul
