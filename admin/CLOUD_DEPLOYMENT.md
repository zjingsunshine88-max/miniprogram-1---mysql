# Admin 云函数部署指南

## 概述

本指南将帮助你将admin后台管理系统配置为使用云函数API，替代本地服务器。

## 第一步：配置云函数HTTP触发器

### 1. 在微信开发者工具中配置云函数

1. 打开微信开发者工具
2. 进入云开发控制台
3. 找到 `question-bank-api` 云函数
4. 在"触发器"选项卡中添加HTTP触发器
5. 记录下HTTP触发器的URL

### 2. 更新配置文件

修改 `admin/src/config/cloud.js` 文件：

```javascript
export const cloudConfig = {
  // 替换为你的云开发环境ID
  envId: 'your-actual-env-id',
  
  // 替换为你的云函数HTTP触发器URL
  functionUrl: 'https://your-actual-env-id.service.tcloudbase.com/question-bank-api',
  
  timeout: 30000,
  debug: process.env.NODE_ENV === 'development'
}
```

## 第二步：部署云函数

### 1. 上传云函数

1. 在微信开发者工具中，右键点击 `cloudfunctions/question-bank-api` 文件夹
2. 选择"上传并部署：云端安装依赖"
3. 等待部署完成

### 2. 测试云函数

在云开发控制台中测试HTTP触发器：

```bash
curl -X POST https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/question-bank-api \
  -H "Content-Type: application/json" \
  -d '{
    "action": "question.getList",
    "subject": "数学",
    "limit": 10
  }'
```

## 第三步：配置Admin应用

### 1. 环境变量配置

创建 `.env.development` 文件：

```bash
# 开发环境配置
VITE_CLOUD_ENV_ID=cloudbase-5guq06yfe657e091
VITE_CLOUD_FUNCTION_URL=https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/question-bank-api
```

创建 `.env.production` 文件：

```bash
# 生产环境配置
VITE_CLOUD_ENV_ID=cloudbase-5guq06yfe657e091
VITE_CLOUD_FUNCTION_URL=https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/question-bank-api
```

### 2. 更新配置文件

修改 `admin/src/config/cloud.js`：

```javascript
export const cloudConfig = {
  envId: import.meta.env.VITE_CLOUD_ENV_ID || 'cloudbase-5guq06yfe657e091',
  functionUrl: import.meta.env.VITE_CLOUD_FUNCTION_URL || 'https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/question-bank-api',
  timeout: 30000,
  debug: import.meta.env.DEV
}
```

## 第四步：测试Admin功能

### 1. 启动开发服务器

```bash
cd admin
npm run dev
```

### 2. 测试功能

1. 访问登录页面
2. 测试题库导入功能
3. 检查题目列表显示
4. 验证统计功能

## 第五步：生产环境部署

### 1. 构建生产版本

```bash
cd admin
npm run build
```

### 2. 部署到服务器

将 `dist` 目录部署到你的Web服务器。

### 3. 配置域名

确保你的域名已正确配置并指向云函数URL。

## 常见问题

### 1. CORS错误

如果遇到CORS错误，检查云函数的HTTP触发器配置：

```javascript
// 在云函数中已添加CORS头
res.setHeader('Access-Control-Allow-Origin', '*')
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
```

### 2. 云函数调用失败

- 检查云函数URL是否正确
- 确认云函数已正确部署
- 查看云函数日志

### 3. 认证问题

- 确认token格式正确
- 检查用户权限设置
- 验证登录状态

## 部署检查清单

- [ ] 云函数HTTP触发器已配置
- [ ] 云函数已部署
- [ ] 配置文件已更新
- [ ] 环境变量已设置
- [ ] 开发环境测试通过
- [ ] 生产环境部署完成
- [ ] 域名配置正确
- [ ] 功能测试通过

## 优势

使用云函数的优势：

1. **无需服务器维护** - 微信自动管理云函数
2. **自动扩缩容** - 根据访问量自动调整资源
3. **安全可靠** - 微信提供安全防护
4. **开发简单** - 无需配置HTTPS证书
5. **成本低廉** - 免费额度足够开发测试

## 下一步

部署完成后，你可以：

1. 添加更多管理功能
2. 优化用户界面
3. 添加数据统计功能
4. 实现更复杂的权限管理
