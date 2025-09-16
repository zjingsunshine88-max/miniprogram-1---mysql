# 开发环境启动指南

## 🚀 快速启动

### 方式一：使用启动器（推荐）
```batch
# 运行图形化启动器
server-launcher.bat
# 选择选项 1: 开发环境启动服务器 (nodemon自动重启)
```

### 方式二：使用专用开发脚本
```batch
# 运行开发环境启动脚本
start-server-dev.bat
```

### 方式三：手动命令
```batch
# 进入server目录
cd server

# 设置开发环境变量
set NODE_ENV=development

# 启动开发服务器
npm run dev
```

## 📋 开发环境特性

### ✅ 自动重启
- 使用 `nodemon` 监听文件变化
- 代码修改后自动重启服务器
- 提高开发效率

### ✅ 环境变量
- `NODE_ENV=development`
- 开发环境专用配置
- 详细的错误信息

### ✅ 热重载
- 文件保存后自动重启
- 无需手动停止和启动
- 保持开发流程顺畅

## 🔧 开发工具

### 安装开发依赖
```batch
cd server
npm install nodemon --save-dev
```

### 检查nodemon安装
```batch
npm list nodemon
```

### 手动安装nodemon
```batch
npm install -g nodemon
```

## 🌐 访问地址

开发环境启动后：
- **API服务**: http://localhost:3002
- **健康检查**: http://localhost:3002/health
- **API文档**: http://localhost:3002/api

## 📊 开发环境 vs 生产环境

| 特性 | 开发环境 | 生产环境 |
|------|----------|----------|
| 启动命令 | `npm run dev` | `npm run start` |
| 进程管理 | nodemon | PM2 |
| 环境变量 | development | production |
| 自动重启 | ✅ | ❌ |
| 错误详情 | 详细 | 简化 |
| 性能优化 | ❌ | ✅ |

## 🔍 故障排除

### 1. nodemon未安装
```batch
# 解决方案：安装nodemon
npm install nodemon --save-dev
```

### 2. 端口被占用
```batch
# 查看端口占用
netstat -ano | findstr :3002

# 结束占用进程
taskkill /f /pid <进程ID>
```

### 3. 环境变量问题
```batch
# 手动设置环境变量
set NODE_ENV=development
```

### 4. 依赖问题
```batch
# 重新安装依赖
npm install
```

## 💡 开发最佳实践

1. **使用开发环境启动器**
   - 自动检查依赖
   - 自动设置环境变量
   - 提供错误提示

2. **保持代码整洁**
   - 使用ESLint检查代码
   - 及时提交代码变更
   - 编写清晰的注释

3. **测试API接口**
   - 使用Postman测试
   - 检查响应数据
   - 验证错误处理

4. **监控日志输出**
   - 观察控制台输出
   - 及时发现问题
   - 记录重要信息

## 🚀 快速命令

```batch
# 一键启动开发环境
start-server-dev.bat

# 检查服务状态
netstat -an | findstr :3002

# 查看进程
tasklist | findstr node

# 停止服务
Ctrl + C
```

## 📞 技术支持

如果遇到问题：
1. 检查Node.js版本
2. 确认依赖安装完整
3. 检查端口占用情况
4. 查看错误日志信息
