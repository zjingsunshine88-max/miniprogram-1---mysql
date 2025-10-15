@echo off
chcp 65001 >nul
echo 🧪 测试API服务器状态
echo ========================

echo 1. 检查API健康状态...
node check-api-status.js

echo.
echo 2. 测试登录API...
node test-login-simple.js

echo.
echo 测试完成！
pause
