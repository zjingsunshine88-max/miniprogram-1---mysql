@echo off
chcp 65001 >nul
echo ========================================
echo 快速启动Admin管理后台
echo ========================================
echo.

:: 检查证书文件是否存在
if not exist "C:\certificates\admin.practice.insightdata.top.pem" (
    echo [错误] SSL证书文件不存在: C:\certificates\admin.practice.insightdata.top.pem
    echo 请确保SSL证书已正确配置到C:\certificates目录
    pause
    exit /b 1
)

if not exist "C:\certificates\admin.practice.insightdata.top.key" (
    echo [错误] SSL私钥文件不存在: C:\certificates\admin.practice.insightdata.top.key
    echo 请确保SSL私钥已正确配置到C:\certificates目录
    pause
    exit /b 1
)

echo [OK] SSL证书文件检查通过
echo.

:: 检查admin目录是否存在
if not exist "admin" (
    echo [错误] admin目录不存在
    echo 请确保在项目根目录下运行此脚本
    pause
    exit /b 1
)

echo [信息] 进入admin目录...
cd admin

:: 检查package.json是否存在
if not exist "package.json" (
    echo [错误] admin/package.json不存在
    pause
    exit /b 1
)

:: 安装依赖（如果需要）
if not exist "node_modules" (
    echo [信息] 安装admin依赖...
    call npm install
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
)

echo [信息] 依赖检查完成
echo.

:: 构建admin项目
echo [信息] 构建admin项目...
call npm run build
if %errorlevel% neq 0 (
    echo [错误] admin项目构建失败
    pause
    exit /b 1
)

echo [信息] admin项目构建完成
echo.

:: 创建C:\admin目录（如果不存在）
if not exist "C:\admin" (
    echo [信息] 创建C:\admin目录...
    mkdir "C:\admin"
)

:: 复制dist目录到C:\admin
echo [信息] 复制构建文件到C:\admin...
if exist "dist" (
    xcopy "dist\*" "C:\admin\" /E /Y /Q
    if %errorlevel% equ 0 (
        echo [OK] 构建文件复制成功
    ) else (
        echo [ERROR] 构建文件复制失败
        pause
        exit /b 1
    )
) else (
    echo [错误] dist目录不存在，构建可能失败
    pause
    exit /b 1
)

:: 返回项目根目录
cd ..

:: 停止可能正在运行的nginx
echo [信息] 停止可能正在运行的nginx...
taskkill /f /im nginx.exe >nul 2>&1

:: 启动nginx（不测试配置）
echo [信息] 启动nginx (SSL模式)...
echo [信息] nginx路径: C:\nginx
echo [信息] 配置文件: C:\nginx\conf\nginx.conf
start "Nginx SSL Server" cmd /c "cd /d C:\nginx && nginx"

:: 等待nginx启动
echo [信息] 等待nginx启动...
timeout /t 3 /nobreak >nul

:: 检查服务状态
echo [信息] 检查服务状态...
echo.

:: 检查C:\admin目录
if exist "C:\admin\index.html" (
    echo [OK] Admin静态文件部署成功 ^(C:\admin^)
) else (
    echo [ERROR] Admin静态文件部署失败
)

:: 检查nginx进程
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx进程运行正常 ^(C:\nginx^)
) else (
    echo [ERROR] Nginx进程未启动
)

:: 检查nginx端口
netstat -an | find ":80 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx端口80监听正常
) else (
    echo [ERROR] Nginx端口80未监听
)

:: 检查nginx端口8443
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx端口8443监听正常
) else (
    echo [ERROR] Nginx端口8443未监听
)

echo.
echo ========================================
echo 启动完成！
echo ========================================
echo.
echo 访问地址:
echo   HTTPS: https://admin.practice.insightdate.top:8443
echo   HTTP:  http://admin.practice.insightdate.top (自动重定向到HTTPS:8443)
echo.
echo 本地测试地址:
echo   Nginx代理: http://localhost
echo   HTTPS测试: https://localhost:8443
echo.
echo 部署信息:
echo   - 静态文件位置: C:\admin
echo   - Nginx路径: C:\nginx
echo   - Nginx配置: C:\nginx\conf\nginx.conf
echo   - Admin将调用远程API: https://practice.insightdate.top/api
echo   - 请确保远程API服务正常运行
echo   - 如需停止服务，请运行 stop-admin-ssl.bat
echo.
echo 注意: 此脚本跳过了nginx配置测试，直接启动服务
echo.
echo 按任意键退出...
pause >nul
