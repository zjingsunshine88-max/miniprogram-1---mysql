@echo off
chcp 65001 >nul
echo ========================================
echo 停止Admin管理后台服务
echo ========================================
echo.

echo [信息] 停止nginx服务...
taskkill /f /im nginx.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] nginx服务已停止
) else (
    echo [信息] nginx服务未运行或已停止
)

echo.
echo [信息] 检查admin静态文件...
if exist "C:\admin\index.html" (
    echo [✓] Admin静态文件存在于C:\admin
) else (
    echo [信息] Admin静态文件不存在
)

echo.
echo [信息] 清理可能残留的进程...
:: 停止所有node进程（谨慎使用）
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq node.exe" /fo csv ^| find "node.exe"') do (
    echo [信息] 发现node进程: %%i
)

echo.
echo ========================================
echo 服务停止完成！
echo ========================================
echo.
echo 按任意键退出...
pause >nul
