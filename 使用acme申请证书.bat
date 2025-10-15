@echo off
chcp 65001 >nul
echo ========================================
echo 使用acme.sh申请admin.practice.insightdata.top的SSL证书
echo ========================================

echo.
echo [1/6] 检查系统环境...

echo.
echo 检查curl...
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ curl未安装，请先安装curl
    echo 下载地址: https://curl.se/windows/
    pause
    exit /b 1
) else (
    echo ✅ curl已安装
)

echo.
echo 检查bash...
bash --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ bash未安装，请先安装Git for Windows
    echo 下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
) else (
    echo ✅ bash已安装
)

echo.
echo [2/6] 检查域名解析...
nslookup admin.practice.insightdata.top >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 域名解析失败，请确保admin.practice.insightdata.top指向本机IP
    echo 当前本机IP:
    ipconfig | findstr "IPv4"
    pause
    exit /b 1
) else (
    echo ✅ 域名解析正常
)

echo.
echo [3/6] 下载acme.sh脚本...
if not exist "acme.sh" (
    curl -o acme.sh https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh
    if %errorlevel% neq 0 (
        echo ❌ 下载acme.sh失败
        pause
        exit /b 1
    )
    echo ✅ acme.sh下载成功
) else (
    echo ✅ acme.sh已存在
)

echo.
echo [4/6] 设置执行权限...
icacls acme.sh /grant Everyone:F >nul 2>&1

echo.
echo [5/6] 申请SSL证书...
echo 使用standalone模式申请证书...
echo 注意: 申请过程中会临时使用80端口，请确保80端口可用

bash acme.sh --issue -d admin.practice.insightdata.top --standalone --email admin@practice.insightdata.top
if %errorlevel% neq 0 (
    echo ❌ 证书申请失败
    echo 请检查:
    echo 1. 域名是否正确解析到本机
    echo 2. 80端口是否可用
    echo 3. 防火墙是否阻止了80端口
    pause
    exit /b 1
)

echo.
echo [6/6] 安装证书到nginx目录...
bash acme.sh --install-cert -d admin.practice.insightdata.top --key-file "C:\certificates\admin.practice.insightdata.top.key" --fullchain-file "C:\certificates\admin.practice.insightdata.top.pem" --reloadcmd "C:\nginx\nginx.exe -s reload"
if %errorlevel% neq 0 (
    echo ❌ 证书安装失败
    pause
    exit /b 1
)

echo.
echo 重新加载nginx配置...
cd /d "C:\nginx"
nginx.exe -s reload

echo.
echo ========================================
echo 🎉 SSL证书申请完成！
echo ========================================
echo.
echo 📋 证书信息:
echo   - 域名: admin.practice.insightdata.top
echo   - 证书文件: C:\certificates\admin.practice.insightdata.top.pem
echo   - 私钥文件: C:\certificates\admin.practice.insightdata.top.key
echo.
echo 🔗 测试访问:
echo   https://admin.practice.insightdata.top:8443
echo.
echo 📝 注意事项:
echo   - 证书有效期为90天
echo   - acme.sh会自动设置续期任务
echo   - 证书已自动安装到nginx配置中
echo.
pause
