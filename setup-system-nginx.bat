@echo off
chcp 65001 >nul
echo ========================================
echo 配置系统Nginx SSL
echo ========================================
echo.

:: 检查是否以管理员身份运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本
    echo 右键点击此文件，选择"以管理员身份运行"
    pause
    exit /b 1
)

echo [信息] 检测到管理员权限
echo.

:: 检查系统nginx是否存在
if not exist "C:\nginx\conf\nginx.conf" (
    echo [错误] 系统nginx配置文件不存在: C:\nginx\conf\nginx.conf
    echo 请确保nginx已正确安装到C:\nginx目录
    pause
    exit /b 1
)

echo [✓] 系统nginx配置文件存在
echo.

:: 备份原始配置文件
echo [信息] 备份原始nginx配置文件...
if not exist "C:\nginx\conf\nginx.conf.backup" (
    copy "C:\nginx\conf\nginx.conf" "C:\nginx\conf\nginx.conf.backup" >nul
    echo [✓] 已备份原始配置文件到 nginx.conf.backup
) else (
    echo [信息] 备份文件已存在，跳过备份
)

:: 创建SSL配置目录
if not exist "C:\nginx\conf.d" (
    echo [信息] 创建conf.d目录...
    mkdir "C:\nginx\conf.d"
)

:: 复制SSL配置文件到系统nginx
echo [信息] 复制SSL配置文件到系统nginx...
copy "%~dp0nginx\conf.d\admin-ssl.conf" "C:\nginx\conf.d\admin-ssl.conf" >nul
if %errorlevel% equ 0 (
    echo [✓] SSL配置文件复制成功
) else (
    echo [✗] SSL配置文件复制失败
    pause
    exit /b 1
)

:: 检查系统nginx主配置文件是否包含conf.d
findstr /i "conf.d" "C:\nginx\conf\nginx.conf" >nul
if %errorlevel% neq 0 (
    echo [信息] 系统nginx配置中未找到conf.d包含，正在添加...
    
    :: 备份当前配置
    copy "C:\nginx\conf\nginx.conf" "C:\nginx\conf\nginx.conf.temp" >nul
    
    :: 在http块中添加conf.d包含
    powershell -Command "(Get-Content 'C:\nginx\conf\nginx.conf') -replace '(http\s*\{)', '$1`n    include conf.d/*.conf;' | Set-Content 'C:\nginx\conf\nginx.conf'"
    
    if %errorlevel% equ 0 (
        echo [✓] 已添加conf.d包含到系统nginx配置
    ) else (
        echo [✗] 添加conf.d包含失败，恢复备份
        copy "C:\nginx\conf\nginx.conf.temp" "C:\nginx\conf\nginx.conf" >nul
        del "C:\nginx\conf\nginx.conf.temp" >nul
        pause
        exit /b 1
    )
    
    del "C:\nginx\conf\nginx.conf.temp" >nul
) else (
    echo [✓] 系统nginx配置已包含conf.d
)

:: 测试nginx配置
echo [信息] 测试nginx配置...
nginx -t
if %errorlevel% equ 0 (
    echo [✓] nginx配置测试通过
) else (
    echo [✗] nginx配置测试失败
    echo 请检查配置文件
    pause
    exit /b 1
)

echo.
echo ========================================
echo 系统Nginx配置完成！
echo ========================================
echo.
echo 配置信息:
echo   - 系统nginx路径: C:\nginx
echo   - 配置文件: C:\nginx\conf\nginx.conf
echo   - SSL配置: C:\nginx\conf.d\admin-ssl.conf
echo   - 备份文件: C:\nginx\conf\nginx.conf.backup
echo.
echo 现在可以运行 start-admin-ssl.bat 启动服务
echo.
echo 按任意键退出...
pause >nul
