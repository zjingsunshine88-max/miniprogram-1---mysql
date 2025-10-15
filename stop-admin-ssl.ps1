# Admin管理后台SSL停止脚本
# 使用PowerShell执行，提供更好的进程管理

param(
    [switch]$Force,
    [switch]$Verbose
)

# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "停止Admin管理后台服务" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 停止nginx服务
Write-Host "[信息] 停止nginx服务..." -ForegroundColor Yellow
$nginxProcesses = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
if ($nginxProcesses) {
    $nginxProcesses | Stop-Process -Force
    Write-Host "[✓] nginx服务已停止 (共 $($nginxProcesses.Count) 个进程)" -ForegroundColor Green
} else {
    Write-Host "[信息] nginx服务未运行或已停止" -ForegroundColor Yellow
}

Write-Host ""

# 检查admin静态文件
Write-Host "[信息] 检查admin静态文件..." -ForegroundColor Yellow
if (Test-Path "C:\admin\index.html") {
    Write-Host "[✓] Admin静态文件存在于C:\admin" -ForegroundColor Green
} else {
    Write-Host "[信息] Admin静态文件不存在" -ForegroundColor Yellow
}

Write-Host ""

# 清理可能残留的进程
Write-Host "[信息] 检查可能残留的进程..." -ForegroundColor Yellow

# 检查其他可能相关的进程
$relatedProcesses = @("vite", "npm")
foreach ($processName in $relatedProcesses) {
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "  发现 $processName 进程: $($processes.Count) 个" -ForegroundColor Yellow
        if ($Verbose) {
            foreach ($proc in $processes) {
                Write-Host "    PID: $($proc.Id), 启动时间: $($proc.StartTime)" -ForegroundColor Gray
            }
        }
    }
}

Write-Host ""

# 检查端口占用情况
Write-Host "[信息] 检查端口占用情况..." -ForegroundColor Yellow
$ports = @(3001, 80, 443)
foreach ($port in $ports) {
    try {
        $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($connection) {
            Write-Host "  端口 $port 仍被占用: $($connection.State)" -ForegroundColor Yellow
            if ($Verbose) {
                Write-Host "    进程ID: $($connection.OwningProcess)" -ForegroundColor Gray
            }
        } else {
            Write-Host "  端口 $port 已释放" -ForegroundColor Green
        }
    } catch {
        Write-Host "  端口 $port 已释放" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "服务停止完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($Force) {
    Write-Host "注意: 使用了强制停止模式，可能影响了其他node进程" -ForegroundColor Yellow
}

Write-Host "使用说明:" -ForegroundColor White
Write-Host "  - 正常停止: .\stop-admin-ssl.ps1" -ForegroundColor Green
Write-Host "  - 强制停止: .\stop-admin-ssl.ps1 -Force" -ForegroundColor Green
Write-Host "  - 详细输出: .\stop-admin-ssl.ps1 -Verbose" -ForegroundColor Green
Write-Host ""

Read-Host "按Enter键退出"
