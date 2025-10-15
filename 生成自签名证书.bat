@echo off
chcp 65001 >nul
echo ========================================
echo 生成admin.practice.insightdata.top的自签名证书
echo ========================================

echo.
echo [1/4] 检查openssl...
openssl version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ openssl未安装，请先安装openssl
    echo 下载地址: https://slproweb.com/products/Win32OpenSSL.html
    pause
    exit /b 1
) else (
    echo ✅ openssl已安装
    openssl version
)

echo.
echo [2/4] 创建证书目录...
if not exist "C:\certificates" mkdir "C:\certificates"
echo ✅ 证书目录已创建

echo.
echo [3/4] 生成私钥...
openssl genrsa -out C:\certificates\admin.practice.insightdata.top.key 2048
if %errorlevel% neq 0 (
    echo ❌ 私钥生成失败
    pause
    exit /b 1
) else (
    echo ✅ 私钥生成成功
)

echo.
echo [4/4] 生成自签名证书...
openssl req -new -x509 -key C:\certificates\admin.practice.insightdata.top.key -out C:\certificates\admin.practice.insightdata.top.pem -days 365 -subj "/CN=admin.practice.insightdata.top"
if %errorlevel% neq 0 (
    echo ❌ 证书生成失败
    pause
    exit /b 1
) else (
    echo ✅ 证书生成成功
)

echo.
echo 重新加载nginx配置...
cd /d "C:\nginx"
nginx.exe -s reload

echo.
echo ========================================
echo 🎉 自签名证书生成完成！
echo ========================================
echo.
echo 📋 证书信息:
echo   - 域名: admin.practice.insightdata.top
echo   - 证书文件: C:\certificates\admin.practice.insightdata.top.pem
echo   - 私钥文件: C:\certificates\admin.practice.insightdata.top.key
echo   - 有效期: 365天
echo.
echo 🔗 测试访问:
echo   https://admin.practice.insightdata.top:8443
echo.
echo ⚠️  注意事项:
echo   - 这是自签名证书，浏览器会显示安全警告
echo   - 仅用于测试，生产环境请使用正式证书
echo   - 点击"高级" -> "继续访问"即可正常使用
echo.
pause
