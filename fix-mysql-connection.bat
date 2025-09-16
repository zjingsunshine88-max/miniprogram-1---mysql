@echo off
chcp 65001 >nul
title 修复MySQL数据库连接问题

echo 🔧 修复MySQL数据库连接问题...
echo.

echo 📋 问题诊断：
echo ❌ 错误: Access denied for user 'root'@'localhost' (using password: YES)
echo 💡 可能原因：
echo    1. MySQL服务未启动
echo    2. 数据库密码不正确
echo    3. 用户权限问题
echo    4. 数据库不存在
echo.

echo 🔍 开始诊断...
echo.

REM 1. 检查MySQL服务状态
echo 步骤1: 检查MySQL服务状态...
sc query mysql >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL服务未安装或未找到
    echo 💡 请先安装MySQL: https://dev.mysql.com/downloads/mysql/
    goto install_mysql
) else (
    echo ✅ MySQL服务已安装
)

REM 检查服务是否运行
sc query mysql | findstr "RUNNING" >nul
if errorlevel 1 (
    echo ⚠️  MySQL服务未运行，正在启动...
    net start mysql
    if errorlevel 1 (
        echo ❌ MySQL服务启动失败
        echo 💡 请手动启动MySQL服务或检查配置
        goto manual_start
    ) else (
        echo ✅ MySQL服务启动成功
    )
) else (
    echo ✅ MySQL服务正在运行
)

echo.
echo 步骤2: 测试数据库连接...
cd /d server

REM 测试默认密码连接
echo 测试密码: LOVEjing96..
mysql -u root -pLOVEjing96.. -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo ❌ 使用默认密码连接失败
    goto password_issue
) else (
    echo ✅ 使用默认密码连接成功
    goto check_database
)

:password_issue
echo.
echo 🔑 密码问题诊断...
echo 可能的原因：
echo 1. 密码不正确
echo 2. 用户不存在
echo 3. 权限问题
echo.

set /p RESET_PASSWORD="是否要重置MySQL密码？(y/n): "
if /i "%RESET_PASSWORD%"=="y" (
    goto reset_password
) else (
    set /p NEW_PASSWORD="请输入正确的MySQL root密码: "
    if not "%NEW_PASSWORD%"=="" (
        mysql -u root -p%NEW_PASSWORD% -e "SELECT 1;" >nul 2>&1
        if not errorlevel 1 (
            echo ✅ 密码验证成功！
            echo 💡 请更新配置文件中的密码
            goto update_config
        ) else (
            echo ❌ 密码仍然不正确
        )
    )
)

echo.
echo 🔧 尝试其他解决方案...
goto other_solutions

:reset_password
echo.
echo 🔑 重置MySQL密码...
echo 注意：这将重置MySQL root密码为: LOVEjing96..
echo.
set /p CONFIRM="确认重置密码？(y/n): "
if /i "%CONFIRM%"=="y" (
    echo 停止MySQL服务...
    net stop mysql
    
    echo 以跳过权限表模式启动MySQL...
    mysqld --skip-grant-tables --console &
    
    echo 等待MySQL启动...
    timeout /t 5 /nobreak >nul
    
    echo 重置密码...
    mysql -u root -e "USE mysql; UPDATE user SET authentication_string=PASSWORD('LOVEjing96..') WHERE User='root'; FLUSH PRIVILEGES;"
    
    echo 重启MySQL服务...
    taskkill /f /im mysqld.exe >nul 2>&1
    net start mysql
    
    echo ✅ 密码重置完成！
    goto check_database
) else (
    echo 取消密码重置
)

:check_database
echo.
echo 步骤3: 检查数据库是否存在...
mysql -u root -pLOVEjing96.. -e "SHOW DATABASES LIKE 'practice';" | findstr "practice" >nul
if errorlevel 1 (
    echo ❌ 数据库 'practice' 不存在
    echo 💡 正在创建数据库...
    mysql -u root -pLOVEjing96.. -e "CREATE DATABASE IF NOT EXISTS practice;"
    if errorlevel 1 (
        echo ❌ 数据库创建失败
    ) else (
        echo ✅ 数据库 'practice' 创建成功
    )
) else (
    echo ✅ 数据库 'practice' 已存在
)

echo.
echo 步骤4: 测试完整连接...
mysql -u root -pLOVEjing96.. -e "USE practice; SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo ❌ 完整连接测试失败
) else (
    echo ✅ 完整连接测试成功！
    echo.
    echo 🎉 数据库连接问题已解决！
    echo 💡 现在可以启动服务器了
)

goto end

:update_config
echo.
echo 📝 更新配置文件...
echo 请在 server/config/database.js 中更新密码为: %NEW_PASSWORD%
pause
goto end

:install_mysql
echo.
echo 📥 MySQL安装指南：
echo 1. 访问: https://dev.mysql.com/downloads/mysql/
echo 2. 下载MySQL Community Server
echo 3. 安装时设置root密码为: LOVEjing96..
echo 4. 完成安装后重新运行此脚本
pause
goto end

:manual_start
echo.
echo 🔧 手动启动MySQL服务：
echo 1. 打开服务管理器 (services.msc)
echo 2. 找到MySQL服务
echo 3. 右键启动服务
echo 4. 或使用命令: net start mysql
pause
goto end

:other_solutions
echo.
echo 🔧 其他解决方案：
echo 1. 检查MySQL配置文件 my.ini 或 my.cnf
echo 2. 确认bind-address设置
echo 3. 检查防火墙设置
echo 4. 尝试使用localhost或127.0.0.1
echo 5. 检查MySQL端口3306是否被占用
echo.
echo 💡 推荐操作：
echo 1. 重新安装MySQL
echo 2. 使用默认密码: LOVEjing96..
echo 3. 确保服务正常启动
echo.

:end
echo.
echo 📋 诊断完成！
echo.
echo 💡 如果问题仍然存在，请尝试：
echo 1. 重新安装MySQL
echo 2. 检查防火墙设置
echo 3. 确认MySQL服务正常启动
echo 4. 验证用户权限
echo.
echo 按任意键退出...
pause >nul
