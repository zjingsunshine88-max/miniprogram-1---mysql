@echo off
chcp 65001 >nul
echo ================================================
echo           更新Nginx配置到8443端口
echo ================================================
echo.

:: 设置颜色
color 0B

:: 检查nginx配置文件是否存在
if not exist "nginx-8443.conf" (
    echo [错误] 未找到nginx-8443.conf配置文件
    pause
    exit /b 1
)

:: 检查nginx目录是否存在
if not exist "C:\nginx\conf" (
    echo [错误] 未找到C:\nginx\conf目录，请检查nginx安装路径
    pause
    exit /b 1
)

:: 备份原配置文件
echo [1/4] 备份原配置文件...
if exist "C:\nginx\conf\practice.insightdata.top.conf" (
    copy "C:\nginx\conf\practice.insightdata.top.conf" "C:\nginx\conf\practice.insightdata.top.conf.backup.%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%" >nul
    echo [✓] 原配置文件已备份
) else (
    echo [信息] 原配置文件不存在，将创建新配置
)

:: 复制新配置文件
echo.
echo [2/4] 复制新配置文件...
copy "nginx-8443.conf" "C:\nginx\conf\practice.insightdata.top.conf" >nul
if errorlevel 1 (
    echo [错误] 复制配置文件失败
    pause
    exit /b 1
)
echo [✓] 新配置文件已复制

:: 测试nginx配置
echo.
echo [3/4] 测试nginx配置...
if exist "C:\nginx\nginx.exe" (
    "C:\nginx\nginx.exe" -t
    if errorlevel 1 (
        echo [错误] nginx配置测试失败，请检查配置文件
        pause
        exit /b 1
    )
    echo [✓] nginx配置测试通过
) else (
    echo [警告] 未找到nginx.exe，跳过配置测试
)

:: 重启nginx服务
echo.
echo [4/4] 重启nginx服务...

:: 停止nginx
echo [信息] 正在停止nginx...
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul

:: 启动nginx
echo [信息] 正在启动nginx...
if exist "C:\nginx\nginx.exe" (
    start "" "C:\nginx\nginx.exe"
    timeout /t 3 >nul
    
    :: 检查nginx是否启动成功
    tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo [✓] nginx服务启动成功
    ) else (
        echo [错误] nginx服务启动失败
        pause
        exit /b 1
    )
) else (
    echo [错误] 未找到nginx.exe
    pause
    exit /b 1
)

echo.
echo ================================================
echo           配置更新完成！
echo ================================================
echo.
echo [信息] nginx已配置为8443端口
echo [信息] 访问地址: https://practice.insightdata.top:8443
echo [信息] API地址: https://practice.insightdata.top:8443/api/
echo.
echo [重要] 请确保以下设置:
echo        1. 防火墙开放8443端口
echo        2. 云服务器安全组开放8443端口
echo        3. SSL证书文件存在于指定路径
echo        4. 后端API服务运行在3002端口
echo.

:: 测试连接
echo [信息] 测试8443端口连接...
curl -s -k -o nul -w "HTTP状态码: %%{http_code}" https://localhost:8443 2>nul
if errorlevel 1 (
    echo [警告] 无法连接到8443端口，请检查配置
) else (
    echo [✓] 8443端口连接正常
)

echo.
echo 按任意键退出...
pause >nul
