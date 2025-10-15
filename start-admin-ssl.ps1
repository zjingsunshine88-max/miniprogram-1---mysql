# Admin管理后台SSL启动脚本
# 使用PowerShell执行，提供更好的错误处理

param(
    [switch]$SkipBuild,
    [switch]$Verbose
)

# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "启动Admin管理后台 (SSL版本)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查证书文件
$certPath = "C:\certificates\admin.practice.insightdata.top.pem"
$keyPath = "C:\certificates\admin.practice.insightdata.top.key"

if (-not (Test-Path $certPath)) {
    Write-Host "[错误] SSL证书文件不存在: $certPath" -ForegroundColor Red
    Write-Host "请确保SSL证书已正确配置到C:\certificates目录" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

if (-not (Test-Path $keyPath)) {
    Write-Host "[错误] SSL私钥文件不存在: $keyPath" -ForegroundColor Red
    Write-Host "请确保SSL私钥已正确配置到C:\certificates目录" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

Write-Host "[信息] SSL证书文件检查通过" -ForegroundColor Green
Write-Host ""

# 检查nginx
try {
    $nginxVersion = nginx -v 2>&1
    Write-Host "[信息] nginx已安装: $nginxVersion" -ForegroundColor Green
} catch {
    Write-Host "[错误] nginx未安装或未添加到PATH环境变量" -ForegroundColor Red
    Write-Host "请先安装nginx并添加到系统PATH" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

# 检查Node.js
try {
    $nodeVersion = node --version
    Write-Host "[信息] Node.js已安装: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[错误] Node.js未安装或未添加到PATH环境变量" -ForegroundColor Red
    Write-Host "请先安装Node.js并添加到系统PATH" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

# 检查admin目录
if (-not (Test-Path "admin")) {
    Write-Host "[错误] admin目录不存在" -ForegroundColor Red
    Write-Host "请确保在项目根目录下运行此脚本" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

Write-Host "[信息] 进入admin目录..." -ForegroundColor Yellow
Set-Location admin

# 检查package.json
if (-not (Test-Path "package.json")) {
    Write-Host "[错误] admin/package.json不存在" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}

# 安装依赖
if (-not (Test-Path "node_modules")) {
    Write-Host "[信息] 安装admin依赖..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[错误] 依赖安装失败" -ForegroundColor Red
        Read-Host "按Enter键退出"
        exit 1
    }
}

Write-Host "[信息] 依赖检查完成" -ForegroundColor Green
Write-Host ""

# 构建项目
if (-not $SkipBuild) {
    Write-Host "[信息] 构建admin项目..." -ForegroundColor Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[错误] admin项目构建失败" -ForegroundColor Red
        Read-Host "按Enter键退出"
        exit 1
    }
    Write-Host "[信息] admin项目构建完成" -ForegroundColor Green
} else {
    Write-Host "[信息] 跳过构建步骤" -ForegroundColor Yellow
}

Write-Host ""

# 创建C:\admin目录（如果不存在）
$adminPath = "C:\admin"
if (-not (Test-Path $adminPath)) {
    Write-Host "[信息] 创建C:\admin目录..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $adminPath -Force | Out-Null
}

# 复制dist目录到C:\admin
Write-Host "[信息] 复制构建文件到C:\admin..." -ForegroundColor Yellow
$distPath = Join-Path $PWD "admin\dist"
if (Test-Path $distPath) {
    Copy-Item -Path "$distPath\*" -Destination $adminPath -Recurse -Force
    Write-Host "[✓] 构建文件复制成功" -ForegroundColor Green
} else {
    Write-Host "[错误] dist目录不存在，构建可能失败" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}

# 返回项目根目录
Set-Location ..

# 跳过nginx配置检查，直接启动
Write-Host "[信息] 跳过nginx配置检查，直接启动nginx..." -ForegroundColor Yellow
Write-Host "[信息] 使用系统nginx: C:\nginx\nginx.exe" -ForegroundColor Green
Write-Host ""

# 停止可能正在运行的nginx
Write-Host "[信息] 停止可能正在运行的nginx..." -ForegroundColor Yellow
Get-Process -Name "nginx" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 启动nginx
Write-Host "[信息] 启动nginx (SSL模式)..." -ForegroundColor Yellow
Start-Process -FilePath "nginx" -WindowStyle Normal

# 等待nginx启动
Write-Host "[信息] 等待nginx启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# 检查服务状态
Write-Host "[信息] 检查服务状态..." -ForegroundColor Yellow
Write-Host ""

# 检查C:\admin目录
if (Test-Path "C:\admin\index.html") {
    Write-Host "[✓] Admin静态文件部署成功 (C:\admin)" -ForegroundColor Green
} else {
    Write-Host "[✗] Admin静态文件部署失败" -ForegroundColor Red
}

# 检查nginx
try {
    $response = Invoke-WebRequest -Uri "http://localhost" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[✓] Nginx运行正常 (http://localhost)" -ForegroundColor Green
} catch {
    Write-Host "[✗] Nginx可能未正常启动" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "错误详情: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "启动完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "访问地址:" -ForegroundColor White
Write-Host "  HTTPS: https://admin.practice.insightdate.top" -ForegroundColor Green
Write-Host "  HTTP:  http://admin.practice.insightdate.top (自动重定向到HTTPS)" -ForegroundColor Green
Write-Host ""
Write-Host "本地测试地址:" -ForegroundColor White
Write-Host "  Nginx代理: http://localhost" -ForegroundColor Green
Write-Host ""
Write-Host "部署信息:" -ForegroundColor Yellow
Write-Host "  - 静态文件位置: C:\admin" -ForegroundColor White
Write-Host "  - Admin将调用远程API: https://practice.insightdate.top/api" -ForegroundColor White
Write-Host "  - 请确保远程API服务正常运行" -ForegroundColor White
Write-Host "  - 如需停止服务，请运行 stop-admin-ssl.ps1" -ForegroundColor White
Write-Host ""
Read-Host "按Enter键退出"
