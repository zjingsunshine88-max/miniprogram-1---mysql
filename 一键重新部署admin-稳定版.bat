@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title 一键重新部署Admin和API服务

echo ================================================
echo           一键重新部署Admin和API服务
echo ================================================
echo.

:: 设置错误处理
set "ERROR_OCCURRED=0"

:: 检查是否在正确的目录
echo [检查] 验证项目目录...
if not exist "admin\package.json" (
    echo [错误] 未找到admin\package.json文件
    echo [信息] 当前目录: %CD%
    echo [信息] 请确保在项目根目录运行此脚本
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] 项目目录验证通过

:: 检查Node.js环境
echo.
echo [检查] Node.js环境...
where node >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到Node.js
    echo [信息] 请先安装Node.js: https://nodejs.org/
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] Node.js已安装

:: 检查npm环境
echo [检查] npm环境...
where npm >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到npm
    echo [信息] 请重新安装Node.js
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] npm已安装

:: 进入admin目录
echo.
echo [操作] 进入admin目录...
pushd admin
if errorlevel 1 (
    echo [错误] 无法进入admin目录
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)

:: 安装依赖
echo.
echo [操作] 检查依赖...
if not exist "node_modules" (
    echo [信息] 正在安装依赖，请稍候...
    call npm install --silent
    if errorlevel 1 (
        echo [错误] 依赖安装失败
        set "ERROR_OCCURRED=1"
        goto :ERROR_HANDLER
    )
    echo [✓] 依赖安装完成
) else (
    echo [✓] 依赖已存在
)

:: 构建项目
echo.
echo [操作] 构建项目...
echo [信息] 正在构建生产版本，请稍候...
call npm run build
if errorlevel 1 (
    echo [错误] 构建失败
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)

:: 检查构建结果
if not exist "dist" (
    echo [错误] 构建后未找到dist目录
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] 构建完成

:: 返回项目根目录
popd

:: 创建目标目录
echo.
echo [操作] 准备目标目录...
if not exist "C:\admin" (
    mkdir "C:\admin" 2>nul
    if errorlevel 1 (
        echo [错误] 无法创建C:\admin目录
        set "ERROR_OCCURRED=1"
        goto :ERROR_HANDLER
    )
    echo [信息] 创建目录: C:\admin
)

:: 复制文件
echo.
echo [操作] 复制文件...
if exist "C:\admin\dist" (
    rmdir /s /q "C:\admin\dist" 2>nul
)
xcopy "admin\dist" "C:\admin\dist\" /E /I /Q /Y >nul
if errorlevel 1 (
    echo [错误] 文件复制失败
    set "ERROR_OCCURRED=1"
    goto :ERROR_HANDLER
)
echo [✓] 文件复制完成

:: 检查复制结果
if not exist "C:\admin\dist\index.html" (
    echo [警告] 复制可能不完整，未找到index.html
)

:: 启动API服务
echo.
echo [操作] 启动API服务...
echo [信息] 检查API服务状态...

:: 检查是否已有API服务在运行
netstat -an | findstr ":3002" >nul
if "%ERRORLEVEL%"=="0" (
    echo [信息] API服务已在运行
) else (
    echo [信息] 正在启动API服务...
    
    :: 检查启动脚本
    if exist "start-server.bat" (
        echo [信息] 使用start-server.bat启动API服务...
        start "" "start-server.bat"
        timeout /t 5 >nul
        
        :: 检查API服务是否启动成功
        netstat -an | findstr ":3002" >nul
        if "%ERRORLEVEL%"=="0" (
            echo [✓] API服务启动成功
        ) else (
            echo [警告] API服务可能未正常启动
        )
    ) else if exist "server\package.json" (
        echo [信息] 直接启动server目录下的API服务...
        pushd server
        start "" cmd /c "npm start"
        popd
        timeout /t 5 >nul
        
        :: 检查API服务是否启动成功
        netstat -an | findstr ":3002" >nul
        if "%ERRORLEVEL%"=="0" (
            echo [✓] API服务启动成功
        ) else (
            echo [警告] API服务可能未正常启动
        )
    ) else (
        echo [警告] 未找到API服务启动脚本
        echo [信息] 请手动启动API服务
    )
)

:: 重启nginx
echo.
echo [操作] 重启nginx服务...
echo [信息] 正在停止nginx...
taskkill /F /IM nginx.exe >nul 2>&1
timeout /t 2 >nul

echo [信息] 正在启动nginx...
if exist "C:\nginx\nginx.exe" (
    start "" "C:\nginx\nginx.exe"
    timeout /t 3 >nul
    
    :: 检查nginx是否启动成功
    tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
    if errorlevel 1 (
        echo [警告] nginx可能未正常启动
    ) else (
        echo [✓] nginx已启动
    )
) else (
    echo [警告] 未找到nginx.exe
    echo [信息] 请手动启动nginx: C:\nginx\nginx.exe
)

:: 测试服务
echo.
echo [测试] 检查服务状态...
timeout /t 2 >nul

:: 测试API连接
curl -s -o nul -w "API状态: %%{http_code}" http://localhost:3002/api/health 2>nul
if errorlevel 1 (
    echo [警告] API服务可能未运行
) else (
    echo [✓] API服务正常
)

echo.
echo ================================================
echo           部署完成！
echo ================================================
echo.
echo [信息] Admin管理后台: C:\admin\dist
echo [信息] API服务: 3002端口
echo [信息] 访问地址: https://practice.insightdata.top:8443
echo [信息] API地址: https://practice.insightdata.top:8443/api/
echo.
echo [提示] 服务状态:
echo        - Admin前端: 已部署到C:\admin\dist
echo        - API后端: 已启动在3002端口
echo        - Nginx代理: 已配置8443端口
echo.

:: 询问是否打开浏览器
set /p choice="是否打开浏览器测试? (Y/N): "
if /i "%choice%"=="Y" (
    start "" "https://practice.insightdata.top:8443"
)

echo.
echo 按任意键退出...
pause >nul
exit /b 0

:ERROR_HANDLER
echo.
echo ================================================
echo           部署失败！
echo ================================================
echo.
echo [错误] 部署过程中发生错误
echo [信息] 请检查上述错误信息并重试
echo.
echo 按任意键退出...
pause >nul
exit /b 1
