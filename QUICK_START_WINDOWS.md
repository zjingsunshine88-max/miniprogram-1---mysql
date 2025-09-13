# Windows快速部署指南

## 🚀 5分钟快速部署

### 1. 环境准备
```powershell
# 下载并安装以下软件：
# - Node.js 18+: https://nodejs.org/
# - MySQL 8.0: https://dev.mysql.com/downloads/mysql/
# - Git: https://git-scm.com/
```

### 2. 一键部署
```powershell
# 1. 克隆项目
git clone <your-repo-url>
cd miniprogram-1-mysql

# 2. 运行Windows部署脚本
deploy-windows.bat
```

### 3. 启动服务
```powershell
# 使用服务管理工具
windows-services.bat

# 或直接启动
start-services.bat
```

## 📋 部署清单

### ✅ 必需软件
- [ ] Node.js 18+
- [ ] MySQL 8.0
- [ ] Git

### ✅ 配置文件
- [ ] 数据库密码: `LOVEjing96..`
- [ ] API端口: `3002`
- [ ] 后台管理端口: `3001`
- [ ] 服务器IP: `223.93.139.87`

### ✅ 微信小程序配置
- [ ] AppID: `wx93529c7938093719`
- [ ] 服务器域名: `http://223.93.139.87:3002`

## 🔧 常用命令

```powershell
# 查看服务状态
pm2 status

# 重启API服务
pm2 restart question-bank-api

# 查看日志
pm2 logs question-bank-api

# 停止所有服务
stop-services.bat

# 启动所有服务
start-services.bat
```

## 🌐 访问地址

- **后台管理**: http://223.93.139.87/admin
- **API服务**: http://223.93.139.87/api
- **健康检查**: http://223.93.139.87/health

## 📞 遇到问题？

1. 检查防火墙是否开放端口
2. 确认MySQL服务已启动
3. 查看PM2服务状态
4. 检查日志文件

详细说明请参考：`README_WINDOWS_DEPLOYMENT.md`
