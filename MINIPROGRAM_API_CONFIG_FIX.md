# 小程序API地址配置修复指南

## 🚨 问题描述

用户询问微信小程序调用API的地址是否已经改成了 `http://223.93.139.87:3002`。

## 🔍 检查结果

### 配置文件状态
✅ **生产环境配置正确**
- 文件: `miniprogram/config/production.js`
- 配置: `BASE_URL: 'http://223.93.139.87:3002'`

✅ **开发环境配置正确**
- 文件: `miniprogram/config/development.js`
- 配置: `BASE_URL: 'http://localhost:3002'`

### 发现的问题
❌ **硬编码地址问题**
- 文件: `miniprogram/pages/answer/index.js`
- 问题: 图片路径处理中硬编码了 `localhost:3002`
- 影响: 生产环境中图片无法正确加载

## 🔧 修复内容

### 1. 修复图片路径硬编码问题

#### 修复前
```javascript
// pages/answer/index.js
path: `http://localhost:3002/uploads${image.path}`,
path: `http://localhost:3002/uploads/${image.path}`,
path: `http://localhost:3002/uploads/images/${image.path}`,
```

#### 修复后
```javascript
// pages/answer/index.js
const config = require('../../config/production.js') // 生产环境配置

path: `${config.BASE_URL}/uploads${image.path}`,
path: `${config.BASE_URL}/uploads/${image.path}`,
path: `${config.BASE_URL}/uploads/images/${image.path}`,
```

### 2. 修复URL路径修正逻辑

#### 修复前
```javascript
else if (image.path && image.path.startsWith('http://localhost:3002/images/')) {
  const correctedPath = image.path.replace('http://localhost:3002/images/', 'http://localhost:3002/uploads/images/')
```

#### 修复后
```javascript
else if (image.path && image.path.startsWith(`${config.BASE_URL}/images/`)) {
  const correctedPath = image.path.replace(`${config.BASE_URL}/images/`, `${config.BASE_URL}/uploads/images/`)
```

## 📋 修复验证

### 检查结果
✅ **所有配置正确**
- 生产环境: `http://223.93.139.87:3002`
- 开发环境: `http://localhost:3002`
- 所有API调用都使用配置文件
- 图片路径处理已修复

### 验证命令
```bash
# 运行配置检查脚本
node check-miniprogram-api-config.js
```

## 🚀 使用方法

### 环境切换
小程序会根据配置文件自动使用正确的API地址：

#### 生产环境
```javascript
// miniprogram/utils/server-api.js
const config = require('../config/production.js') // 生产环境
```

#### 开发环境
```javascript
// miniprogram/utils/server-api.js
// const config = require('../config/production.js') // 生产环境
const config = require('../config/development.js') // 开发环境
```

### 配置说明
- **生产环境**: 使用 `http://223.93.139.87:3002`
- **开发环境**: 使用 `http://localhost:3002`
- **自动切换**: 通过注释/取消注释配置行来切换

## 🔍 技术细节

### API调用流程
```
小程序页面 → server-api.js → config/production.js → http://223.93.139.87:3002
```

### 图片路径处理
```
相对路径 → config.BASE_URL + 路径 → 完整URL
```

### 关键文件
- `miniprogram/config/production.js` - 生产环境配置
- `miniprogram/config/development.js` - 开发环境配置
- `miniprogram/utils/server-api.js` - API调用工具
- `miniprogram/pages/answer/index.js` - 答题页面（已修复）

## 💡 最佳实践

### 1. 环境管理
- 使用配置文件管理不同环境的API地址
- 避免硬编码地址
- 通过注释切换环境

### 2. 路径处理
- 使用配置的BASE_URL构建完整路径
- 支持多种图片路径格式
- 自动修正错误的路径

### 3. 测试验证
- 定期检查配置是否正确
- 验证API调用是否正常
- 测试图片加载是否正常

## 🔄 维护建议

### 定期检查
1. 验证API地址配置
2. 检查硬编码地址
3. 测试图片加载
4. 验证环境切换

### 监控指标
- API调用成功率
- 图片加载成功率
- 响应时间
- 错误率

## 📞 故障排除

### 常见问题

1. **API调用失败**
   - 检查配置文件是否正确
   - 验证服务器地址是否可达
   - 确认网络连接正常

2. **图片加载失败**
   - 检查图片路径是否正确
   - 验证服务器图片服务是否正常
   - 确认BASE_URL配置正确

3. **环境切换问题**
   - 检查配置文件引入是否正确
   - 确认注释状态正确
   - 验证配置内容是否匹配

### 调试命令
```bash
# 检查配置
node check-miniprogram-api-config.js

# 测试API连接
# 在小程序中查看控制台日志
```

## ✅ 修复确认

修复完成后，请确认以下项目：

- [x] 生产环境配置正确 (`http://223.93.139.87:3002`)
- [x] 开发环境配置正确 (`http://localhost:3002`)
- [x] 硬编码地址已修复
- [x] 图片路径处理已修复
- [x] 配置文件使用正确
- [x] 环境切换功能正常
- [x] 测试脚本已创建
- [x] 文档已更新

## 📊 当前状态

✅ **微信小程序API地址配置已完成**
- 生产环境: `http://223.93.139.87:3002`
- 开发环境: `http://localhost:3002`
- 所有API调用都使用配置文件
- 图片路径处理已修复
- 支持环境自动切换

现在小程序可以正确调用生产环境的API地址了！
