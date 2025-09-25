# Windows服务器SSL证书配置指南

## 🎯 目标
在Windows服务器上配置SSL证书，使域名 `practice.insightdata.top` 支持HTTPS访问。

## 📋 准备工作

### 1. 域名解析
确保域名 `practice.insightdata.top` 已正确解析到服务器IP `223.93.139.87`：
```
practice.insightdata.top A 223.93.139.87
```

### 2. 获取SSL证书
推荐使用Let's Encrypt免费证书，或购买商业SSL证书。

## 🔧 SSL证书获取方案

### 方案一：使用Let's Encrypt（推荐）

#### 1. 安装Certbot for Windows
```powershell
# 下载Certbot Windows版本
# 访问：https://certbot.eff.org/instructions?ws=other&os=windows

# 或使用Chocolatey安装
choco install certbot
```

#### 2. 使用Webroot验证方式
```powershell
# 创建验证目录
mkdir C:\inetpub\wwwroot\.well-known\acme-challenge

# 获取证书
certbot certonly --webroot -w C:\inetpub\wwwroot -d practice.insightdata.top
```

#### 3. 手动验证方式（如果Webroot不工作）
```powershell
# 停止IIS服务
net stop iisadmin /y

# 获取证书
certbot certonly --standalone -d practice.insightdata.top

# 启动IIS服务
net start iisadmin
```

### 方案二：使用商业SSL证书

#### 1. 购买证书
从证书颁发机构（如阿里云、腾讯云、DigiCert等）购买SSL证书。

#### 2. 生成CSR文件
```powershell
# 使用OpenSSL生成私钥和CSR
openssl req -new -newkey rsa:2048 -nodes -keyout practice.insightdata.top.key -out practice.insightdata.top.csr
```

## 🌐 Nginx配置HTTPS

### 1. 安装Nginx for Windows
```powershell
# 下载Nginx Windows版本
# 访问：http://nginx.org/en/download.html

# 解压到 C:\nginx
```

### 2. 配置Nginx SSL
创建配置文件 `C:\nginx\conf\practice.insightdata.top.conf`：

```nginx
# HTTPS配置
server {
    listen 443 ssl http2;
    server_name practice.insightdata.top;
    
    # SSL证书配置
    ssl_certificate C:/certificates/practice.insightdata.top.crt;
    ssl_certificate_key C:/certificates/practice.insightdata.top.key;
    
    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # 安全头
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # API代理
    location /api/ {
        proxy_pass http://localhost:3002/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # 健康检查
    location /health {
        proxy_pass http://localhost:3002/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 静态文件
    location /uploads/ {
        proxy_pass http://localhost:3002/uploads/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 管理后台
    location / {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# HTTP重定向到HTTPS
server {
    listen 80;
    server_name practice.insightdata.top;
    
    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}
```

### 3. 更新主配置文件
编辑 `C:\nginx\conf\nginx.conf`：
```nginx
http {
    include       mime.types;
    default_type  application/octet-stream;
    
    # 日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log logs/access.log main;
    error_log logs/error.log;
    
    # 包含站点配置
    include practice.insightdata.top.conf;
    
    # 其他配置...
}
```

## 🔧 证书自动续期

### 1. 创建续期脚本
创建 `C:\scripts\renew-cert.bat`：
```batch
@echo off
echo 开始续期SSL证书...

REM 续期证书
certbot renew --quiet

REM 重启Nginx
cd /d C:\nginx
nginx.exe -s reload

echo SSL证书续期完成
```

### 2. 设置定时任务
```powershell
# 打开任务计划程序
taskschd.msc

# 创建基本任务
# 名称：SSL证书自动续期
# 触发器：每月
# 操作：启动程序 C:\scripts\renew-cert.bat
```

## 🚀 部署步骤

### 1. 证书部署
```powershell
# 创建证书目录
mkdir C:\certificates

# 复制证书文件
copy "证书文件.crt" C:\certificates\practice.insightdata.top.crt
copy "私钥文件.key" C:\certificates\practice.insightdata.top.key

# 设置文件权限
icacls C:\certificates /grant "IIS_IUSRS:(OI)(CI)F"
```

### 2. 启动服务
```powershell
# 启动Nginx
cd C:\nginx
nginx.exe

# 启动API服务
cd D:\Helen Zhang\Cursor\miniprogram-1 - mysql\server
npm run start:prod

# 启动管理后台
cd D:\Helen Zhang\Cursor\miniprogram-1 - mysql\admin
npm run serve
```

### 3. 验证配置
```powershell
# 测试HTTPS连接
curl -I https://practice.insightdata.top/health

# 检查证书
openssl s_client -connect practice.insightdata.top:443 -servername practice.insightdata.top
```

## 🔍 故障排除

### 常见问题

1. **证书验证失败**
   ```powershell
   # 检查域名解析
   nslookup practice.insightdata.top
   
   # 检查防火墙
   netsh advfirewall firewall show rule name="HTTP"
   ```

2. **Nginx启动失败**
   ```powershell
   # 检查配置文件语法
   nginx.exe -t
   
   # 查看错误日志
   type C:\nginx\logs\error.log
   ```

3. **代理不工作**
   ```powershell
   # 检查后端服务
   netstat -an | findstr :3002
   
   # 测试本地连接
   curl http://localhost:3002/health
   ```

### 调试命令
```powershell
# 检查端口占用
netstat -an | findstr :443

# 检查Nginx状态
tasklist | findstr nginx

# 查看SSL握手
openssl s_client -connect practice.insightdata.top:443 -debug
```

## 📊 性能优化

### 1. SSL优化
```nginx
# 启用HTTP/2
listen 443 ssl http2;

# SSL会话缓存
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
```

### 2. 缓存配置
```nginx
# 静态资源缓存
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# API响应缓存
location /api/ {
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
}
```

## ✅ 验证清单

- [ ] 域名解析正确
- [ ] SSL证书有效
- [ ] HTTPS访问正常
- [ ] HTTP自动重定向
- [ ] API代理工作正常
- [ ] 管理后台可访问
- [ ] 证书自动续期配置
- [ ] 防火墙规则正确
- [ ] 日志记录正常
- [ ] 性能测试通过

## 🎯 预期结果

配置完成后：
- ✅ 域名 `https://practice.insightdata.top` 可正常访问
- ✅ 小程序API调用使用HTTPS
- ✅ 管理后台支持HTTPS访问
- ✅ SSL证书自动续期
- ✅ 安全等级达到A级

现在您的Windows服务器已经配置好SSL证书，支持HTTPS访问了！
