# Admin管理后台SSL部署指南

## 概述

本指南介绍如何使用SSL证书部署Admin管理后台，让admin调用远程API `https://practice.insightdate.top/api`。

## 前置条件

### 1. SSL证书配置
确保SSL证书已正确配置到 `C:\certificates` 目录：
- `C:\certificates\admin.practice.insightdata.top.pem` - SSL证书文件
- `C:\certificates\admin.practice.insightdata.top.key` - SSL私钥文件

### 2. 系统要求
- Windows 10/11
- Node.js (推荐v16+)
- nginx (已安装并添加到PATH)
- PowerShell 5.1+ (用于PowerShell脚本)

## 快速启动

### 方法1: 使用批处理脚本 (推荐)
```bash
# 启动服务
start-admin-ssl.bat

# 停止服务
stop-admin-ssl.bat
```

### 方法2: 使用PowerShell脚本
```powershell
# 启动服务
.\start-admin-ssl.ps1

# 停止服务
.\stop-admin-ssl.ps1

# 启动服务（跳过构建）
.\start-admin-ssl.ps1 -SkipBuild

# 启动服务（详细输出）
.\start-admin-ssl.ps1 -Verbose

# 强制停止服务
.\stop-admin-ssl.ps1 -Force
```

## 访问地址

启动成功后，可以通过以下地址访问：

- **生产环境**: https://admin.practice.insightdate.top
- **本地测试**: http://localhost (nginx代理)
- **静态文件位置**: C:\admin

## 配置说明

### 1. API配置
Admin将调用远程API: `https://practice.insightdate.top/api`

所有API文件已更新为使用新的远程地址：
- `admin/src/api/admin.js`
- `admin/src/api/question.js`
- `admin/src/api/user.js`
- `admin/src/api/questionBank.js`
- `admin/src/api/subject.js`
- `admin/src/api/activationCode.js`

### 2. 环境变量
生产环境配置在 `admin/env.production`:
```
VITE_SERVER_URL=https://practice.insightdate.top
VITE_API_BASE_URL=https://practice.insightdate.top/api
```

### 3. Nginx配置
系统nginx路径: `C:\nginx`
SSL配置文件: `C:\nginx\conf.d\admin-ssl.conf`

**首次配置**:
```bash
# 以管理员身份运行
setup-system-nginx.bat
```

主要特性：
- HTTP自动重定向到HTTPS
- SSL证书配置
- 直接服务C:\admin目录中的静态文件
- 安全头设置
- 静态资源缓存
- SPA路由支持（try_files）

## 故障排除

### 1. SSL证书问题
```
[错误] SSL证书文件不存在: C:\certificates\admin.practice.insightdata.top.pem
```
**解决方案**: 确保SSL证书文件已正确放置到指定目录

### 2. nginx未安装
```
[错误] nginx未安装或未添加到PATH环境变量
```
**解决方案**: 
1. 下载并安装nginx
2. 将nginx.exe所在目录添加到系统PATH环境变量

### 3. Node.js未安装
```
[错误] Node.js未安装或未添加到PATH环境变量
```
**解决方案**: 
1. 从官网下载并安装Node.js
2. 确保npm命令可用

### 4. 端口占用
如果端口80或443被占用：
```bash
# 查看端口占用
netstat -ano | findstr :80
netstat -ano | findstr :443

# 停止占用进程
taskkill /f /pid <进程ID>
```

### 5. 构建失败
如果admin项目构建失败：
```bash
# 进入admin目录
cd admin

# 清理并重新安装依赖
rm -rf node_modules
npm install

# 重新构建
npm run build
```

## 服务管理

### 启动服务
1. **首次运行**：以管理员身份运行 `setup-system-nginx.bat` 配置系统nginx
2. **启动服务**：双击 `start-admin-ssl.bat` 或在命令行运行
3. 脚本会自动：
   - 检查SSL证书
   - 检查系统nginx配置
   - 安装依赖（如果需要）
   - 构建admin项目
   - 将构建文件复制到C:\admin
   - 启动系统nginx

### 停止服务
1. 双击 `stop-admin-ssl.bat` 或在命令行运行
2. 或使用PowerShell脚本：`.\stop-admin-ssl.ps1`

### 查看服务状态
```bash
# 检查nginx进程
tasklist | findstr nginx

# 检查静态文件
dir C:\admin

# 检查端口占用
netstat -ano | findstr :80
netstat -ano | findstr :443
```

## 开发模式

如果需要开发模式（不构建，直接运行dev服务器）：

1. 修改 `start-admin-ssl.bat` 中的构建命令
2. 或使用PowerShell脚本的 `-SkipBuild` 参数

## 安全注意事项

1. **SSL证书**: 确保使用有效的SSL证书
2. **防火墙**: 确保防火墙允许80和443端口
3. **权限**: 以管理员身份运行脚本（如果需要）
4. **日志**: 定期检查nginx和admin的日志文件

## 更新和维护

### 更新admin代码
```bash
cd admin
git pull
npm install
npm run build
```

### 更新nginx配置
修改 `nginx/conf.d/admin-ssl.conf` 后：
```bash
nginx -t -c nginx/nginx.conf
nginx -s reload
```

### 更新SSL证书
1. 将新证书文件放置到 `C:\certificates`
2. 重启nginx服务

## 联系支持

如果遇到问题，请检查：
1. 系统日志
2. nginx错误日志
3. admin控制台输出
4. 网络连接状态
