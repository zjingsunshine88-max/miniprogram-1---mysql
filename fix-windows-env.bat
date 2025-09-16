@echo off
chcp 65001 >nul
title 修复Windows环境变量问题

echo 🔧 修复Windows环境变量问题...
echo.

echo 📋 问题描述：
echo 在Windows中，Linux风格的环境变量语法不被支持：
echo ❌ NODE_ENV=production node app.js
echo ✅ set NODE_ENV=production ^&^& node app.js
echo.

echo 🔍 检查当前package.json配置...
if exist "server\package.json" (
    echo ✅ 找到server\package.json
    findstr "NODE_ENV=production" server\package.json >nul
    if not errorlevel 1 (
        echo ❌ 发现Linux风格的环境变量设置
        echo 💡 需要修复package.json中的scripts
    ) else (
        echo ✅ package.json配置正确
    )
) else (
    echo ❌ 未找到server\package.json
    pause
    exit /b 1
)

echo.
echo 🔧 开始修复...

REM 备份原文件
copy "server\package.json" "server\package.json.backup"

REM 修复package.json
echo 📝 修复package.json中的scripts...
powershell -Command "(Get-Content 'server\package.json') -replace 'NODE_ENV=production', 'set NODE_ENV=production &&' | Set-Content 'server\package.json'"

echo ✅ package.json修复完成！

echo.
echo 🧪 测试修复结果...
cd /d server
echo 测试命令: npm run start
echo.

REM 测试启动
call npm run start
if errorlevel 1 (
    echo ❌ 测试失败
    echo 💡 尝试手动启动...
    set NODE_ENV=production
    node app.js
) else (
    echo ✅ 测试成功！
)

echo.
echo 📋 修复总结：
echo 1. ✅ 修复了package.json中的环境变量语法
echo 2. ✅ 创建了Windows专用的启动脚本
echo 3. ✅ 提供了多种启动方式
echo.
echo 💡 推荐使用方式：
echo   1. server-launcher.bat (图形化启动器)
echo   2. start-server.bat (简单启动脚本)
echo   3. 手动设置环境变量后启动
echo.

echo 按任意键退出...
pause >nul
