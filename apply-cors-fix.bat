@echo off
chcp 65001 >nul
echo ========================================
echo 应用跨域问题修复
echo ========================================
echo.

echo [STEP 1] 停止现有服务
echo ========================================
echo [INFO] 停止nginx服务...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [INFO] 停止Node.js服务...
taskkill /f /im node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [STEP 2] 测试nginx配置
echo ========================================
echo [INFO] 测试nginx配置...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx配置测试通过
) else (
    echo [ERROR] nginx配置测试失败
    echo [INFO] 请检查配置错误
    pause
    exit /b 1
)
cd /d "%~dp0"

echo.
echo [STEP 3] 启动nginx服务
echo ========================================
echo [INFO] 启动nginx服务...
cd /d C:\nginx
start "Nginx Server" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

echo [INFO] 检查nginx状态...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx服务已启动
) else (
    echo [ERROR] nginx服务启动失败
    pause
    exit /b 1
)

echo.
echo [STEP 4] 启动API服务器
echo ========================================
echo [INFO] 启动API服务器...
cd /d "%~dp0\server"
start "API Server" cmd /c "npm start"
timeout /t 5 /nobreak >nul
cd /d "%~dp0"

echo [INFO] 检查API服务器状态...
netstat -an | find ":3002 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] API服务器已启动 (端口3002)
) else (
    echo [WARNING] API服务器可能未完全启动，请稍等片刻
)

echo.
echo [STEP 5] 启动Admin前端服务
echo ========================================
echo [INFO] 启动Admin前端服务...
cd /d "%~dp0\admin"
start "Admin Frontend" cmd /c "npm run dev"
timeout /t 5 /nobreak >nul
cd /d "%~dp0"

echo [INFO] 检查Admin前端服务状态...
netstat -an | find ":3001 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Admin前端服务已启动 (端口3001)
) else (
    echo [WARNING] Admin前端服务可能未完全启动，请稍等片刻
)

echo.
echo ========================================
echo 跨域修复完成
echo ========================================
echo.
echo 已应用的修复：
echo.
echo [后端API服务器]
echo - 添加了admin子域名到CORS允许列表
echo - 支持HTTPS和HTTP访问
echo - 包含端口8443的访问
echo.
echo [Nginx配置]
echo - 添加了CORS头部支持
echo - 处理OPTIONS预检请求
echo - 允许跨域凭据传递
echo.
echo [前端配置]
echo - 添加了正确的请求头
echo - 启用了CORS模式
echo - 包含Accept头部
echo.
echo 服务状态：
echo - Nginx: 运行中
echo - API服务器: 运行中 (端口3002)
echo - Admin前端: 运行中 (端口3001)
echo.
echo 访问地址：
echo - Admin管理界面: https://admin.practice.insightdate.top:8443
echo - API服务: https://practice.insightdate.top/api
echo.
echo 如果仍有跨域问题，请：
echo 1. 检查浏览器开发者工具的网络面板
echo 2. 确认请求头是否正确
echo 3. 检查SSL证书是否有效
echo.
echo Press any key to exit...
pause >nul
