# 最简单SSL证书申请方法

## 🎯 目标
为 `admin.practice.insightdata.top` 申请Let's Encrypt SSL证书

## 🚀 推荐方法：使用SSL For Free

### 步骤1: 访问网站
1. 打开浏览器访问：https://www.sslforfree.com/
2. 在输入框中输入：`admin.practice.insightdata.top`
3. 点击 "Create Free SSL Certificate"

### 步骤2: 选择验证方式
1. 选择 "Manual Verification"（手动验证）
2. 点击 "Manual Verification"

### 步骤3: 创建验证目录
```cmd
mkdir C:\nginx\html\.well-known\acme-challenge
```

### 步骤4: 下载验证文件
1. 下载验证文件到：`C:\nginx\html\.well-known\acme-challenge\`
2. 确保文件名和内容正确

### 步骤5: 启动临时HTTP服务器
```cmd
python -m http.server 80 --directory C:\nginx\html
```

### 步骤6: 完成验证
1. 在SSL For Free网站上点击 "Download SSL Certificate"
2. 下载证书文件

### 步骤7: 安装证书
1. 将证书文件重命名为：`admin.practice.insightdata.top.pem`
2. 将私钥文件重命名为：`admin.practice.insightdata.top.key`
3. 放置到：`C:\certificates\` 目录

### 步骤8: 更新nginx配置
```cmd
powershell -Command "(Get-Content 'C:\nginx\conf\admin.practice.insightdata.top.conf') -replace 'practice\.insightdata\.top\.pem', 'admin.practice.insightdata.top.pem' -replace 'practice\.insightdata\.top\.key', 'admin.practice.insightdata.top.key' | Set-Content 'C:\nginx\conf\admin.practice.insightdata.top.conf'"
```

### 步骤9: 重新加载nginx
```cmd
cd C:\nginx
nginx.exe -s reload
```

## 🔧 自动化脚本

我已经创建了自动化脚本，您可以直接运行：

```cmd
手动申请SSL证书.bat
```

这个脚本会：
1. 创建验证目录
2. 启动临时HTTP服务器
3. 引导您完成证书申请
4. 自动更新nginx配置
5. 重新启动nginx

## ✅ 验证证书

申请完成后，访问：
- https://admin.practice.insightdata.top:8443

检查浏览器是否显示安全锁图标。

## 📝 注意事项

1. **域名解析**：确保 `admin.practice.insightdata.top` 解析到您的服务器IP
2. **端口开放**：确保80端口可用于验证
3. **证书有效期**：Let's Encrypt证书有效期为90天
4. **自动续期**：建议设置自动续期任务

## 🎉 完成！

按照以上步骤操作，您就可以成功为 `admin.practice.insightdata.top` 申请到SSL证书了！
