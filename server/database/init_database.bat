@echo off
echo ========================================
echo 刷题小程序数据库初始化脚本
echo ========================================
echo.

echo 正在初始化数据库...
echo.

REM 检查MySQL是否可用
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到MySQL命令，请确保MySQL已安装并添加到PATH环境变量
    echo.
    echo 请检查以下内容:
    echo 1. MySQL是否已安装
    echo 2. MySQL bin目录是否已添加到PATH环境变量
    echo 3. MySQL服务是否已启动
    echo.
    pause
    exit /b 1
)

echo MySQL已找到，开始初始化数据库...
echo.

REM 提示用户输入MySQL root密码
set /p mysql_password="请输入MySQL root密码 (如果没有密码请直接按回车): "

echo.
echo 正在创建数据库和表结构...

REM 执行SQL文件
if "%mysql_password%"=="" (
    mysql -u root < init_database.sql
) else (
    mysql -u root -p%mysql_password% < init_database.sql
)

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 数据库初始化成功！
    echo ========================================
    echo.
    echo 数据库信息:
    echo - 数据库名: practice
    echo - 默认管理员手机号: 13800138000
    echo - 示例题目: 5道
    echo.
    echo 接下来可以:
    echo 1. 启动服务器: npm start
    echo 2. 测试API: http://localhost:3002/health
    echo 3. 访问管理后台进行题目管理
    echo.
) else (
    echo.
    echo ========================================
    echo 数据库初始化失败！
    echo ========================================
    echo.
    echo 可能的原因:
    echo 1. MySQL密码错误
    echo 2. MySQL服务未启动
    echo 3. 权限不足
    echo 4. 数据库已存在且有冲突
    echo.
    echo 请检查错误信息并重试
    echo.
)

echo 按任意键退出...
pause >nul
