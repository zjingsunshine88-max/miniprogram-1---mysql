@echo off
chcp 65001 >nul
title 测试数据库连接

:menu
cls
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                     数据库连接测试工具                        ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║  1. 测试开发环境数据库连接 (密码: 1234)                        ║
echo ║  2. 测试生产环境数据库连接 (密码: LOVEjing96..)                ║
echo ║  3. 测试自定义数据库连接                                      ║
echo ║  4. 创建practice数据库                                        ║
echo ║  0. 退出                                                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

set /p choice="请选择测试类型 (0-4): "

if "%choice%"=="1" goto test_dev
if "%choice%"=="2" goto test_prod
if "%choice%"=="3" goto test_custom
if "%choice%"=="4" goto create_db
if "%choice%"=="0" goto exit
goto menu

:test_dev
echo.
echo 🧪 测试开发环境数据库连接...
echo 主机: localhost
echo 端口: 3306
echo 用户名: root
echo 密码: 1234
echo 数据库: practice
echo.

mysql -u root -p1234 -e "SELECT 1 as test_connection;" >nul 2>&1
if errorlevel 1 (
    echo ❌ 开发环境数据库连接失败
    echo 💡 请检查：
    echo    1. MySQL服务是否启动
    echo    2. 密码是否为 1234
    echo    3. 用户权限是否正确
) else (
    echo ✅ 开发环境数据库基本连接成功！
    
    echo 测试practice数据库...
    mysql -u root -p1234 -e "USE practice; SELECT 1 as test_connection;" >nul 2>&1
    if errorlevel 1 (
        echo ❌ practice数据库不存在或无法访问
        echo 💡 是否需要创建practice数据库？
        set /p CREATE_DB="创建practice数据库？(y/n): "
        if /i "%CREATE_DB%"=="y" (
            mysql -u root -p1234 -e "CREATE DATABASE IF NOT EXISTS practice;"
            if not errorlevel 1 (
                echo ✅ practice数据库创建成功！
            ) else (
                echo ❌ practice数据库创建失败
            )
        )
    ) else (
        echo ✅ practice数据库连接成功！
        echo 🎉 开发环境数据库完全正常！
    )
)
pause
goto menu

:test_prod
echo.
echo 🧪 测试生产环境数据库连接...
echo 主机: 223.93.139.87
echo 端口: 3306
echo 用户名: root
echo 密码: LOVEjing96..
echo 数据库: practice
echo.

mysql -h 223.93.139.87 -u root -pLOVEjing96.. -e "SELECT 1 as test_connection;" >nul 2>&1
if errorlevel 1 (
    echo ❌ 生产环境数据库连接失败
    echo 💡 请检查：
    echo    1. 网络连接是否正常
    echo    2. MySQL服务是否启动
    echo    3. 密码是否为 LOVEjing96..
    echo    4. 防火墙是否开放3306端口
    echo    5. 用户权限是否正确
) else (
    echo ✅ 生产环境数据库基本连接成功！
    
    echo 测试practice数据库...
    mysql -h 223.93.139.87 -u root -pLOVEjing96.. -e "USE practice; SELECT 1 as test_connection;" >nul 2>&1
    if errorlevel 1 (
        echo ❌ practice数据库不存在或无法访问
        echo 💡 是否需要创建practice数据库？
        set /p CREATE_DB="创建practice数据库？(y/n): "
        if /i "%CREATE_DB%"=="y" (
            mysql -h 223.93.139.87 -u root -pLOVEjing96.. -e "CREATE DATABASE IF NOT EXISTS practice;"
            if not errorlevel 1 (
                echo ✅ practice数据库创建成功！
            ) else (
                echo ❌ practice数据库创建失败
            )
        )
    ) else (
        echo ✅ practice数据库连接成功！
        echo 🎉 生产环境数据库完全正常！
    )
)
pause
goto menu

:test_custom
echo.
echo 🧪 测试自定义数据库连接...
set /p CUSTOM_HOST="请输入主机地址 (默认: localhost): "
if "%CUSTOM_HOST%"=="" set CUSTOM_HOST=localhost

set /p CUSTOM_PORT="请输入端口 (默认: 3306): "
if "%CUSTOM_PORT%"=="" set CUSTOM_PORT=3306

set /p CUSTOM_USER="请输入用户名 (默认: root): "
if "%CUSTOM_USER%"=="" set CUSTOM_USER=root

set /p CUSTOM_PASSWORD="请输入密码: "

echo.
echo 测试连接...
mysql -h %CUSTOM_HOST% -P %CUSTOM_PORT% -u %CUSTOM_USER% -p%CUSTOM_PASSWORD% -e "SELECT 1 as test_connection;" >nul 2>&1
if errorlevel 1 (
    echo ❌ 自定义数据库连接失败
) else (
    echo ✅ 自定义数据库连接成功！
)
pause
goto menu

:create_db
echo.
echo 🗄️ 创建practice数据库...
echo 请选择环境：
echo 1. 开发环境 (localhost, 密码: 1234)
echo 2. 生产环境 (223.93.139.87, 密码: LOVEjing96..)
echo 3. 自定义环境
echo.
set /p ENV_CHOICE="请选择环境 (1-3): "

if "%ENV_CHOICE%"=="1" (
    mysql -u root -p1234 -e "CREATE DATABASE IF NOT EXISTS practice;"
    if not errorlevel 1 (
        echo ✅ 开发环境practice数据库创建成功！
    ) else (
        echo ❌ 开发环境practice数据库创建失败
    )
) else if "%ENV_CHOICE%"=="2" (
    mysql -h 223.93.139.87 -u root -pLOVEjing96.. -e "CREATE DATABASE IF NOT EXISTS practice;"
    if not errorlevel 1 (
        echo ✅ 生产环境practice数据库创建成功！
    ) else (
        echo ❌ 生产环境practice数据库创建失败
    )
) else if "%ENV_CHOICE%"=="3" (
    set /p CUSTOM_HOST="请输入主机地址: "
    set /p CUSTOM_USER="请输入用户名: "
    set /p CUSTOM_PASSWORD="请输入密码: "
    mysql -h %CUSTOM_HOST% -u %CUSTOM_USER% -p%CUSTOM_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS practice;"
    if not errorlevel 1 (
        echo ✅ 自定义环境practice数据库创建成功！
    ) else (
        echo ❌ 自定义环境practice数据库创建失败
    )
)
pause
goto menu

:exit
echo.
echo 👋 感谢使用数据库连接测试工具！
exit
