# Let's Encrypt SSL证书手动配置指南

## 🔐 方案一：使用Certbot（推荐）

### 1. 安装Python和Certbot

```bash
# 下载Python 3.x
# 访问: https://www.python.org/downloads/
# 安装时勾选 "Add Python to PATH"

# 安装Certbot
pip install certbot
```

### 2. 生成SSL证书

```bash
# 停止Nginx（释放80端口）
nginx -s stop

# 生成证书
certbot certonly --standalone -d practice.insightdata.top --email your-email@example.com --agree-tos

# 重启Nginx
nginx
```

### 3. 复制证书文件

```bash
# 创建证书目录
mkdir C:\certificates

# 复制证书文件
copy "C:\Certbot\live\practice.insightdata.top\fullchain.pem" "C:\certificates\practice.insightdata.top.pem"
copy "C:\Certbot\live\practice.insightdata.top\privkey.pem" "C:\certificates\practice.insightdata.top.key"
```

## 🔐 方案二：使用在线工具

### 1. 使用SSL For Free
- 访问: https://www.sslforfree.com/
- 输入域名: practice.insightdata.top
- 选择"Manual Verification"
- 下载证书文件

### 2. 使用Let's Encrypt在线工具
- 访问: https://letsencrypt.org/
- 使用在线证书生成工具
- 下载证书和私钥

## 🔐 方案三：使用Docker（如果已安装Docker）

```bash
# 使用Docker运行Certbot
docker run -it --rm -v C:\certificates:/etc/letsencrypt certbot/certbot certonly --standalone -d practice.insightdata.top
```

## 📋 证书文件说明

- **证书文件**: `practice.insightdata.top.pem` (fullchain.pem)
- **私钥文件**: `practice.insightdata.top.key` (privkey.pem)
- **有效期**: 90天
- **自动续期**: 需要设置定时任务

## 🔄 自动续期设置

### Windows计划任务
```bash
# 创建续期脚本
echo certbot renew --quiet > C:\certbot\renew.bat
echo nginx -s reload >> C:\certbot\renew.bat

# 添加计划任务
schtasks /create /tn "Certbot Renewal" /tr "C:\certbot\renew.bat" /sc daily /st 02:00
```

## ⚠️ 重要注意事项

1. **域名解析**: 确保 `practice.insightdata.top` 解析到服务器IP
2. **端口开放**: 确保80和443端口可访问
3. **防火墙**: 允许HTTP和HTTPS流量
4. **Nginx配置**: 使用正确的证书路径
5. **证书续期**: 设置自动续期避免证书过期

## 🧪 测试证书

```bash
# 测试SSL证书
openssl s_client -connect practice.insightdata.top:443 -servername practice.insightdata.top

# 检查证书有效期
openssl x509 -in C:\certificates\practice.insightdata.top.pem -text -noout
```

## 🆘 故障排除

### 常见问题
1. **域名验证失败**: 检查域名解析和80端口
2. **证书生成失败**: 确保没有其他服务占用80端口
3. **Nginx重启失败**: 检查证书文件路径和权限
4. **HTTPS无法访问**: 检查防火墙和SSL配置

### 调试命令
```bash
# 检查端口占用
netstat -ano | findstr :80
netstat -ano | findstr :443

# 检查域名解析
nslookup practice.insightdata.top

# 检查Nginx配置
nginx -t

# 查看Nginx日志
type C:\nginx\logs\error.log
```
