@echo off
chcp 65001 >nul
echo ========================================
echo 修复Windows Nginx配置
echo ========================================
echo.

:: 检查是否以管理员身份运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本
    echo 右键点击此文件，选择"以管理员身份运行"
    pause
    exit /b 1
)

echo [信息] 检测到管理员权限
echo.

:: 检查C:\nginx是否存在
if not exist "C:\nginx" (
    echo [错误] C:\nginx目录不存在
    echo 请确保nginx已正确安装到C:\nginx目录
    pause
    exit /b 1
)

echo [OK] C:\nginx目录存在
echo.

:: 创建必要的目录
echo [信息] 创建必要的目录...
if not exist "C:\nginx\logs" (
    mkdir "C:\nginx\logs"
    echo [OK] 已创建logs目录
)

if not exist "C:\nginx\conf.d" (
    mkdir "C:\nginx\conf.d"
    echo [OK] 已创建conf.d目录
)

if not exist "C:\nginx\temp" (
    mkdir "C:\nginx\temp"
    echo [OK] 已创建temp目录
)

:: 备份原始配置文件
echo [信息] 备份原始配置文件...
if exist "C:\nginx\conf\nginx.conf" (
    if not exist "C:\nginx\conf\nginx.conf.backup" (
        copy "C:\nginx\conf\nginx.conf" "C:\nginx\conf\nginx.conf.backup" >nul
        echo [OK] 已备份原始配置文件
    ) else (
        echo [信息] 备份文件已存在
    )
)

:: 创建Windows兼容的nginx.conf
echo [信息] 创建Windows兼容的nginx.conf...
(
echo # Windows版本的nginx配置文件
echo # 适用于C:\nginx安装
echo.
echo worker_processes auto;
echo error_log logs/error.log warn;
echo pid logs/nginx.pid;
echo.
echo events {
echo     worker_connections 1024;
echo     # Windows使用select事件模型
echo     use select;
echo     multi_accept on;
echo }
echo.
echo http {
echo     # 包含MIME类型定义
echo     include mime.types;
echo     default_type application/octet-stream;
echo.
echo     # 日志格式
echo     log_format main '$remote_addr - $remote_user [$time_local] "$request" '
echo                     '$status $body_bytes_sent "$http_referer" '
echo                     '"$http_user_agent" "$http_x_forwarded_for"';
echo.
echo     access_log logs/access.log main;
echo.
echo     # 基本设置
echo     sendfile on;
echo     tcp_nopush on;
echo     tcp_nodelay on;
echo     keepalive_timeout 65;
echo     types_hash_max_size 2048;
echo     client_max_body_size 20M;
echo.
echo     # 启用gzip压缩
echo     gzip on;
echo     gzip_vary on;
echo     gzip_min_length 1024;
echo     gzip_proxied any;
echo     gzip_comp_level 6;
echo     gzip_types
echo         text/plain
echo         text/css
echo         text/xml
echo         text/javascript
echo         application/javascript
echo         application/xml+rss
echo         application/json;
echo.
echo     # 包含站点配置
echo     include conf.d/*.conf;
echo }
) > "C:\nginx\conf\nginx.conf"

echo [OK] 已创建Windows兼容的nginx.conf

:: 创建mime.types文件（如果不存在）
if not exist "C:\nginx\mime.types" (
    echo [信息] 创建mime.types文件...
    (
        echo types {
        echo     text/html                             html htm shtml;
        echo     text/css                              css;
        echo     text/xml                              xml;
        echo     image/gif                             gif;
        echo     image/jpeg                            jpeg jpg;
        echo     application/javascript                js;
        echo     application/json                       json;
        echo     image/png                             png;
        echo     image/svg+xml                         svg;
        echo     application/pdf                        pdf;
        echo     application/octet-stream               bin exe dll;
        echo }
    ) > "C:\nginx\mime.types"
    echo [OK] 已创建mime.types文件
)

:: 创建空的日志文件
echo [信息] 创建日志文件...
echo. > "C:\nginx\logs\error.log"
echo. > "C:\nginx\logs\access.log"
echo [OK] 已创建日志文件

:: 测试nginx配置
echo [信息] 测试nginx配置...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx配置测试通过
) else (
    echo [ERROR] nginx配置测试失败
    echo [信息] 请检查配置文件
)

cd /d "%~dp0"

echo.
echo ========================================
echo 修复完成！
echo ========================================
echo.
echo 现在可以运行 start-admin-ssl.bat 启动服务
echo.
echo 按任意键退出...
pause >nul
