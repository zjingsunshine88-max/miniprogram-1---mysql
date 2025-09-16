@echo off
chcp 65001 >nul
title 测试MySQL连接

echo 🧪 测试MySQL数据库连接...
echo.

REM 检查MySQL是否安装
mysql --version >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL命令行工具未找到
    echo 💡 请确保MySQL已安装并添加到PATH环境变量
    pause
    exit /b 1
)

echo ✅ MySQL命令行工具已找到
echo.

REM 测试不同的密码组合
echo 🔑 测试密码连接...

echo 测试1: 空密码...
mysql -u root -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 空密码连接成功！
    goto show_databases
)

echo 测试2: 默认密码 LOVEjing96.. ...
mysql -u root -pLOVEjing96.. -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 默认密码连接成功！
    goto show_databases
)

echo 测试3: 常见密码 root ...
mysql -u root -proot -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 密码 'root' 连接成功！
    goto show_databases
)

echo 测试4: 常见密码 123456 ...
mysql -u root -p123456 -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 密码 '123456' 连接成功！
    goto show_databases
)

echo ❌ 所有测试密码都失败
echo.
echo 💡 请手动输入正确的MySQL root密码：
set /p MYSQL_PASSWORD="请输入MySQL root密码: "
if not "%MYSQL_PASSWORD%"=="" (
    mysql -u root -p%MYSQL_PASSWORD% -e "SELECT 1;" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ 密码验证成功！
        goto show_databases
    ) else (
        echo ❌ 密码仍然不正确
        goto end
    )
) else (
    echo ❌ 未输入密码
    goto end
)

:show_databases
echo.
echo 📊 显示数据库列表：
mysql -u root -p%MYSQL_PASSWORD% -e "SHOW DATABASES;"

echo.
echo 🔍 检查practice数据库：
mysql -u root -p%MYSQL_PASSWORD% -e "SHOW DATABASES LIKE 'practice';" | findstr "practice" >nul
if errorlevel 1 (
    echo ❌ practice数据库不存在
    echo 💡 创建practice数据库...
    mysql -u root -p%MYSQL_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS practice;"
    if not errorlevel 1 (
        echo ✅ practice数据库创建成功！
    ) else (
        echo ❌ practice数据库创建失败
    )
) else (
    echo ✅ practice数据库已存在
)

echo.
echo 🧪 测试完整连接（使用practice数据库）：
mysql -u root -p%MYSQL_PASSWORD% -e "USE practice; SELECT 1 as test_connection;" 2>nul
if errorlevel 1 (
    echo ❌ 完整连接测试失败
) else (
    echo ✅ 完整连接测试成功！
    echo.
    echo 🎉 MySQL连接正常！
    echo 💡 可以启动服务器了
)

:end
echo.
echo 按任意键退出...
pause >nul
