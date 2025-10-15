@echo off
chcp 65001 >nul
echo ========================================
echo 手动申请admin.practice.insightdata.top的SSL证书
echo ========================================

echo.
echo 由于certbot需要管理员权限，我们使用手动方式申请证书。
echo.

echo [1/4] 创建验证目录...
if not exist "C:\nginx\html\.well-known\acme-challenge" (
    mkdir "C:\nginx\html\.well-known\acme-challenge"
)
echo ✅ 验证目录已创建

echo.
echo [2/4] 启动临时HTTP服务器...
echo 启动Python HTTP服务器在80端口...
start /b python -m http.server 80 --directory C:\nginx\html
timeout /t 3 >nul
echo ✅ 临时HTTP服务器已启动

echo.
echo [3/4] 手动申请证书...
echo 请按照以下步骤操作:
echo.
echo 1. 打开浏览器访问: https://www.sslforfree.com/
echo 2. 输入域名: admin.practice.insightdata.top
echo 3. 点击 "Create Free SSL Certificate"
echo 4. 选择 "Manual Verification"
echo 5. 下载验证文件到: C:\nginx\html\.well-known\acme-challenge\
echo 6. 完成验证后下载证书文件
echo.
echo 验证文件示例:
echo   - 文件名: 类似 "abc123def456"
echo   - 内容: 类似 "abc123def456.abc123def456"
echo.
echo 请将验证文件保存到: C:\nginx\html\.well-known\acme-challenge\
echo.

echo 是否已完成验证文件下载? (y/n)
set /p choice1=请选择: 
if /i "%choice1%"=="y" (
    echo ✅ 验证文件已下载
) else (
    echo 请先完成验证文件下载
    pause
    exit /b 1
)

echo.
echo 是否已完成证书申请? (y/n)
set /p choice2=请选择: 
if /i "%choice2%"=="y" (
    echo ✅ 证书申请已完成
) else (
    echo 请先完成证书申请
    pause
    exit /b 1
)

echo.
echo [4/4] 安装证书...
echo 请将证书文件放置到以下位置:
echo   - 证书文件: C:\certificates\admin.practice.insightdata.top.pem
echo   - 私钥文件: C:\certificates\admin.practice.insightdata.top.key
echo.

if not exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo ❌ 证书文件不存在: C:\certificates\admin.practice.insightdata.top.pem
    echo 请确保已正确下载并重命名证书文件
    pause
    exit /b 1
)

if not exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo ❌ 私钥文件不存在: C:\certificates\admin.practice.insightdata.top.key
    echo 请确保已正确下载并重命名私钥文件
    pause
    exit /b 1
)

echo ✅ 证书文件已存在

echo.
echo 更新nginx配置...
powershell -Command "(Get-Content 'C:\nginx\conf\admin.practice.insightdata.top.conf') -replace 'practice\.insightdata\.top\.pem', 'admin.practice.insightdata.top.pem' -replace 'practice\.insightdata\.top\.key', 'admin.practice.insightdata.top.key' | Set-Content 'C:\nginx\conf\admin.practice.insightdata.top.conf'"
echo ✅ nginx配置已更新

echo.
echo 停止临时HTTP服务器...
taskkill /f /im python.exe >nul 2>&1
echo ✅ 临时HTTP服务器已停止

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
