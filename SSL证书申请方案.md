# SSL证书申请方案

## 🎯 当前状态
- ✅ nginx已启动并监听8443端口
- ✅ 使用现有证书 `practice.insightdata.top` 作为临时方案
- ⚠️ 浏览器会显示证书域名不匹配警告

## 🔐 SSL证书申请方案

### 方案1: 使用现有证书 (当前方案)
**优点**: 立即可用
**缺点**: 浏览器会显示安全警告
**状态**: ✅ 已配置

### 方案2: 使用acme.sh (推荐)
```bash
# 下载acme.sh
curl -o acme.sh https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh

# 申请证书
bash acme.sh --issue -d admin.practice.insightdata.top --standalone --email admin@practice.insightdata.top

# 安装证书
bash acme.sh --install-cert -d admin.practice.insightdata.top --key-file "C:\certificates\admin.practice.insightdata.top.key" --fullchain-file "C:\certificates\admin.practice.insightdata.top.pem" --reloadcmd "C:\nginx\nginx.exe -s reload"
```

### 方案3: 使用certbot (需要管理员权限)
```cmd
# 以管理员身份运行
certbot certonly --standalone -d admin.practice.insightdata.top --email admin@practice.insightdata.top --agree-tos --non-interactive
```

### 方案4: 使用在线工具
1. 访问 https://www.sslforfree.com/
2. 输入域名: admin.practice.insightdata.top
3. 选择 Manual Verification
4. 下载验证文件到 C:\nginx\html\.well-known\acme-challenge\
5. 完成验证后下载证书

### 方案5: 使用自签名证书 (测试用)
```cmd
# 生成私钥
openssl genrsa -out C:\certificates\admin.practice.insightdata.top.key 2048

# 生成证书请求
openssl req -new -key C:\certificates\admin.practice.insightdata.top.key -out C:\certificates\admin.practice.insightdata.top.csr -subj "/CN=admin.practice.insightdata.top"

# 生成自签名证书
openssl x509 -req -days 365 -in C:\certificates\admin.practice.insightdata.top.csr -signkey C:\certificates\admin.practice.insightdata.top.key -out C:\certificates\admin.practice.insightdata.top.pem
```

## 🚀 推荐操作

### 立即测试当前配置
访问: https://admin.practice.insightdata.top:8443
- 浏览器会显示安全警告，点击"高级" -> "继续访问"
- 功能正常，只是证书域名不匹配

### 长期解决方案
1. 使用方案2 (acme.sh) 申请正式证书
2. 或者使用方案4 (在线工具) 手动申请
3. 设置自动续期

## 📝 注意事项
- 当前配置可以正常使用，只是有安全警告
- 建议尽快申请正确的SSL证书
- 证书有效期为90天，需要定期更新
