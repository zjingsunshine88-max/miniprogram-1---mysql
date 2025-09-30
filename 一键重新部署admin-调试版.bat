@echo off
chcp 65001 >nul
echo ================================================
echo           一键重新部署Admin和API - 调试版
echo ================================================
echo.

:: 设置颜色
color 0A

:: 显示当前目录
echo [调试] 当前目录: %CD%
echo.

:: 检查是否在正确的目录
echo [调试] 检查admin目录...
if not exist "admin\package.json" (
    echo [错误] 未找到admin\package.json
    echo [调试] 当前目录内容:
    dir /b
    echo.
    echo [错误] 请在项目根目录运行此脚本
    pause
    exit /b 1
)
echo [✓] 找到admin\package.json

:: 检查Node.js环境
echo.
echo [1/6] 检查Node.js环境...
echo [调试] 正在检查node命令...
where node >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到node命令
    echo [调试] 请检查PATH环境变量
    pause
    exit /b 1
)

echo [调试] 正在获取node版本...
node --version 2>&1
if errorlevel 1 (
    echo [错误] node命令执行失败
    pause
    exit /b 1
)
echo [✓] Node.js环境正常

:: 检查npm环境
echo.
echo [调试] 正在检查npm命令...
where npm >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到npm命令
    pause
    exit /b 1
)

echo [调试] 正在获取npm版本...
npm --version 2>&1
if errorlevel 1 (
    echo [错误] npm命令执行失败
    pause
    exit /b 1
)
echo [✓] npm环境正常

:: 进入admin目录
echo.
echo [调试] 正在进入admin目录...
cd admin
echo [调试] 当前目录: %CD%

:: 检查package.json
echo.
echo [调试] 检查package.json内容...
type package.json | findstr "build"
if errorlevel 1 (
    echo [警告] 未找到build脚本
) else (
    echo [✓] 找到build脚本
)

:: 安装依赖（如果需要）
echo.
echo [2/6] 检查并安装依赖...
if not exist "node_modules" (
    echo [信息] 正在安装依赖...
    echo [调试] 执行: npm install
    npm install
    if errorlevel 1 (
        echo [错误] 依赖安装失败
        echo [调试] npm install执行失败，错误代码: %ERRORLEVEL%
        pause
        exit /b 1
    )
    echo [✓] 依赖安装完成
) else (
    echo [✓] 依赖已存在
)

:: 构建admin项目
echo.
echo [3/6] 构建Admin项目...
echo [信息] 正在构建生产版本...
echo [调试] 执行: npm run build
npm run build
if errorlevel 1 (
    echo [错误] 构建失败
    echo [调试] npm run build执行失败，错误代码: %ERRORLEVEL%
    pause
    exit /b 1
)
echo [✓] 构建完成

:: 检查dist目录
echo.
echo [调试] 检查dist目录...
if not exist "dist" (
    echo [错误] 构建后未找到dist目录
    echo [调试] 当前目录内容:
    dir /b
    pause
    exit /b 1
)
echo [✓] 找到dist目录
echo [调试] dist目录内容:
dir /b dist

:: 返回项目根目录
echo.
echo [调试] 返回项目根目录...
cd ..
echo [调试] 当前目录: %CD%

:: 创建目标目录
echo.
echo [4/6] 创建目标目录...
if not exist "C:\admin" (
    echo [调试] 创建目录: C:\admin
    mkdir "C:\admin"
    if errorlevel 1 (
        echo [错误] 创建目录失败
        pause
        exit /b 1
    )
    echo [信息] 创建目录: C:\admin
) else (
    echo [✓] 目录C:\admin已存在
)

:: 复制dist文件
echo.
echo [5/6] 复制Admin文件...
echo [信息] 正在复制dist文件到 C:\admin\dist...
echo [调试] 执行: robocopy "admin\dist" "C:\admin\dist" /E /Y /NFL /NDL /NJH /NJS
robocopy "admin\dist" "C:\admin\dist" /E /Y /NFL /NDL /NJH /NJS
echo [调试] robocopy退出代码: %ERRORLEVEL%
if %ERRORLEVEL% GTR 7 (
    echo [错误] 复制文件失败
    pause
    exit /b 1
)
echo [✓] 文件复制完成

:: 检查复制结果
echo.
echo [调试] 检查复制结果...
if exist "C:\admin\dist\index.html" (
    echo [✓] 复制成功，找到index.html
) else (
    echo [警告] 复制可能不完整，未找到index.html
)

:: 重启nginx服务
echo.
echo [6/6] 重启Nginx服务...
echo [信息] 正在重启nginx...

:: 尝试停止nginx
echo [调试] 停止nginx进程...
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul

:: 启动nginx
echo [调试] 检查nginx.exe路径...
if exist "C:\nginx\nginx.exe" (
    echo [调试] 找到nginx.exe，正在启动...
    start "" "C:\nginx\nginx.exe"
    echo [✓] Nginx已重启
) else (
    echo [警告] 未找到C:\nginx\nginx.exe
    echo [调试] 尝试查找nginx.exe...
    where nginx.exe 2>nul
    if errorlevel 1 (
        echo [错误] 未找到nginx.exe，请手动启动nginx
        echo [信息] 请运行: C:\nginx\nginx.exe
    ) else (
        echo [信息] 找到nginx.exe，正在启动...
        start "" "nginx.exe"
        echo [✓] Nginx已重启
    )
)

:: 检查服务状态
echo.
echo [信息] 检查服务状态...
timeout /t 3 >nul

:: 检查nginx进程
echo [调试] 检查nginx进程...
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [✓] Nginx服务正在运行
) else (
    echo [警告] Nginx服务可能未正常启动
)

:: 测试API连接
echo.
echo [信息] 测试API连接...
echo [调试] 测试API连接: http://localhost:3002/api/health
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
