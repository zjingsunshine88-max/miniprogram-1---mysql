@echo off
chcp 65001 >nul
title 更新数据库配置

echo 🔧 更新数据库配置...
echo.

echo 📋 当前数据库配置：
echo 主机: localhost
echo 端口: 3306
echo 用户名: root
echo 密码: LOVEjing96..
echo 数据库: practice
echo.

echo 💡 如果需要修改配置，请选择操作：
echo 1. 更新密码
echo 2. 更新主机地址
echo 3. 更新端口
echo 4. 更新数据库名
echo 5. 测试当前配置
echo 0. 退出
echo.

set /p choice="请选择操作 (0-5): "

if "%choice%"=="1" goto update_password
if "%choice%"=="2" goto update_host
if "%choice%"=="3" goto update_port
if "%choice%"=="4" goto update_database
if "%choice%"=="5" goto test_config
if "%choice%"=="0" goto exit
goto menu

:update_password
echo.
echo 🔑 更新数据库密码...
set /p NEW_PASSWORD="请输入新的MySQL密码: "
if not "%NEW_PASSWORD%"=="" (
    echo 测试新密码...
    mysql -u root -p%NEW_PASSWORD% -e "SELECT 1;" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ 密码验证成功！
        echo 更新配置文件...
        REM 这里可以添加更新配置文件的代码
        echo 💡 请手动更新 server/config/database.js 中的密码
    ) else (
        echo ❌ 密码验证失败
    )
)
pause
goto menu

:update_host
echo.
echo 🏠 更新主机地址...
set /p NEW_HOST="请输入新的主机地址 (当前: localhost): "
if not "%NEW_HOST%"=="" (
    echo 测试新主机地址...
    mysql -h %NEW_HOST% -u root -pLOVEjing96.. -e "SELECT 1;" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ 主机地址验证成功！
        echo 💡 请手动更新 server/config/database.js 中的主机地址
    ) else (
        echo ❌ 主机地址验证失败
    )
)
pause
goto menu

:update_port
echo.
echo 🔌 更新端口...
set /p NEW_PORT="请输入新的端口 (当前: 3306): "
if not "%NEW_PORT%"=="" (
    echo 测试新端口...
    mysql -P %NEW_PORT% -u root -pLOVEjing96.. -e "SELECT 1;" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ 端口验证成功！
        echo 💡 请手动更新 server/config/database.js 中的端口
    ) else (
        echo ❌ 端口验证失败
    )
)
pause
goto menu

:update_database
echo.
echo 🗄️ 更新数据库名...
set /p NEW_DATABASE="请输入新的数据库名 (当前: practice): "
if not "%NEW_DATABASE%"=="" (
    echo 测试新数据库...
    mysql -u root -pLOVEjing96.. -e "USE %NEW_DATABASE%; SELECT 1;" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ 数据库验证成功！
        echo 💡 请手动更新 server/config/database.js 中的数据库名
    ) else (
        echo ❌ 数据库验证失败
        echo 💡 数据库可能不存在，是否创建？
        set /p CREATE_DB="创建数据库 %NEW_DATABASE%？(y/n): "
        if /i "%CREATE_DB%"=="y" (
            mysql -u root -pLOVEjing96.. -e "CREATE DATABASE IF NOT EXISTS %NEW_DATABASE%;"
            if not errorlevel 1 (
                echo ✅ 数据库创建成功！
            ) else (
                echo ❌ 数据库创建失败
            )
        )
    )
)
pause
goto menu

:test_config
echo.
echo 🧪 测试当前配置...
echo 测试连接...
mysql -u root -pLOVEjing96.. -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 基本连接成功！
    echo 测试practice数据库...
    mysql -u root -pLOVEjing96.. -e "USE practice; SELECT 1;" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ practice数据库连接成功！
        echo 🎉 当前配置完全正常！
    ) else (
        echo ❌ practice数据库连接失败
        echo 💡 可能数据库不存在，是否创建？
        set /p CREATE_PRACTICE="创建practice数据库？(y/n): "
        if /i "%CREATE_PRACTICE%"=="y" (
            mysql -u root -pLOVEjing96.. -e "CREATE DATABASE IF NOT EXISTS practice;"
            if not errorlevel 1 (
                echo ✅ practice数据库创建成功！
            ) else (
                echo ❌ practice数据库创建失败
            )
        )
    )
) else (
    echo ❌ 基本连接失败
    echo 💡 请检查MySQL服务状态和密码
)
pause
goto menu

:exit
echo.
echo 👋 感谢使用数据库配置工具！
exit
