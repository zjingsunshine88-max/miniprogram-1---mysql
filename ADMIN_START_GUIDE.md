# Admin启动指南

## 🚀 快速启动

### 前提条件
- ✅ admin目录已存在
- ✅ 已运行 `npm run build` 并生成dist目录
- ✅ Node.js已安装

### 推荐启动方式

#### 1. 使用图形化启动器（最简单）
```batch
admin-launcher.bat
```
- 提供菜单式选择
- 自动检查dist目录
- 支持多种启动方式

#### 2. 使用PM2（生产环境推荐）
```batch
start-admin-pm2.bat
```
- 进程管理
- 自动重启
- 日志记录
- 开机自启动

#### 3. 使用Nginx（生产环境推荐）
```batch
start-admin-nginx.bat
```
- 高性能静态文件服务
- 反向代理API请求
- 静态资源缓存

## 📋 启动方式对比

| 方式 | 适用场景 | 优点 | 缺点 |
|------|----------|------|------|
| Vite预览 | 开发/测试 | 简单快速 | 性能一般 |
| PM2 | 生产环境 | 进程管理、自动重启 | 需要安装PM2 |
| Nginx | 生产环境 | 高性能、反向代理 | 需要安装Nginx |
| HTTP服务器 | 临时使用 | 无需配置 | 功能简单 |

## 🔧 手动启动命令

### 使用Vite预览服务器
```batch
cd admin
npm run serve
```
访问：http://localhost:3001

### 使用PM2
```batch
cd admin
pm2 start "npm run serve" --name admin-frontend
```
访问：http://localhost:3001

### 使用简单HTTP服务器
```batch
cd admin
npx http-server dist -p 3001 -a 0.0.0.0
```
访问：http://localhost:3001

## 🌐 访问地址

启动成功后，可以通过以下地址访问：

- **本地访问**: http://localhost:3001
- **远程访问**: http://223.93.139.87:3001

## 🔍 故障排除

### 1. dist目录不存在
```batch
# 解决方案：重新构建
cd admin
npm run build
```

### 2. 端口被占用
```batch
# 查看端口占用
netstat -ano | findstr :3001

# 结束占用进程
taskkill /f /pid <进程ID>
```

### 3. 权限问题
- 以管理员身份运行命令提示符
- 检查防火墙设置

### 4. Node.js未安装
- 下载安装Node.js: https://nodejs.org/
- 验证安装: `node --version`

## 💡 最佳实践

1. **生产环境**：使用PM2或Nginx
2. **开发环境**：使用Vite预览服务器
3. **临时使用**：使用简单HTTP服务器
4. **不确定时**：使用图形化启动器

## 📞 技术支持

如果遇到问题：
1. 检查dist目录是否存在
2. 确认Node.js已安装
3. 检查端口是否被占用
4. 查看错误日志信息
