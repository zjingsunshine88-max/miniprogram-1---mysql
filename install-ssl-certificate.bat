@echo off
chcp 65001 >nul
title SSL证书安装工具

echo 🔐 SSL证书安装工具
echo.

echo 📋 检查Python环境...
echo.

REM 尝试不同的Python命令
python --version >nul 2>&1
if not errorlevel 1 (
    set PYTHON_CMD=python
    echo ✅ 找到Python: python
    goto :install_certbot
)

python3 --version >nul 2>&1
if not errorlevel 1 (
    set PYTHON_CMD=python3
    echo ✅ 找到Python: python3
    goto :install_certbot
)

py --version >nul 2>&1
if not errorlevel 1 (
    set PYTHON_CMD=py
    echo ✅ 找到Python: py
    goto :install_certbot
)

REM 检查常见Python安装路径
if exist "C:\Python39\python.exe" (
    set PYTHON_CMD=C:\Python39\python.exe
    echo ✅ 找到Python: C:\Python39\python.exe
    goto :install_certbot
)

if exist "C:\Python310\python.exe" (
    set PYTHON_CMD=C:\Python310\python.exe
    echo ✅ 找到Python: C:\Python310\python.exe
    goto :install_certbot
)

if exist "C:\Python311\python.exe" (
    set PYTHON_CMD=C:\Python311\python.exe
    echo ✅ 找到Python: C:\Python311\python.exe
    goto :install_certbot
)

if exist "C:\Python312\python.exe" (
    set PYTHON_CMD=C:\Python312\python.exe
    echo ✅ 找到Python: C:\Python312\python.exe
    goto :install_certbot
)

echo ❌ 未找到Python
echo.
echo 💡 请确保Python已正确安装并添加到PATH
echo 或者手动指定Python路径
echo.
set /p python_path="请输入Python.exe的完整路径: "
if exist "%python_path%" (
    set PYTHON_CMD="%python_path%"
    echo ✅ 使用Python: %python_path%
    goto :install_certbot
) else (
    echo ❌ Python路径无效
    pause
    exit /b 1
)

:install_certbot
echo.
echo 📋 安装Certbot...
echo 正在使用 %PYTHON_CMD% 安装certbot...

%PYTHON_CMD% -m pip install certbot

if errorlevel 1 (
    echo ❌ Certbot安装失败
    echo.
    echo 💡 可能的解决方案:
    echo 1. 检查网络连接
    echo 2. 使用管理员权限运行
    echo 3. 升级pip: %PYTHON_CMD% -m pip install --upgrade pip
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Certbot安装成功
)

echo.
echo 📋 准备生成SSL证书...
echo.
echo ⚠️  重要提示:
echo 1. 确保域名 practice.insightdata.top 已解析到服务器IP
echo 2. 需要临时停止Nginx以释放80端口
echo 3. 证书生成过程需要网络连接
echo.

set /p confirm="是否继续生成证书? (y/n): "
if /i not "%confirm%"=="y" (
    echo 操作已取消
    pause
    exit /b 0
)

echo.
echo 📋 停止Nginx服务...
nginx -s stop
timeout /t 2 >nul

echo.
echo 📋 生成SSL证书...
echo 域名: practice.insightdata.top
echo 邮箱: admin@practice.insightdata.top
echo.

%PYTHON_CMD% -m certbot certonly --standalone -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos --non-interactive

if errorlevel 1 (
    echo ❌ 证书生成失败
    echo.
    echo 💡 可能的原因:
    echo 1. 域名未正确解析到服务器IP
    echo 2. 80端口仍被占用
    echo 3. 网络连接问题
    echo 4. 防火墙阻止了连接
    echo.
    echo 🔧 故障排除:
    echo 1. 检查域名解析: nslookup practice.insightdata.top
    echo 2. 检查端口占用: netstat -ano | findstr :80
    echo 3. 检查网络连接: ping 8.8.8.8
    echo.
    echo 重启Nginx...
    nginx
    pause
    exit /b 1
) else (
    echo ✅ 证书生成成功
)

echo.
echo 📋 复制证书文件...
if not exist "C:\certificates" mkdir C:\certificates

copy "C:\Certbot\live\practice.insightdata.top\fullchain.pem" "C:\certificates\practice.insightdata.top.pem"
copy "C:\Certbot\live\practice.insightdata.top\privkey.pem" "C:\certificates\practice.insightdata.top.key"

if errorlevel 1 (
    echo ❌ 证书复制失败
    echo 💡 请手动复制证书文件
    echo 源路径: C:\Certbot\live\practice.insightdata.top\
    echo 目标路径: C:\certificates\
    echo.
    echo 重启Nginx...
    nginx
    pause
    exit /b 1
) else (
    echo ✅ 证书复制成功
)

echo.
echo 📋 重启Nginx服务...
nginx

if errorlevel 1 (
    echo ❌ Nginx启动失败
    echo 💡 请检查Nginx配置
    pause
    exit /b 1
) else (
    echo ✅ Nginx启动成功
)

echo.
echo 📋 设置自动续期...
echo 创建续期脚本...

echo @echo off > C:\certbot\renew.bat
echo %PYTHON_CMD% -m certbot renew --quiet >> C:\certbot\renew.bat
echo nginx -s reload >> C:\certbot\renew.bat

echo 添加Windows计划任务...
schtasks /create /tn "Certbot Renewal" /tr "C:\certbot\renew.bat" /sc daily /st 02:00 /f

if errorlevel 1 (
    echo ⚠️  自动续期任务创建失败，请手动设置
) else (
    echo ✅ 自动续期任务创建成功
)

echo.
echo 🎉 SSL证书安装完成！
echo.
echo 📋 证书信息:
echo - 证书路径: C:\certificates\practice.insightdata.top.pem
echo - 私钥路径: C:\certificates\practice.insightdata.top.key
echo - 有效期: 90天（自动续期）
echo.
echo 🌐 测试访问:
echo - 管理后台: https://practice.insightdata.top/
echo - API接口: https://practice.insightdata.top/api/
echo - 健康检查: https://practice.insightdata.top/health
echo.
echo 💡 注意事项:
echo 1. 证书有效期为90天，会自动续期
echo 2. 如果续期失败，请手动运行: %PYTHON_CMD% -m certbot renew
echo 3. 证书文件位置: C:\Certbot\live\practice.insightdata.top\
echo.
echo 按任意键退出...
pause >nul
