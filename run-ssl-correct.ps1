# PowerShell版本的SSL证书获取工具
# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "正确的SSL证书获取方式"

Write-Host "🔐 正确的SSL证书获取方式" -ForegroundColor Green
Write-Host ""

Write-Host "📋 说明:" -ForegroundColor Yellow
Write-Host "1. 系统会显示新的TXT记录值"
Write-Host "2. 您需要将这个字符串添加到DNS中"
Write-Host "3. 等待DNS传播后继续验证"
Write-Host ""

Write-Host "⚠️  重要提示:" -ForegroundColor Red
Write-Host "请准备好您的DNS管理面板，以便添加TXT记录"
Write-Host ""

Write-Host "按任意键开始..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "🔄 开始DNS验证..." -ForegroundColor Cyan
Write-Host "注意: 系统会提示您添加TXT记录，请按照提示操作"
Write-Host ""

# 清理旧的验证记录
if (Test-Path "C:\Certbot\live\practice.insightdata.top") {
    Write-Host "清理旧的验证记录..." -ForegroundColor Yellow
    Remove-Item "C:\Certbot\live\practice.insightdata.top" -Recurse -Force
}

Write-Host ""
Write-Host "📋 系统将显示新的TXT记录，请按照以下步骤操作:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 复制系统提供的TXT记录值"
Write-Host "2. 登录您的DNS管理面板"
Write-Host "3. 添加TXT记录:"
Write-Host "   - 记录类型: TXT"
Write-Host "   - 主机记录: _acme-challenge.practice"
Write-Host "   - 记录值: [系统提供的值]"
Write-Host "4. 保存DNS设置"
Write-Host "5. 等待DNS传播（通常需要5-30分钟）"
Write-Host "6. 按回车继续验证"
Write-Host ""

Write-Host "按回车开始DNS验证..."
Read-Host

Write-Host ""
Write-Host "🔄 开始DNS验证..." -ForegroundColor Cyan
Write-Host ""

# 使用正确的Python模块调用方式
try {
    & python -c "import certbot.main; certbot.main.main()" certonly --manual --preferred-challenges dns -d practice.insightdata.top --email admin@practice.insightdata.top --agree-tos
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ DNS验证成功！" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "📁 证书文件位置:" -ForegroundColor Yellow
        Write-Host "- 证书文件: C:\Certbot\live\practice.insightdata.top\fullchain.pem"
        Write-Host "- 私钥文件: C:\Certbot\live\practice.insightdata.top\privkey.pem"
        Write-Host ""
        
        Write-Host "🔄 复制证书到项目目录..." -ForegroundColor Cyan
        if (!(Test-Path "C:\certificates")) {
            New-Item -ItemType Directory -Path "C:\certificates" -Force
        }
        
        Copy-Item "C:\Certbot\live\practice.insightdata.top\fullchain.pem" "C:\certificates\practice.insightdata.top.pem" -Force
        Copy-Item "C:\Certbot\live\practice.insightdata.top\privkey.pem" "C:\certificates\practice.insightdata.top.key" -Force
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 证书复制成功" -ForegroundColor Green
        } else {
            Write-Host "❌ 证书复制失败" -ForegroundColor Red
            Write-Host "💡 请手动复制证书文件" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "🎉 SSL证书配置完成！" -ForegroundColor Green
        Write-Host ""
        Write-Host "🌐 测试访问:" -ForegroundColor Cyan
        Write-Host "- HTTPS: https://practice.insightdata.top"
        Write-Host ""
    } else {
        throw "DNS验证失败"
    }
} catch {
    Write-Host ""
    Write-Host "❌ DNS验证失败" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 可能的原因:" -ForegroundColor Yellow
    Write-Host "1. TXT记录格式错误"
    Write-Host "2. DNS传播时间较长"
    Write-Host "3. 域名DNS设置有问题"
    Write-Host ""
    Write-Host "🔧 解决方案:" -ForegroundColor Yellow
    Write-Host "1. 检查TXT记录是否正确添加"
    Write-Host "2. 等待DNS传播（通常需要几分钟）"
    Write-Host "3. 使用在线工具验证TXT记录"
    Write-Host ""
    Write-Host "🌐 在线验证工具:" -ForegroundColor Cyan
    Write-Host "- https://dnschecker.org/"
    Write-Host "- https://www.whatsmydns.net/"
    Write-Host "- https://mxtoolbox.com/TXTLookup.aspx"
    Write-Host ""
}

Read-Host "按回车键退出"
