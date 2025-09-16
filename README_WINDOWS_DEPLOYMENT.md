# Windows系统部署指南 (223.93.139.87)

## 📋 部署概述

本指南专门针对在Windows服务器上部署刷题小程序系统，使用IP地址 `223.93.139.87` 作为生产环境。

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

### 3. **Windows防火墙配置**
确保以下端口开放：
- 80 (HTTP)
- 3002 (API服务)
- 3001 (后台管理)
- 3306 (MySQL)
- 6379 (Redis)

## 🔧 环境准备

### 1. 安装必要软件

#### Node.js
```powershell
# 下载并安装 Node.js 18+
# 访问 https://nodejs.org/ 下载 LTS 版本
# 安装完成后验证
node --version
npm --version
```

#### MySQL
```powershell
# 下载并安装 MySQL 8.0
# 访问 https://dev.mysql.com/downloads/mysql/
# 安装时设置root密码为: LOVEjing96..
```

#### PM2 (进程管理)
```powershell
# 全局安装PM2
npm install -g pm2
npm install -g pm2-windows-startup

# 设置PM2开机自启
pm2-startup install
```

#### Nginx (可选)
```powershell
# 下载Nginx for Windows
# 访问 http://nginx.org/en/download.html
# 解压到 C:\nginx
```

## 🚀 部署步骤

### 1. 创建项目目录
```powershell
# 创建项目目录
mkdir C:\question-bank
cd C:\question-bank

# 克隆或复制项目文件到此目录
```

### 2. 配置环境变量

创建 `C:\question-bank\.env` 文件：
```env
# 数据库配置
DB_HOST=localhost
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

### 3. 构建后台管理系统

```powershell
# 进入后台管理目录
cd C:\question-bank\admin

# 安装依赖
npm install

# 构建生产版本
npm run build

# 构建完成后，dist目录包含所有静态文件
```

### 4. 配置API服务

```powershell
# 进入API服务目录
cd C:\question-bank\server

# 安装生产依赖
npm install --production

# 创建日志目录
mkdir logs
mkdir public\uploads

# 设置环境变量
$env:NODE_ENV="production"
```

### 5. 初始化数据库

```powershell
# 确保MySQL服务已启动
net start mysql

# 创建数据库
mysql -u root -pLOVEjing96.. -e "CREATE DATABASE IF NOT EXISTS practice;"

# 运行数据库初始化脚本
node scripts\init-db.js

# 创建管理员用户
node scripts\init-admin.js
```

### 6. 启动API服务

```powershell
# 使用PM2启动API服务
pm2 start app.js --name "question-bank-api" --env production

# 保存PM2配置
pm2 save

# 查看服务状态
pm2 status
```

### 7. 启动后台管理系统

有多种方式启动admin服务：

#### 方式一：使用启动器（推荐）
```powershell
# 运行图形化启动器
admin-launcher.bat
```

#### 方式二：使用PM2（生产环境推荐）
```powershell
# 使用PM2启动admin
start-admin-pm2.bat
```

#### 方式三：使用Nginx（生产环境推荐）
```powershell
# 使用Nginx启动admin
start-admin-nginx.bat
```

#### 方式四：使用Vite预览服务器
```powershell
# 使用Vite预览服务器
start-admin.bat
```

#### 方式五：使用简单HTTP服务器
```powershell
# 使用简单HTTP服务器
start-admin-simple.bat
```

### 7. 配置Nginx (可选)

创建 `C:\nginx\conf\nginx.conf`：
```nginx
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  223.93.139.87;

        # 后台管理系统
        location /admin {
            alias C:/question-bank/admin/dist;
            try_files $uri $uri/ /admin/index.html;
            
            # 静态资源缓存
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # API服务
        location /api {
            proxy_pass http://localhost:3002;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            
            # 文件上传大小限制
            client_max_body_size 20M;
        }

        # 健康检查
        location /health {
            proxy_pass http://localhost:3002;
        }

        # 静态文件
        location /uploads {
            proxy_pass http://localhost:3002;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # 默认路由到后台管理
        location / {
            root C:/question-bank/admin/dist;
            try_files $uri $uri/ /index.html;
        }
    }
}
```

启动Nginx：
```powershell
# 进入Nginx目录
cd C:\nginx

# 启动Nginx
start nginx.exe

# 检查配置
nginx.exe -t

# 重新加载配置
nginx.exe -s reload
```

## 📱 小程序配置

### 1. 修改小程序配置

编辑 `miniprogram\config\production.js`：
```javascript
module.exports = {
  BASE_URL: 'http://223.93.139.87:3002',
  APP_ID: 'wx93529c7938093719',
  DEBUG: false,
  VERSION: '1.0.0'
}
```

### 2. 微信公众平台配置

在微信公众平台配置服务器域名：
- 登录微信公众平台
- 进入 开发 -> 开发管理 -> 开发设置 -> 服务器域名
- 添加以下域名：
  - request合法域名：`http://223.93.139.87:3002`
  - uploadFile合法域名：`http://223.93.139.87:3002`
  - downloadFile合法域名：`http://223.93.139.87:3002`

