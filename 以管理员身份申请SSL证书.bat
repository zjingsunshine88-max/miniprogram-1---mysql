@echo off
chcp 65001 >nul
echo ========================================
echo 以管理员身份申请admin.practice.insightdata.top的SSL证书
echo ========================================

echo.
echo [1/6] 检查管理员权限...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 需要管理员权限，正在请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
) else (
    echo ✅ 已获得管理员权限
)

echo.
echo [2/6] 检查域名解析...
nslookup admin.practice.insightdata.top >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 域名解析失败，请确保admin.practice.insightdata.top指向本机IP
    pause
    exit /b 1
) else (
    echo ✅ 域名解析正常
)

echo.
echo [3/6] 停止nginx服务...
taskkill /f /im nginx.exe >nul 2>&1
echo ✅ nginx已停止

echo.
echo [4/6] 检查80端口...
netstat -an | find ":80 " >nul
if %errorlevel% neq 0 (
    echo ✅ 80端口可用
) else (
    echo ⚠️  80端口被占用，尝试释放...
    net stop w3svc >nul 2>&1
    net stop "World Wide Web Publishing Service" >nul 2>&1
    timeout /t 3 >nul
)

echo.
echo [5/6] 申请SSL证书...
echo 使用certbot申请证书...
"C:\Users\Administrator\AppData\Roaming\Python\Python313\Scripts\certbot.exe" certonly --standalone -d admin.practice.insightdata.top --email admin@practice.insightdata.top --agree-tos --non-interactive
if %errorlevel% neq 0 (
    echo ❌ 证书申请失败
    echo 请检查:
    echo 1. 域名是否正确解析到本机
    echo 2. 80端口是否可用
    echo 3. 防火墙是否阻止了80端口
    pause
    exit /b 1
) else (
    echo ✅ 证书申请成功
)

echo.
echo [6/6] 安装证书到nginx目录...
if not exist "C:\certificates" mkdir "C:\certificates"
copy "C:\Certbot\live\admin.practice.insightdata.top\fullchain.pem" "C:\certificates\admin.practice.insightdata.top.pem" >nul
copy "C:\Certbot\live\admin.practice.insightdata.top\privkey.pem" "C:\certificates\admin.practice.insightdata.top.key" >nul
echo ✅ 证书文件已复制

echo.
echo 更新nginx配置...
powershell -Command "(Get-Content 'C:\nginx\conf\admin.practice.insightdata.top.conf') -replace 'practice\.insightdata\.top\.pem', 'admin.practice.insightdata.top.pem' -replace 'practice\.insightdata\.top\.key', 'admin.practice.insightdata.top.key' | Set-Content 'C:\nginx\conf\admin.practice.insightdata.top.conf'"
echo ✅ nginx配置已更新

echo.
echo 启动nginx服务...
cd /d "C:\nginx"
start /b nginx.exe
timeout /t 3 >nul
echo ✅ nginx已启动

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
echo   - 建议设置自动续期
echo   - 证书已自动安装到nginx配置中
echo.
pause
