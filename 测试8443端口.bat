@echo off
chcp 65001 >nul
echo ================================================
echo           测试8443端口连接
echo ================================================
echo.

:: 设置颜色
color 0E

echo [1/5] 检查本地8443端口监听状态...
netstat -an | findstr :8443
if errorlevel 1 (
    echo [警告] 本地8443端口未监听
) else (
    echo [✓] 本地8443端口正在监听
)

echo.
echo [2/5] 测试本地8443端口连接...
curl -s -k -o nul -w "HTTP状态码: %%{http_code}" https://localhost:8443 2>nul
if errorlevel 1 (
    echo [错误] 本地8443端口连接失败
) else (
    echo [✓] 本地8443端口连接成功
)

echo.
echo [3/5] 测试外网8443端口连接...
curl -s -k -o nul -w "HTTP状态码: %%{http_code}" https://practice.insightdata.top:8443 2>nul
if errorlevel 1 (
    echo [错误] 外网8443端口连接失败
    echo [信息] 可能的原因:
    echo        1. 防火墙未开放8443端口
    echo        2. 云服务器安全组未开放8443端口
    echo        3. nginx配置错误
    echo        4. SSL证书问题
) else (
    echo [✓] 外网8443端口连接成功
)

echo.
echo [4/5] 测试API接口连接...
curl -s -k -o nul -w "HTTP状态码: %%{http_code}" https://practice.insightdata.top:8443/api/health 2>nul
if errorlevel 1 (
    echo [错误] API接口连接失败
) else (
    echo [✓] API接口连接成功
)

echo.
echo [5/5] 检查防火墙状态...
echo [信息] 检查Windows防火墙规则...
netsh advfirewall firewall show rule name="8443" >nul 2>&1
if errorlevel 1 (
    echo [警告] 未找到8443端口防火墙规则
    echo [建议] 请手动添加防火墙规则:
    echo        netsh advfirewall firewall add rule name="8443" dir=in action=allow protocol=TCP localport=8443
) else (
    echo [✓] 8443端口防火墙规则已存在
)

echo.
echo ================================================
echo           测试完成
echo ================================================
echo.
echo [信息] 如果外网无法访问8443端口，请检查:
echo.
echo 1. 云服务器安全组设置:
echo    - 入方向规则: 端口8443, 协议TCP, 源0.0.0.0/0
echo.
echo 2. Windows防火墙设置:
echo    - 运行: netsh advfirewall firewall add rule name="8443" dir=in action=allow protocol=TCP localport=8443
echo.
echo 3. nginx配置检查:
echo    - 确认nginx-8443.conf已正确复制到C:\nginx\conf\
echo    - 确认SSL证书文件存在且路径正确
echo.
echo 4. 后端服务检查:
echo    - 确认API服务运行在3002端口
echo    - 确认数据库连接正常
echo.

:: 提供快速修复选项
set /p fix="是否自动添加防火墙规则? (Y/N): "
if /i "%fix%"=="Y" (
    echo [信息] 正在添加防火墙规则...
    netsh advfirewall firewall add rule name="8443" dir=in action=allow protocol=TCP localport=8443
    if errorlevel 1 (
        echo [错误] 添加防火墙规则失败，请以管理员身份运行
    ) else (
        echo [✓] 防火墙规则添加成功
    )
)

echo.
echo 按任意键退出...
pause >nul
