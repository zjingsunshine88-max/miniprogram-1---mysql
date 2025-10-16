@echo off
chcp 65001 >nul
echo 🔧 初始化Git仓库并配置.gitignore
echo =====================================

echo 检查Git安装...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未检测到Git，请先安装Git
    echo 📥 下载地址：https://git-scm.com/
    pause
    exit /b 1
)

echo ✅ Git已安装，版本：
git --version

echo.
echo 🔧 初始化Git仓库...
git init

echo.
echo 📝 添加.gitignore文件...
git add .gitignore

echo.
echo 📊 检查node_modules目录...
if exist "admin\node_modules" (
    echo ✅ admin/node_modules 存在
)
if exist "server\node_modules" (
    echo ✅ server/node_modules 存在
)

echo.
echo 💡 提示：
echo 1. .gitignore文件已创建并配置
echo 2. admin/node_modules 和 server/node_modules 已被忽略
echo 3. 现在可以安全地提交代码，不会提交node_modules
echo.
echo 下一步操作：
echo   git add .
echo   git commit -m "Initial commit"
echo   git remote add origin <your-repository-url>
echo   git push -u origin main
echo.
pause
