@echo off
chcp 65001 >nul
echo ========================================
echo 测试admin.practice.insightdata.top:8443部署
echo ========================================

echo.
echo [1/5] 检查nginx进程...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul
if %errorlevel% neq 0 (
    echo ❌ nginx进程未运行
    echo 请先启动nginx服务
    pause
    exit /b 1
)
echo ✅ nginx进程正在运行

echo.
echo [2/5] 检查8443端口监听...
netstat -an | find ":8443" >nul
if %errorlevel% neq 0 (
    echo ❌ 8443端口未监听
    pause
    exit /b 1
)
echo ✅ 8443端口正在监听

echo.
echo [3/5] 检查SSL证书...
if not exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo ❌ SSL证书文件不存在
    pause
    exit /b 1
)
if not exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo ❌ SSL私钥文件不存在
    pause
    exit /b 1
)
echo ✅ SSL证书文件存在

echo.
echo [4/5] 检查admin静态文件...
if not exist "C:\admin\dist\index.html" (
    echo ❌ admin静态文件不存在
    pause
    exit /b 1
)
echo ✅ admin静态文件存在

echo.
echo [5/5] 测试本地访问...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://localhost:8443/' -UseBasicParsing -TimeoutSec 10; Write-Host '✅ 本地访问成功 - HTTP状态码:' $response.StatusCode } catch { Write-Host '❌ 本地访问失败:' $_.Exception.Message }"

echo.
echo ========================================
echo 📋 部署状态总结
echo ========================================
echo.
echo 🟢 服务状态:
echo   - nginx: 运行中
echo   - 8443端口: 监听中
echo   - SSL证书: 存在
echo   - admin文件: 存在
echo.
echo 🟡 注意事项:
echo   - 当前使用practice.insightdata.top的证书
echo   - 浏览器可能会显示安全警告
echo   - 点击"高级" -> "继续访问"即可正常使用
echo.
echo 🔗 访问地址:
echo   - 本地测试: https://localhost:8443
echo   - 域名访问: https://admin.practice.insightdata.top:8443
echo.
echo 📝 下一步操作:
echo   1. 确保DNS解析 admin.practice.insightdata.top 指向本机IP
echo   2. 确保防火墙开放8443端口
echo   3. 考虑申请专用的SSL证书
echo.
pause
