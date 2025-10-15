# 配置Nginx到系统环境变量
# 使用PowerShell执行，提供更好的错误处理

param(
    [string]$NginxPath,
    [switch]$Force
)

# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "配置Nginx到系统环境变量" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否以管理员身份运行
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[错误] 请以管理员身份运行此脚本" -ForegroundColor Red
    Write-Host "右键点击此文件，选择'以管理员身份运行'" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

Write-Host "[信息] 检测到管理员权限" -ForegroundColor Green
Write-Host ""

# 查找nginx安装路径
if (-not $NginxPath) {
    Write-Host "[信息] 正在查找nginx安装路径..." -ForegroundColor Yellow
    
    # 常见nginx安装路径
    $commonPaths = @(
        "C:\nginx",
        "C:\Program Files\nginx",
        "C:\Program Files (x86)\nginx",
        "D:\nginx",
        "E:\nginx",
        "C:\tools\nginx",
        "C:\apps\nginx"
    )
    
    $foundPath = $null
    foreach ($path in $commonPaths) {
        if (Test-Path "$path\nginx.exe") {
            $foundPath = $path
            Write-Host "[✓] 找到nginx: $path\nginx.exe" -ForegroundColor Green
            break
        }
    }
    
    if (-not $foundPath) {
        Write-Host "[警告] 未找到nginx安装路径" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "请手动输入nginx的安装路径（包含nginx.exe的目录）" -ForegroundColor White
        Write-Host "例如: C:\nginx 或 C:\Program Files\nginx" -ForegroundColor Gray
        Write-Host ""
        $NginxPath = Read-Host "请输入nginx路径"
    } else {
        $NginxPath = $foundPath
    }
}

# 验证nginx路径
if (-not (Test-Path "$NginxPath\nginx.exe")) {
    Write-Host "[错误] 路径 $NginxPath 中未找到nginx.exe" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}

Write-Host "[信息] 使用nginx路径: $NginxPath" -ForegroundColor Green
Write-Host ""

# 获取当前系统PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")

# 检查PATH环境变量中是否已包含nginx路径
if ($currentPath -like "*$NginxPath*") {
    Write-Host "[信息] nginx路径已存在于PATH环境变量中" -ForegroundColor Yellow
    Write-Host "当前PATH中的nginx路径: $NginxPath" -ForegroundColor Gray
} else {
    Write-Host "[信息] 正在添加nginx路径到系统PATH环境变量..." -ForegroundColor Yellow
    
    # 添加nginx路径到PATH
    $newPath = "$currentPath;$NginxPath"
    
    try {
        # 更新系统PATH
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        Write-Host "[✓] nginx路径已成功添加到系统PATH环境变量" -ForegroundColor Green
    } catch {
        Write-Host "[✗] 添加nginx路径到PATH失败: $($_.Exception.Message)" -ForegroundColor Red
        Read-Host "按Enter键退出"
        exit 1
    }
}

Write-Host ""
Write-Host "[信息] 正在验证nginx配置..." -ForegroundColor Yellow

# 测试nginx命令
try {
    $nginxVersion = nginx -v 2>&1
    Write-Host "[✓] nginx命令可用" -ForegroundColor Green
    Write-Host "版本信息: $nginxVersion" -ForegroundColor Gray
} catch {
    Write-Host "[✗] nginx命令不可用，可能需要重启命令行或系统" -ForegroundColor Red
    Write-Host "错误详情: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "配置完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "注意事项:" -ForegroundColor Yellow
Write-Host "1. 如果nginx命令仍然不可用，请重启命令行窗口" -ForegroundColor White
Write-Host "2. 如果重启命令行后仍不可用，请重启系统" -ForegroundColor White
Write-Host "3. 您可以在任何目录下直接使用nginx命令" -ForegroundColor White
Write-Host ""

Write-Host "常用nginx命令:" -ForegroundColor White
Write-Host "  nginx -v                    # 查看版本" -ForegroundColor Green
Write-Host "  nginx -t                    # 测试配置文件" -ForegroundColor Green
Write-Host "  nginx -s reload             # 重新加载配置" -ForegroundColor Green
Write-Host "  nginx -s stop               # 停止nginx" -ForegroundColor Green
Write-Host "  nginx                       # 启动nginx" -ForegroundColor Green
Write-Host ""

Write-Host "使用说明:" -ForegroundColor White
Write-Host "  - 自动检测: .\setup-nginx-path.ps1" -ForegroundColor Green
Write-Host "  - 指定路径: .\setup-nginx-path.ps1 -NginxPath 'C:\nginx'" -ForegroundColor Green
Write-Host "  - 强制更新: .\setup-nginx-path.ps1 -Force" -ForegroundColor Green
Write-Host ""

Read-Host "按Enter键退出"
