@echo off
chcp 65001 >nul
echo 🔧 修复题目上传权限问题
echo ========================

echo 检查Node.js安装...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未检测到Node.js，请先安装Node.js
    pause
    exit /b 1
)

echo ✅ Node.js已安装，版本：
node --version

echo.
echo 🔧 开始修复题目上传权限问题...
echo.

node fix-upload-permission.js

echo.
echo 🎉 修复完成！
echo.
echo 📝 如果权限问题仍然存在，请手动执行：
echo 1. 在宝塔面板文件管理器中创建 temp 目录
echo 2. 设置目录权限为 755
echo 3. 重启API服务
echo.
pause
