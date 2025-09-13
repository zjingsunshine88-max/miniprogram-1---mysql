# IP地址部署指南 (223.93.139.87)

## 📋 部署概述

本指南专门针对使用IP地址 `223.93.139.87` 作为生产环境的部署配置。

## 🚨 重要注意事项

### 1. **HTTPS vs HTTP**
- 由于使用IP地址，无法申请SSL证书
- 所有服务都使用HTTP协议
- 小程序需要在微信公众平台配置HTTP域名

### 2. **微信小程序域名配置**
- 在微信公众平台 -> 开发 -> 开发管理 -> 开发设置 -> 服务器域名
- 添加以下域名：
  - request合法域名：`http://223.93.139.87:3002`
  - uploadFile合法域名：`http://223.93.139.87:3002`
  - downloadFile合法域名：`http://223.93.139.87:3002`

### 3. **防火墙配置**
确保以下端口开放：
- 80 (HTTP)
- 3002 (API服务)
- 3001 (后台管理)
- 3306 (MySQL)
- 6379 (Redis)

## 🚀 部署方式

### 方式一：传统部署

```bash
# 1. 配置环境变量
cp env.example .env
# 编辑.env文件，设置数据库密码等

# 2. 运行IP专用部署脚本
chmod +x deploy-ip.sh
./deploy-ip.sh
```

### 方式二：Docker部署

```bash
# 1. 配置环境变量
cp env.example .env

# 2. 使用IP专用Docker配置
docker-compose -f docker-compose-ip.yml up -d

# 3. 查看服务状态
docker-compose -f docker-compose-ip.yml ps
```

## 🔧 配置说明

### 服务访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| 后台管理 | http://223.93.139.87/admin | Vue.js后台管理系统 |
| API服务 | http://223.93.139.87/api | RESTful API接口 |
| 健康检查 | http://223.93.139.87/health | 服务健康状态 |
| 文件上传 | http://223.93.139.87/uploads | 静态文件访问 |

### 环境变量配置

```bash
# 数据库配置
DB_HOST=223.93.139.87
DB_PORT=3306
DB_NAME=practice
DB_USERNAME=root
DB_PASSWORD=LOVEjing96..

# 服务器配置
HOST=223.93.139.87
PORT=3002

# 跨域配置
CORS_ORIGIN=http://223.93.139.87,http://223.93.139.87:3000,http://223.93.139.87:3001

# JWT配置
JWT_SECRET=your-super-secret-jwt-key-change-in-production
```

### 小程序配置

修改 `miniprogram/config/production.js`：
```javascript
module.exports = {
  BASE_URL: 'http://223.93.139.87:3002',
  APP_ID: 'wx93529c7938093719',
  DEBUG: false,
  VERSION: '1.0.0'
}
```

### 后台管理系统配置

修改 `admin/env.production`：
```
VITE_SERVER_URL=http://223.93.139.87:3002
```

## 📱 小程序发布步骤

### 1. 配置微信开发者工具
1. 打开微信开发者工具
2. 导入项目：`miniprogram` 目录
3. 修改AppID为：`wx93529c7938093719`

### 2. 配置服务器域名
在微信公众平台配置：
- 登录微信公众平台
- 进入 开发 -> 开发管理 -> 开发设置 -> 服务器域名
- 添加以下域名：
  - request合法域名：`http://223.93.139.87:3002`
  - uploadFile合法域名：`http://223.93.139.87:3002`
  - downloadFile合法域名：`http://223.93.139.87:3002`

### 3. 上传代码
1. 在微信开发者工具中点击"上传"
2. 填写版本号和项目备注
3. 在微信公众平台提交审核

## 🔍 故障排除

### 常见问题

1. **小程序无法连接API**
   - 检查服务器域名是否在微信公众平台正确配置
   - 确认API服务是否正常运行
   - 检查防火墙是否开放3002端口

2. **后台管理系统无法访问**
   - 检查Nginx配置是否正确
   - 确认后台管理服务是否启动
   - 检查防火墙是否开放80端口

3. **跨域问题**
   - 检查API服务的CORS配置
   - 确认允许的域名包含当前访问地址

4. **数据库连接失败**
   - 检查数据库服务是否启动
   - 验证数据库配置信息
   - 确认防火墙是否开放3306端口

### 日志位置
- API服务日志：`/var/www/question-bank/logs/`
- Nginx日志：`/var/log/nginx/`
- 系统日志：`/var/log/syslog`

### 服务状态检查
```bash
# 检查PM2服务状态
pm2 status

# 检查Nginx状态
sudo systemctl status nginx

# 检查MySQL状态
sudo systemctl status mysql

# 检查端口占用
netstat -tlnp | grep :3002
netstat -tlnp | grep :80
```

## 🔄 更新部署

### 更新代码
```bash
# 1. 拉取最新代码
git pull origin main

# 2. 重新构建前端
cd admin && npm run build

# 3. 重启API服务
cd ../server && pm2 restart question-bank-api
```

### 回滚
```bash
# 使用备份恢复
sudo cp -r /backup/20240101_120000/* /var/www/question-bank/
pm2 restart question-bank-api
```

## 📞 技术支持

如遇到部署问题，请检查：
1. 服务器IP地址是否正确
2. 端口是否被占用
3. 防火墙是否开放相应端口
4. 数据库连接是否正常
5. 微信小程序域名配置是否正确

## ⚠️ 安全提醒

使用IP地址部署时请注意：
1. 定期更新服务器密码
2. 配置防火墙规则
3. 定期备份数据库
4. 监控服务运行状态
5. 及时更新依赖包版本
