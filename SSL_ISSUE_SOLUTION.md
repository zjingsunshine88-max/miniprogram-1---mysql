# SSL证书问题解决方案

## 问题描述
访问 `http://223.93.139.87/` 时会自动跳转到 `https://223.93.139.87/web/frame/login.html?ssl=false&host=223.93.139.87` 并报"此站点的连接不安全"错误。

## 问题原因
1. **nginx代理已可用** - HTTP访问正常工作（返回200状态码）
2. **缺少HTTPS配置** - 原nginx配置只有HTTP，没有HTTPS配置
3. **SSL证书缺失** - 浏览器尝试访问HTTPS但服务器没有配置SSL证书

## 解决方案

### 方案1：使用HTTP访问（推荐用于测试）
当前已配置nginx只使用HTTP，可以直接访问：
- 访问地址：`http://223.93.139.87`
- 状态：✅ 已修复，可正常访问

### 方案2：配置HTTPS（生产环境推荐）

#### 2.1 生成SSL证书
运行以下命令生成自签名证书：
```bash
# 方法1：使用PowerShell脚本
powershell -ExecutionPolicy Bypass -File create-ssl-cert.ps1

# 方法2：使用批处理文件
fix-ssl-issue.bat
```

#### 2.2 启用HTTPS配置
编辑 `C:\nginx\conf\conf.d\admin.conf`，取消注释HTTPS部分：
```nginx
# 取消注释这部分配置
server {
    listen 443 ssl http2;
    server_name 223.93.139.87;
    
    ssl_certificate C:/nginx/ssl/cert.pem;
    ssl_certificate_key C:/nginx/ssl/key.pem;
    
    # 其他配置...
}
```

#### 2.3 重新加载nginx
```bash
C:\nginx\nginx.exe -s reload
```

## 当前状态
- ✅ nginx代理正常工作
- ✅ HTTP访问正常（http://223.93.139.87）
- ⚠️ HTTPS需要SSL证书（生产环境建议使用正式证书）

## 生产环境建议
1. **使用正式SSL证书** - 从Let's Encrypt或其他CA获取免费证书
2. **配置域名** - 使用域名而不是IP地址
3. **启用HTTPS重定向** - 自动将HTTP请求重定向到HTTPS

## 测试命令
```bash
# 测试HTTP访问
curl -I http://223.93.139.87

# 测试HTTPS访问（需要证书）
curl -I https://223.93.139.87
```

## 文件位置
- nginx配置：`C:\nginx\conf\conf.d\admin.conf`
- SSL证书：`C:\nginx\ssl\`（需要创建）
- 项目配置：`nginx/conf.d/admin.conf`
