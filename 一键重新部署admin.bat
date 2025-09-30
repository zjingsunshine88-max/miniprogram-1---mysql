@echo off
chcp 65001 >nul
echo ================================================
echo           一键重新部署Admin和API
echo ================================================
echo.

:: 设置颜色
color 0A

:: 检查是否在正确的目录
if not exist "admin\package.json" (
    echo [错误] 请在项目根目录运行此脚本
    pause
    exit /b 1
)

:: 检查Node.js环境
echo [1/6] 检查Node.js环境...
where node >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到Node.js，请先安装Node.js
    pause
    exit /b 1
)
echo [✓] Node.js环境正常

:: 检查npm环境
where npm >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到npm，请先安装npm
    pause
    exit /b 1
)
echo [✓] npm环境正常

:: 进入admin目录
cd admin

:: 安装依赖（如果需要）
echo.
echo [2/6] 检查并安装依赖...
if not exist "node_modules" (
    echo [信息] 正在安装依赖...
    call npm install
    if errorlevel 1 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
) else (
    echo [✓] 依赖已存在
)

:: 构建admin项目
echo.
echo [3/6] 构建Admin项目...
echo [信息] 正在构建生产版本...
call npm run build
if errorlevel 1 (
    echo [错误] 构建失败
    pause
    exit /b 1
)
echo [✓] 构建完成

:: 检查dist目录
if not exist "dist" (
    echo [错误] 构建后未找到dist目录
    pause
    exit /b 1
)

:: 返回项目根目录
cd ..

:: 创建目标目录
echo.
echo [4/6] 创建目标目录...
if not exist "C:\admin" (
    mkdir "C:\admin"
    echo [信息] 创建目录: C:\admin
)

:: 复制dist文件
echo.
echo [5/6] 复制Admin文件...
echo [信息] 正在复制dist文件到 C:\admin\dist...
robocopy "admin\dist" "C:\admin\dist" /E /Y /NFL /NDL /NJH /NJS
if errorlevel 8 (
    echo [错误] 复制文件失败
    pause
    exit /b 1
)
echo [✓] 文件复制完成

:: 重启nginx服务
echo.
echo [6/6] 重启Nginx服务...
echo [信息] 正在重启nginx...

:: 尝试停止nginx
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul

:: 启动nginx
if exist "C:\nginx\nginx.exe" (
    start "" "C:\nginx\nginx.exe"
    echo [✓] Nginx已重启
) else (
    echo [警告] 未找到nginx.exe，请手动启动nginx
    echo [信息] 请运行: C:\nginx\nginx.exe
)

:: 检查服务状态
echo.
echo [信息] 检查服务状态...
timeout /t 3 >nul

:: 检查nginx进程
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [✓] Nginx服务正在运行
) else (
    echo [警告] Nginx服务可能未正常启动
)

:: 测试API连接
echo.
echo [信息] 测试API连接...
curl -s -o nul -w "HTTP状态码: %%{http_code}" http://localhost:3002/api/health 2>nul
if errorlevel 1 (
    echo [警告] API服务可能未运行，请检查后端服务
) else (
    echo [✓] API服务连接正常
)

echo.
echo ================================================
echo           部署完成！
echo ================================================
echo.
echo [信息] Admin管理后台已部署到: C:\admin\dist
echo [信息] 访问地址: https://practice.insightdata.top:8443
echo [信息] API地址: http://practice.insightdata.top/api/
echo.
echo [提示] 如果外网无法访问，请检查:
echo        1. 防火墙设置 (8443端口)
echo        2. 云服务器安全组设置
echo        3. nginx配置是否正确
echo        4. SSL证书是否有效
echo.

:: 打开浏览器测试
set /p choice="是否打开浏览器测试? (Y/N): "
if /i "%choice%"=="Y" (
    start "" "https://practice.insightdata.top:8443"
)

echo.
echo 按任意键退出...
pause >nul
