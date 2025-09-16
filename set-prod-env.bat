@echo off
chcp 65001 >nul
title 设置生产环境变量

echo 🔧 设置生产环境变量...
echo.

echo 📋 生产环境配置：
echo NODE_ENV = production
echo DB_HOST = 223.93.139.87
echo DB_PORT = 3306
echo DB_USERNAME = root
echo DB_PASSWORD = LOVEjing96..
echo DB_NAME = practice
echo HOST = 223.93.139.87
echo PORT = 3002
echo.

echo 🔧 设置环境变量...
set NODE_ENV=production
set DB_HOST=223.93.139.87
set DB_PORT=3306
set DB_USERNAME=root
set DB_PASSWORD=LOVEjing96..
set DB_NAME=practice
set HOST=223.93.139.87
set PORT=3002
set JWT_SECRET=your-super-secret-jwt-key-change-in-production
set JWT_EXPIRES_IN=24h
set CORS_ORIGIN=http://223.93.139.87,http://223.93.139.87:3000,http://223.93.139.87:3001

echo ✅ 生产环境变量设置完成！
echo.

echo 📋 新的环境变量：
echo NODE_ENV = %NODE_ENV%
echo DB_HOST = %DB_HOST%
echo DB_PORT = %DB_PORT%
echo DB_USERNAME = %DB_USERNAME%
echo DB_PASSWORD = %DB_PASSWORD%
echo DB_NAME = %DB_NAME%
echo HOST = %HOST%
echo PORT = %PORT%
echo.

echo 💡 提示：
echo 1. 这些环境变量仅在当前命令行会话中有效
echo 2. 启动生产服务器时会自动使用这些配置
echo 3. 数据库密码已设置为: LOVEjing96..
echo.

echo 按任意键退出...
pause >nul
