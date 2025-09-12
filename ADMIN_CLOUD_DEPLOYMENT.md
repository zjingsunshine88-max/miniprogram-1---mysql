# Admin系统部署到微信云后台指南

## 概述

将admin系统部署到微信云后台需要以下步骤：
1. 创建admin云函数
2. 修改admin前端配置
3. 部署云函数
4. 配置HTTP触发器
5. 部署前端

## 1. 云函数准备

### 1.1 创建admin云函数
在微信开发者工具中：
1. 右键点击 `cloudfunctions` 文件夹
2. 选择"新建云函数"
3. 函数名称：`admin-api`
4. 运行环境：Node.js

### 1.2 云函数文件结构
```
cloudfunctions/admin-api/
├── index.js          # 云函数入口文件
├── package.json      # 依赖配置
└── node_modules/     # 依赖包（部署时自动生成）
```

### 1.3 安装依赖
```bash
cd cloudfunctions/admin-api
npm install
```

## 2. 前端配置修改

### 2.1 修改API配置
在 `admin/src/api/admin.js` 中配置云函数URL：
```javascript
const cloudConfig = {
  functionUrl: 'https://your-env-id.service.tcloudbase.com/admin-api',
  timeout: 30000,
  debug: true
}
```

### 2.2 更新环境变量
在 `admin/.env.production` 中：
```env
VITE_CLOUD_FUNCTION_URL=https://your-env-id.service.tcloudbase.com/admin-api
```

## 3. 部署步骤

### 3.1 部署云函数
1. 在微信开发者工具中右键点击 `cloudfunctions/admin-api`
2. 选择"上传并部署：云端安装依赖"
3. 等待部署完成

### 3.2 配置HTTP触发器
1. 打开微信云开发控制台
2. 进入云函数页面
3. 找到 `admin-api` 函数
4. 点击"触发器"选项卡
5. 添加HTTP触发器：
   - 触发方式：HTTP
   - 访问路径：`/admin-api`
   - 请求方法：POST
   - 认证方式：无认证

### 3.3 获取云函数URL
部署完成后，在云函数详情页面可以看到HTTP触发器URL：
```
https://your-env-id.service.tcloudbase.com/admin-api
```

### 3.4 更新前端配置
将获取到的URL更新到 `admin/src/api/admin.js` 中：
```javascript
const cloudConfig = {
  functionUrl: 'https://your-env-id.service.tcloudbase.com/admin-api',
  // ...
}
```

## 4. 数据库准备

### 4.1 创建管理员账号
在云开发控制台的数据库中，创建 `admins` 集合，添加管理员账号：
```javascript
{
  "username": "admin",
  "password": "123456", // 实际项目中应该加密
  "role": "admin",
  "createTime": "2024-01-15T10:00:00.000Z"
}
```

### 4.2 设置数据库权限
确保以下集合的权限设置正确：
- `users` - 仅管理员可读写
- `questions` - 仅管理员可读写
- `answer_records` - 仅管理员可读
- `error_records` - 仅管理员可读
- `favorites` - 仅管理员可读
- `admins` - 仅管理员可读写

## 5. 前端部署

### 5.1 构建生产版本
```bash
cd admin
npm run build
```

### 5.2 部署到静态托管
1. 在微信云开发控制台中
2. 进入"静态网站托管"
3. 上传 `dist` 文件夹内容
4. 获取访问域名

### 5.3 配置自定义域名（可选）
1. 在静态网站托管中
2. 点击"设置"
3. 添加自定义域名
4. 配置DNS解析

## 6. 测试验证

### 6.1 测试云函数
在云开发控制台中测试云函数：
```javascript
{
  "action": "admin.login",
  "username": "admin",
  "password": "123456"
}
```

### 6.2 测试前端
1. 访问部署的前端地址
2. 使用管理员账号登录
3. 测试各项功能

## 7. 安全配置

### 7.1 环境变量
创建 `.env.production` 文件：
```env
VITE_CLOUD_FUNCTION_URL=https://your-env-id.service.tcloudbase.com/admin-api
VITE_APP_TITLE=题库管理系统
```

### 7.2 密码加密
在实际项目中，应该对密码进行加密：
```javascript
// 使用bcrypt加密密码
const bcrypt = require('bcrypt')
const hashedPassword = await bcrypt.hash(password, 10)
```

### 7.3 访问控制
在云函数中添加访问控制：
```javascript
// 验证管理员token
const verifyAdminToken = (token) => {
  // 实现token验证逻辑
}
```

## 8. 监控和维护

### 8.1 日志监控
在云开发控制台中查看云函数日志：
1. 进入云函数页面
2. 点击 `admin-api` 函数
3. 查看"日志"选项卡

### 8.2 性能监控
监控云函数的执行情况：
- 执行时间
- 内存使用
- 错误率

### 8.3 备份策略
定期备份数据库：
1. 在云开发控制台中导出数据
2. 保存到本地或云端存储

## 9. 常见问题

### 9.1 CORS错误
如果遇到CORS错误，检查云函数的CORS配置：
```javascript
res.setHeader('Access-Control-Allow-Origin', '*')
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
```

### 9.2 云函数超时
如果云函数执行超时，可以：
1. 增加云函数超时时间
2. 优化代码逻辑
3. 使用异步处理

### 9.3 数据库权限
确保数据库集合权限设置正确：
- 管理员集合：仅管理员可读写
- 用户数据：仅用户本人可读写
- 题目数据：仅管理员可读写

## 10. 部署检查清单

- [ ] 云函数部署成功
- [ ] HTTP触发器配置正确
- [ ] 数据库权限设置正确
- [ ] 管理员账号创建
- [ ] 前端API配置更新
- [ ] 前端构建成功
- [ ] 静态托管部署完成
- [ ] 功能测试通过
- [ ] 安全配置完成
- [ ] 监控配置完成

## 总结

通过以上步骤，您可以将admin系统成功部署到微信云后台。部署后的系统具有以下优势：

1. **高可用性** - 微信云提供99.9%的可用性
2. **自动扩缩容** - 根据访问量自动调整资源
3. **安全可靠** - 微信云提供多层安全防护
4. **成本低廉** - 按使用量计费，成本可控
5. **易于维护** - 统一的云开发控制台

部署完成后，您就可以通过微信云后台管理您的题库系统了！
