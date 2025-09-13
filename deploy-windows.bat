@echo off
chcp 65001 >nul
echo 🚀 开始部署刷题小程序系统到Windows服务器...
echo.

REM 设置变量
set PROJECT_ROOT=%~dp0
set SERVICE_DIR=C:\question-bank
set BACKUP_DIR=C:\backup\%date:~0,10%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set IP_ADDRESS=223.93.139.87

REM 创建备份目录
echo 📁 创建备份目录...
if not exist C:\backup mkdir C:\backup
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM 备份现有服务（如果存在）
if exist "%SERVICE_DIR%" (
    echo 💾 备份现有服务...
    xcopy "%SERVICE_DIR%" "%BACKUP_DIR%" /E /I /Y
)

REM 创建服务目录
echo 📂 创建服务目录...
if not exist "%SERVICE_DIR%" mkdir "%SERVICE_DIR%"

REM 1. 构建后台管理系统
echo 🔨 构建后台管理系统...
cd /d "%PROJECT_ROOT%admin"
call npm install
if errorlevel 1 (
    echo ❌ 后台管理系统依赖安装失败
    pause
    exit /b 1
)

call npm run build
if errorlevel 1 (
    echo ❌ 后台管理系统构建失败
    pause
    exit /b 1
)

REM 复制构建文件到服务目录
if not exist "%SERVICE_DIR%\admin" mkdir "%SERVICE_DIR%\admin"
xcopy dist\* "%SERVICE_DIR%\admin\" /E /Y

REM 2. 构建API服务
echo 🔨 准备API服务...
cd /d "%PROJECT_ROOT%server"

REM 安装生产依赖
call npm install --production
if errorlevel 1 (
    echo ❌ API服务依赖安装失败
    pause
    exit /b 1
)

REM 创建必要目录
if not exist "%SERVICE_DIR%\logs" mkdir "%SERVICE_DIR%\logs"
if not exist "%SERVICE_DIR%\public\uploads" mkdir "%SERVICE_DIR%\public\uploads"

REM 复制API服务文件
xcopy . "%SERVICE_DIR%\api\" /E /Y /EXCLUDE:exclude.txt

REM 创建排除文件列表
echo node_modules > exclude.txt
echo .git >> exclude.txt
echo logs >> exclude.txt
echo temp >> exclude.txt

REM 3. 复制小程序文件
echo 📱 复制小程序文件...
if not exist "%SERVICE_DIR%\miniprogram" mkdir "%SERVICE_DIR%\miniprogram"
xcopy "%PROJECT_ROOT%miniprogram\*" "%SERVICE_DIR%\miniprogram\" /E /Y

REM 4. 检查并安装PM2
echo 📦 检查PM2安装状态...
pm2 --version >nul 2>&1
if errorlevel 1 (
    echo 安装PM2...
    call npm install -g pm2
    call npm install -g pm2-windows-startup
    if errorlevel 1 (
        echo ❌ PM2安装失败
        pause
        exit /b 1
    )
)

REM 5. 启动API服务
echo 🚀 启动API服务...
cd /d "%SERVICE_DIR%\api"

REM 停止现有服务
pm2 stop question-bank-api >nul 2>&1
pm2 delete question-bank-api >nul 2>&1

REM 启动新服务
set NODE_ENV=production
pm2 start app.js --name "question-bank-api" --env production
if errorlevel 1 (
    echo ❌ API服务启动失败
    pause
    exit /b 1
)

REM 保存PM2配置
pm2 save

REM 6. 配置Windows防火墙
echo 🔥 配置Windows防火墙...
netsh advfirewall firewall add rule name="Question Bank API" dir=in action=allow protocol=TCP localport=3002
netsh advfirewall firewall add rule name="Question Bank Admin" dir=in action=allow protocol=TCP localport=3001
netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="MySQL" dir=in action=allow protocol=TCP localport=3306

REM 7. 初始化数据库（可选）
set /p INIT_DB="🗄️ 是否需要初始化数据库？(y/n): "
if /i "%INIT_DB%"=="y" (
    echo 初始化数据库...
    cd /d "%SERVICE_DIR%\api"
    call node scripts\init-db.js
    call node scripts\init-admin.js
)

echo.
echo ✅ 部署完成！
echo.
echo 📊 服务状态：
pm2 status

echo.
echo 🌐 访问地址：
echo   后台管理: http://%IP_ADDRESS%/admin
echo   API服务: http://%IP_ADDRESS%/api
echo   健康检查: http://%IP_ADDRESS%/health

echo.
echo 📝 部署日志已保存到: %BACKUP_DIR%

echo.
echo 🔧 小程序配置说明：
echo   在微信开发者工具中配置服务器域名：
echo   - request合法域名: http://%IP_ADDRESS%:3002
echo   - uploadFile合法域名: http://%IP_ADDRESS%:3002
echo   - downloadFile合法域名: http://%IP_ADDRESS%:3002

echo.
echo 按任意键退出...
pause >nul
