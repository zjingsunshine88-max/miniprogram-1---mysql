@echo off
echo 正在生成SSL自签名证书...

REM 创建SSL证书目录
if not exist "C:\nginx\ssl" mkdir "C:\nginx\ssl"

REM 使用PowerShell生成自签名证书
powershell -Command "& { $cert = New-SelfSignedCertificate -DnsName '223.93.139.87' -CertStoreLocation 'cert:\CurrentUser\My' -KeyAlgorithm RSA -KeyLength 2048; $pwd = ConvertTo-SecureString -String 'password' -Force -AsPlainText; Export-PfxCertificate -Cert $cert -FilePath 'C:\nginx\ssl\cert.pfx' -Password $pwd; $cert | Export-Certificate -FilePath 'C:\nginx\ssl\cert.pem' -Type CERT; $cert | Export-Certificate -FilePath 'C:\nginx\ssl\cert.cer' -Type CERT }"

REM 将PFX转换为PEM格式的私钥
powershell -Command "& { $cert = Get-PfxCertificate -FilePath 'C:\nginx\ssl\cert.pfx' -Password (ConvertTo-SecureString -String 'password' -Force -AsPlainText); $cert.PrivateKey | Export-Certificate -FilePath 'C:\nginx\ssl\key.pem' -Type CERT }"

echo SSL证书生成完成！
echo 证书文件位置：
echo   - C:\nginx\ssl\cert.pem
echo   - C:\nginx\ssl\key.pem
echo.
echo 注意：这是自签名证书，浏览器会显示安全警告。
echo 在生产环境中，请使用正式的SSL证书。
pause
