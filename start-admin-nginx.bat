@echo off
chcp 65001 >nul
title 使用Nginx启动后台管理系统

echo 🌐 使用Nginx启动后台管理系统...
echo.

REM 检查Nginx是否存在
if not exist "C:\nginx\nginx.exe" (
    echo ❌ 错误: 未找到Nginx
    echo 💡 请先下载并安装Nginx到 C:\nginx\
    echo 下载地址: http://nginx.org/en/download.html
    pause
    exit /b 1
)

REM 进入admin目录
cd /d "%~dp0admin"

REM 检查dist目录是否存在
if not exist "dist" (
    echo ❌ 错误: dist目录不存在
    echo 💡 请先运行构建命令: npm run build
    pause
    exit /b 1
)

echo ✅ dist目录检查通过
echo.

REM 创建Nginx配置文件
echo 📝 创建Nginx配置...
echo worker_processes 1; > nginx-admin.conf
echo. >> nginx-admin.conf
echo events { >> nginx-admin.conf
echo     worker_connections 1024; >> nginx-admin.conf
echo } >> nginx-admin.conf
echo. >> nginx-admin.conf
echo http { >> nginx-admin.conf
echo     include       mime.types; >> nginx-admin.conf
echo     default_type  application/octet-stream; >> nginx-admin.conf
echo     sendfile        on; >> nginx-admin.conf
echo     keepalive_timeout  65; >> nginx-admin.conf
echo. >> nginx-admin.conf
echo     server { >> nginx-admin.conf
echo         listen       3001; >> nginx-admin.conf
echo         server_name  223.93.139.87; >> nginx-admin.conf
echo. >> nginx-admin.conf
echo         location / { >> nginx-admin.conf
echo             root   %~dp0dist; >> nginx-admin.conf
echo             index  index.html index.htm; >> nginx-admin.conf
echo             try_files $uri $uri/ /index.html; >> nginx-admin.conf
echo         } >> nginx-admin.conf
echo. >> nginx-admin.conf
echo         # 静态资源缓存 >> nginx-admin.conf
echo         location ~* \.(js^|css^|png^|jpg^|jpeg^|gif^|ico^|svg^|woff^|woff2^|ttf^|eot)$ { >> nginx-admin.conf
echo             expires 1y; >> nginx-admin.conf
echo             add_header Cache-Control "public, immutable"; >> nginx-admin.conf
echo         } >> nginx-admin.conf
echo. >> nginx-admin.conf
echo         # API代理到后端服务 >> nginx-admin.conf
echo         location /api { >> nginx-admin.conf
echo             proxy_pass http://localhost:3002; >> nginx-admin.conf
echo             proxy_http_version 1.1; >> nginx-admin.conf
echo             proxy_set_header Upgrade $http_upgrade; >> nginx-admin.conf
echo             proxy_set_header Connection 'upgrade'; >> nginx-admin.conf
echo             proxy_set_header Host $host; >> nginx-admin.conf
echo             proxy_set_header X-Real-IP $remote_addr; >> nginx-admin.conf
echo             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >> nginx-admin.conf
echo             proxy_set_header X-Forwarded-Proto $scheme; >> nginx-admin.conf
echo             proxy_cache_bypass $http_upgrade; >> nginx-admin.conf
echo         } >> nginx-admin.conf
echo     } >> nginx-admin.conf
echo } >> nginx-admin.conf

echo ✅ Nginx配置文件创建完成
echo.

REM 检查端口3001是否被占用
netstat -an | findstr :3001 >nul
if not errorlevel 1 (
    echo ⚠️  端口3001已被占用
    echo 🔍 正在查找占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
        echo 进程ID: %%a
        tasklist /fi "pid eq %%a"
    )
    echo.
    set /p KILL_PROCESS="是否要结束占用进程？(y/n): "
    if /i "%KILL_PROCESS%"=="y" (
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
            taskkill /f /pid %%a
        )
        echo ✅ 进程已结束
    ) else (
        echo ❌ 取消启动
        pause
        exit /b 1
    )
)

REM 启动Nginx
echo 🚀 启动Nginx...
cd /d C:\nginx
start nginx.exe -c "%~dp0admin\nginx-admin.conf"

echo.
echo ✅ Nginx启动成功！
echo.
echo 🌐 访问地址：
echo   本地访问: http://localhost:3001
echo   远程访问: http://223.93.139.87:3001
echo.
echo 💡 管理命令：
echo   停止Nginx: taskkill /f /im nginx.exe
echo   重新加载: nginx.exe -s reload
echo   检查配置: nginx.exe -t
echo.
echo 按任意键退出...
pause >nul