## 🔧 Windows服务配置

### 1. 创建Windows服务脚本

创建 `C:\question-bank\start-services.bat`：
```batch
@echo off
echo Starting Question Bank Services...

REM 设置环境变量
set NODE_ENV=production

REM 启动API服务
cd /d C:\question-bank\server
pm2 start app.js --name "question-bank-api" --env production

REM 启动Nginx (如果使用)
cd /d C:\nginx
start nginx.exe

echo Services started successfully!
pause
```

### 2. 创建停止服务脚本

创建 `C:\question-bank\stop-services.bat`：
```batch
@echo off
echo Stopping Question Bank Services...

REM 停止PM2服务
pm2 stop question-bank-api
pm2 delete question-bank-api

REM 停止Nginx
taskkill /f /im nginx.exe

echo Services stopped successfully!
pause
```

### 3. 设置开机自启动

创建 `C:\question-bank\install-service.bat`：
```batch
@echo off
echo Installing Question Bank as Windows Service...

REM 安装PM2开机自启
pm2-startup install

REM 启动服务并保存配置
pm2 start app.js --name "question-bank-api" --env production
pm2 save

REM 创建启动脚本的快捷方式到启动文件夹
copy "C:\question-bank\start-services.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"

echo Service installed successfully!
pause
```

## 🔍 故障排除

### 常见问题

1. **Terser依赖缺失**
```powershell
# 错误信息: terser not found
# 解决方案1: 安装terser依赖
cd admin
npm install terser --save-dev

# 解决方案2: 使用备用构建脚本
build-admin.bat

# 解决方案3: 手动安装terser
install-terser.bat
```

2. **端口被占用**
```powershell
# 查看端口占用情况
netstat -ano | findstr :3002
netstat -ano | findstr :80

# 结束占用端口的进程
taskkill /PID <进程ID> /F
```

2. **PM2服务无法启动**
```powershell
# 查看PM2日志
pm2 logs question-bank-api

# 重启服务
pm2 restart question-bank-api

# 删除并重新创建服务
pm2 delete question-bank-api
pm2 start app.js --name "question-bank-api"
```

3. **数据库连接失败**
```powershell
# 检查MySQL服务状态
net start mysql

# 测试数据库连接
mysql -u root -pLOVEjing96.. -e "SHOW DATABASES;"

# 检查防火墙设置
netsh advfirewall firewall show rule name="MySQL"
```

4. **Nginx配置错误**
```powershell
# 检查Nginx配置
C:\nginx\nginx.exe -t

# 查看Nginx错误日志
type C:\nginx\logs\error.log
```

### 服务状态检查

```powershell
# 检查PM2服务状态
pm2 status

# 检查Node.js进程
tasklist | findstr node

# 检查Nginx进程
tasklist | findstr nginx

# 检查端口监听
netstat -an | findstr :3002
netstat -an | findstr :80
```

## 🔄 更新部署

### 更新代码
```powershell
# 1. 停止服务
pm2 stop question-bank-api

# 2. 备份当前版本
xcopy C:\question-bank C:\question-bank-backup-%date:~0,10% /E /I

# 3. 更新代码 (如果使用Git)
cd C:\question-bank
git pull origin main

# 4. 重新构建前端
cd admin
npm run build

# 5. 重启API服务
cd ..\server
pm2 restart question-bank-api
```

### 回滚
```powershell
# 停止当前服务
pm2 stop question-bank-api

# 恢复备份
xcopy C:\question-bank-backup-2024-01-01 C:\question-bank /E /Y

# 重启服务
pm2 restart question-bank-api
```

## 📊 监控和维护

### 1. 日志管理

```powershell
# 查看API服务日志
pm2 logs question-bank-api

# 查看Nginx访问日志
type C:\nginx\logs\access.log

# 查看Nginx错误日志
type C:\nginx\logs\error.log

# 清理旧日志
forfiles /p C:\question-bank\logs /s /m *.log /d -30 /c "cmd /c del @path"
```

### 2. 性能监控

```powershell
# PM2监控面板
pm2 monit

# 系统资源监控
tasklist /svc
wmic cpu get loadpercentage
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory
```

### 3. 数据库维护

```powershell
# 备份数据库
mysqldump -u root -pLOVEjing96.. practice > C:\backup\practice_%date:~0,10%.sql

# 恢复数据库
mysql -u root -pLOVEjing96.. practice < C:\backup\practice_2024-01-01.sql
```

## 📞 技术支持

如遇到部署问题，请检查：
1. Windows防火墙是否开放相应端口
2. 服务是否正常启动
3. 数据库连接是否正常
4. 微信小程序域名配置是否正确
5. 日志文件中的错误信息

## ⚠️ 安全提醒

使用Windows服务器部署时请注意：
1. 定期更新Windows系统补丁
2. 配置Windows防火墙规则
3. 定期备份数据库和代码
4. 监控服务运行状态
5. 使用强密码和定期更换
6. 限制远程桌面访问权限
