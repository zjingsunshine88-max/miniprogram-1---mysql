# 刷题小程序生产环境部署指南

## 📋 部署概述

本系统包含三个主要组件：
- **后台管理系统** (admin) - Vue.js + Element Plus
- **API服务** (server) - Node.js + Koa + MySQL
- **小程序** (miniprogram) - 微信小程序

## 🚀 部署方式

### 方式一：传统部署（推荐）

#### 1. 服务器准备
```bash
# 安装Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装MySQL
sudo apt-get install mysql-server

# 安装Nginx
sudo apt-get install nginx

# 安装PM2
sudo npm install -g pm2
```

#### 2. 部署步骤
```bash
# 1. 克隆代码
git clone <your-repo-url>
cd miniprogram-1-mysql

# 2. 配置环境变量
cp env.example .env
# 编辑.env文件，修改数据库密码等配置

# 3. 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

#### 3. 手动配置
如果自动部署脚本不可用，可以手动执行以下步骤：

```bash
# 1. 构建后台管理系统
cd admin
npm install
npm run build

# 2. 准备API服务
cd ../server
npm install --production

# 3. 初始化数据库
npm run init-db
npm run init-admin

# 4. 启动服务
npm run pm2:start
```

### 方式二：Docker部署

#### 1. 安装Docker和Docker Compose
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker
```

#### 2. 部署
```bash
# 1. 配置环境变量
cp env.example .env
# 编辑.env文件

# 2. 启动所有服务
docker-compose up -d

# 3. 查看服务状态
docker-compose ps

# 4. 查看日志
docker-compose logs -f
```

## 🔧 配置说明

### 环境变量配置

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| DB_HOST | 数据库主机 | localhost |
| DB_PORT | 数据库端口 | 3306 |
| DB_NAME | 数据库名 | practice |
| DB_USERNAME | 数据库用户名 | root |
| DB_PASSWORD | 数据库密码 | your_password |
| JWT_SECRET | JWT密钥 | your-secret-key |
| PORT | API服务端口 | 3002 |
| CORS_ORIGIN | 跨域允许的域名 | http://your-domain.com |

### 小程序配置

修改 `miniprogram/utils/server-api.js` 中的配置：
```javascript
// 生产环境
const config = require('../config/production.js')

// 开发环境
// const config = require('../config/development.js')
```

### 后台管理系统配置

修改 `admin/env.production` 文件：
```
VITE_SERVER_URL=https://your-api-domain.com
```

## 📱 小程序配置

### 1. 修改API地址
```javascript
// miniprogram/config/production.js
module.exports = {
  BASE_URL: 'https://your-api-domain.com',
  APP_ID: 'wxfc05c5bc952c4524'
}
```

### 2. 微信开发者工具配置
1. 打开微信开发者工具
2. 导入项目目录：`miniprogram`
3. 修改AppID为你的小程序AppID
4. 配置服务器域名：
   - request合法域名：`https://your-api-domain.com`
   - uploadFile合法域名：`https://your-api-domain.com`
   - downloadFile合法域名：`https://your-api-domain.com`

### 3. 上传代码
1. 点击"上传"按钮
2. 填写版本号和项目备注
3. 在微信公众平台提交审核

## 🔒 SSL证书配置

### 使用Let's Encrypt（免费）
```bash
# 安装certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 监控和维护

### PM2监控
```bash
# 查看服务状态
pm2 status

# 查看日志
pm2 logs question-bank-api

# 重启服务
pm2 restart question-bank-api

# 监控面板
pm2 monit
```

### 数据库维护
```bash
# 备份数据库
mysqldump -u root -p practice > backup_$(date +%Y%m%d).sql

# 恢复数据库
mysql -u root -p practice < backup_20240101.sql
```

### 日志管理
```bash
# 查看API日志
tail -f /var/www/question-bank/logs/out.log

# 查看错误日志
tail -f /var/www/question-bank/logs/error.log

# 清理旧日志
find /var/www/question-bank/logs -name "*.log" -mtime +30 -delete
```

## 🚨 故障排除

### 常见问题

1. **数据库连接失败**
   - 检查数据库服务是否启动
   - 验证数据库配置信息
   - 确认防火墙设置

2. **API服务无法访问**
   - 检查PM2服务状态
   - 查看端口是否被占用
   - 验证Nginx配置

3. **小程序无法连接API**
   - 确认服务器域名配置
   - 检查SSL证书是否有效
   - 验证跨域设置

4. **文件上传失败**
   - 检查上传目录权限
   - 验证文件大小限制
   - 确认磁盘空间

### 日志位置
- API服务日志：`/var/www/question-bank/logs/`
- Nginx日志：`/var/log/nginx/`
- 系统日志：`/var/log/syslog`

## 📞 技术支持

如遇到部署问题，请检查：
1. 服务器配置是否满足要求
2. 环境变量是否正确设置
3. 服务端口是否被占用
4. 数据库连接是否正常
5. 网络连接是否畅通

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
