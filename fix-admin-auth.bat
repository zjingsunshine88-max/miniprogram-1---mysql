@echo off
chcp 65001 >nul
title 修复管理员认证问题

echo 🔧 修复管理员认证问题...
echo.

echo 📋 问题分析：
echo ❌ 错误: 401 Unauthorized
echo 💡 原因: 后台管理系统需要管理员登录认证
echo.

echo 🔍 开始诊断和修复...
echo.

REM 进入server目录
cd /d "%~dp0server"

REM 1. 检查数据库连接
echo 步骤1: 检查数据库连接...
set NODE_ENV=development
set DB_PASSWORD=1234

node -e "
const { sequelize } = require('./config/database');
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ 数据库连接成功');
    process.exit(0);
  } catch (error) {
    console.log('❌ 数据库连接失败:', error.message);
    process.exit(1);
  }
};
testConnection();
"

if errorlevel 1 (
    echo ❌ 数据库连接失败，请先解决数据库连接问题
    echo 💡 运行: test-db-connection.bat
    pause
    exit /b 1
)

echo ✅ 数据库连接正常
echo.

REM 2. 初始化管理员用户
echo 步骤2: 初始化管理员用户...
echo 运行管理员初始化脚本...
node scripts/init-admin.js

if errorlevel 1 (
    echo ❌ 管理员初始化失败
    pause
    exit /b 1
)

echo ✅ 管理员用户初始化完成
echo.

REM 3. 创建管理员登录脚本
echo 步骤3: 创建管理员登录测试脚本...
echo import { adminAPI } from './src/api/admin.js' > test-admin-login.js
echo. >> test-admin-login.js
echo // 测试管理员登录 >> test-admin-login.js
echo const testLogin = async () =^> { >> test-admin-login.js
echo   try { >> test-admin-login.js
echo     const result = await adminAPI.login({ >> test-admin-login.js
echo       phoneNumber: '13800138000', >> test-admin-login.js
echo       password: '' // 管理员默认无密码 >> test-admin-login.js
echo     }); >> test-admin-login.js
echo     console.log('✅ 管理员登录成功:', result); >> test-admin-login.js
echo   } catch (error) { >> test-admin-login.js
echo     console.error('❌ 管理员登录失败:', error.message); >> test-admin-login.js
echo   } >> test-admin-login.js
echo }; >> test-admin-login.js
echo. >> test-admin-login.js
echo testLogin(); >> test-admin-login.js

echo ✅ 测试脚本创建完成
echo.

REM 4. 显示管理员信息
echo 步骤4: 显示管理员信息...
echo 📋 默认管理员账户：
echo    手机号: 13800138000
echo    昵称: 系统管理员
echo    密码: (无密码，直接登录)
echo.

REM 5. 创建快速登录脚本
echo 步骤5: 创建快速登录脚本...
echo @echo off > admin-quick-login.bat
echo chcp 65001 ^>nul >> admin-quick-login.bat
echo title 管理员快速登录 >> admin-quick-login.bat
echo. >> admin-quick-login.bat
echo echo 🔑 管理员快速登录 >> admin-quick-login.bat
echo echo. >> admin-quick-login.bat
echo echo 📋 默认管理员账户： >> admin-quick-login.bat
echo echo    手机号: 13800138000 >> admin-quick-login.bat
echo echo    昵称: 系统管理员 >> admin-quick-login.bat
echo echo    密码: (无密码，直接登录) >> admin-quick-login.bat
echo echo. >> admin-quick-login.bat
echo echo 💡 请在后台管理系统中使用以上信息登录 >> admin-quick-login.bat
echo echo. >> admin-quick-login.bat
echo pause >> admin-quick-login.bat

echo ✅ 快速登录脚本创建完成
echo.

echo 🎉 管理员认证问题修复完成！
echo.
echo 📋 解决方案总结：
echo 1. ✅ 数据库连接正常
echo 2. ✅ 管理员用户已创建
echo 3. ✅ 测试脚本已准备
echo 4. ✅ 快速登录脚本已创建
echo.
echo 🔑 管理员登录信息：
echo    手机号: 13800138000
echo    昵称: 系统管理员
echo    密码: (无密码，直接登录)
echo.
echo 💡 下一步操作：
echo 1. 启动后台管理系统: start-admin.bat
echo 2. 使用管理员账户登录
echo 3. 如果仍有问题，运行: admin-quick-login.bat
echo.

echo 按任意键退出...
pause >nul
