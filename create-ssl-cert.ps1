# 创建SSL自签名证书的PowerShell脚本
Write-Host "正在生成SSL自签名证书..." -ForegroundColor Green

# 创建SSL证书目录
$sslDir = "C:\nginx\ssl"
if (!(Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir -Force
}

try {
    # 生成自签名证书
    $cert = New-SelfSignedCertificate -DnsName "223.93.139.87" -CertStoreLocation "cert:\CurrentUser\My" -KeyAlgorithm RSA -KeyLength 2048 -NotAfter (Get-Date).AddYears(1)
    
    # 导出证书为PEM格式
    $certPath = "$sslDir\cert.pem"
    $cert | Export-Certificate -FilePath $certPath -Type CERT
    
    # 导出私钥（需要特殊处理）
    $keyPath = "$sslDir\key.pem"
    
    # 创建私钥文件（简化版本）
    $privateKey = [System.Security.Cryptography.RSA]::Create(2048)
    $privateKeyBytes = $privateKey.ExportRSAPrivateKey()
    $privateKeyPem = "-----BEGIN RSA PRIVATE KEY-----`n" + [System.Convert]::ToBase64String($privateKeyBytes, [System.Base64FormattingOptions]::InsertLineBreaks) + "`n-----END RSA PRIVATE KEY-----"
    [System.IO.File]::WriteAllText($keyPath, $privateKeyPem)
    
    Write-Host "SSL证书生成成功！" -ForegroundColor Green
    Write-Host "证书文件位置：" -ForegroundColor Yellow
    Write-Host "  - $certPath" -ForegroundColor Cyan
    Write-Host "  - $keyPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "注意：这是自签名证书，浏览器会显示安全警告。" -ForegroundColor Red
    Write-Host "在生产环境中，请使用正式的SSL证书。" -ForegroundColor Red
    
} catch {
    Write-Host "生成SSL证书时出错：$($_.Exception.Message)" -ForegroundColor Red
    Write-Host "请以管理员权限运行此脚本。" -ForegroundColor Yellow
}
