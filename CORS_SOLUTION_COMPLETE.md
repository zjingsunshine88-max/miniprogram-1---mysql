# 跨域问题完整解决方案

## 问题分析

从浏览器开发者工具的网络面板可以看出：
- 请求从 `https://admin.practice.insightdate.top:8443` 发往 `https://practice.insightdate.top/api/user/admin-login`
- 显示"Provisional headers are shown"警告，表明CORS预检请求失败
- 这是一个典型的跨域问题，因为源域名和目标域名不同

## 解决方案：Nginx代理

### 1. 后端API服务器配置 ✅
已修改 `server/app.js`，添加了admin子域名到CORS允许列表：
```javascript
origin: [
  'http://223.93.139.87:3001',
  'http://localhost:3001',
  'https://admin.practice.insightdate.top:8443',
  'https://admin.practice.insightdate.top',
  'http://admin.practice.insightdate.top:8443',
  'http://admin.practice.insightdate.top'
]
```

### 2. Nginx代理配置 ✅
创建了 `C:\nginx\conf.d\admin-ssl.conf`，实现API请求代理：
```nginx
# 代理API请求到主域名 - 解决跨域问题
location /api/ {
    proxy_pass https://practice.insightdate.top/api/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_ssl_verify off;
    proxy_ssl_server_name on;
}
```

### 3. 前端API配置 ✅
修改了 `admin/src/api/admin.js`，在生产环境中使用相对路径：
```javascript
const getServerUrl = () => {
  // 在生产环境中使用相对路径，让nginx代理处理API请求
  if (import.meta.env.PROD) {
    return ''; // 使用相对路径，nginx会代理到主域名
  }
  // 开发环境使用完整URL
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdate.top'
}
```

## 工作原理

1. **前端请求**：Admin前端发送请求到 `/api/user/admin-login`
2. **Nginx代理**：Nginx接收到请求后，代理到 `https://practice.insightdate.top/api/user/admin-login`
3. **同域请求**：从浏览器角度看，请求是从 `admin.practice.insightdate.top:8443` 到 `admin.practice.insightdate.top:8443`，属于同域请求
4. **无跨域问题**：由于是同域请求，不会触发CORS预检，直接成功

## 服务状态

- ✅ Nginx: 运行中，监听8443端口
- ✅ API服务器: 运行中，监听3002端口
- ✅ Admin前端: 需要重新构建并部署

## 下一步操作

1. **重新构建Admin前端**：
   ```bash
   cd admin
   npm run build
   ```

2. **部署到nginx目录**：
   ```bash
   # 将构建后的文件复制到 C:/admin 目录
   xcopy /E /I dist C:\admin
   ```

3. **测试访问**：
   - 访问：https://admin.practice.insightdate.top:8443
   - 检查登录功能是否正常

## 验证方法

1. 打开浏览器开发者工具
2. 访问admin管理界面
3. 尝试登录
4. 检查网络面板，应该看到：
   - 请求URL为 `https://admin.practice.insightdate.top:8443/api/user/admin-login`
   - 没有CORS错误
   - 请求成功返回

## 备用方案

如果代理方案仍有问题，可以尝试：
1. 检查SSL证书是否有效
2. 确认域名DNS解析正确
3. 检查防火墙设置
4. 验证nginx日志中的错误信息
