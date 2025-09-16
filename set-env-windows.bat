@echo off
chcp 65001 >nul
title 设置Windows环境变量

echo 🔧 设置Windows环境变量...
echo.

echo 📋 当前环境变量：
echo NODE_ENV = %NODE_ENV%
echo.

echo 🔧 设置生产环境变量...
set NODE_ENV=production
set DB_HOST=localhost
set DB_PORT=3306
set DB_NAME=practice
set DB_USERNAME=root
set DB_PASSWORD=LOVEjing96..
set HOST=223.93.139.87
set PORT=3002
set JWT_SECRET=your-super-secret-jwt-key-change-in-production

echo ✅ 环境变量设置完成！
echo.

echo 📋 新的环境变量：
echo NODE_ENV = %NODE_ENV%
echo DB_HOST = %DB_HOST%
echo DB_PORT = %DB_PORT%
echo DB_NAME = %DB_NAME%
echo DB_USERNAME = %DB_USERNAME%
echo HOST = %HOST%
echo PORT = %PORT%
echo.

echo 💡 提示：
echo 1. 这些环境变量仅在当前命令行会话中有效
echo 2. 如需永久设置，请使用系统环境变量设置
echo 3. 或者在每个批处理文件中设置这些变量
echo.

echo 按任意键退出...
pause >nul
