# 刷题小程序系统 - Windows环境部署说明

## 📋 系统概述

本系统包含三个主要部分：
- **Admin管理后台**：Vue.js + Element Plus 构建的管理界面
- **Server后端服务**：Node.js + Koa + MySQL 构建的API服务
- **Mini-program小程序**：微信小程序前端

## 🛠️ 环境要求

### Windows环境
- **操作系统**：Windows 10/11 或 Windows Server 2016+
- **Node.js**：v16.0+ (推荐 v18.x LTS)
- **MySQL**：v8.0+
- **IIS**：Windows 10/11 自带 或 Windows Server 的 IIS
- **PM2**：用于进程管理（可选）
- **Git**：用于代码管理

### 开发环境
- **微信开发者工具**：最新版本
- **Visual Studio Code**：推荐代码编辑器
- **MySQL Workbench**：数据库管理工具

## 📁 项目结构

```
miniprogram-1-mysql/
├── admin/                 # 管理后台
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── vite.config.js
├── server/               # 后端服务
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middlewares/
│   ├── config/
│   ├── public/
│   ├── package.json
│   └── app.js
├── miniprogram/          # 微信小程序
│   ├── pages/
│   ├── utils/
│   ├── app.js
│   └── app.json
└── Windows环境部署说明.md
```

## 🚀 部署步骤

### 第一步：环境准备

#### 1.1 安装 Node.js

1. **下载 Node.js**：
   - 访问 https://nodejs.org/
   - 下载 LTS 版本（推荐 v18.x）
   - 选择 Windows Installer (.msi)

2. **安装 Node.js**：
   - 运行下载的 .msi 文件
   - 按照安装向导完成安装
   - 确保勾选 "Add to PATH" 选项

3. **验证安装**：
   ```cmd
   node --version
   npm --version
   ```

#### 1.2 安装 MySQL

1. **下载 MySQL**：
   - 访问 https://dev.mysql.com/downloads/mysql/
   - 选择 MySQL Community Server
   - 下载 Windows (x86, 64-bit), MSI Installer

2. **安装 MySQL**：
   - 运行下载的 .msi 文件
   - 选择 "Developer Default" 或 "Server only"
   - 设置 root 密码（请记住此密码）
   - 完成安装

3. **启动 MySQL 服务**：
   - 打开 "服务" 管理器（services.msc）
   - 找到 "MySQL80" 服务
   - 右键选择 "启动"，并设置为 "自动启动"

4. **验证安装**：
   ```cmd
   mysql -u root -p
   # 输入密码后应该能进入 MySQL 命令行
   ```

#### 1.3 安装 Git（如果未安装）

1. **下载 Git**：
   - 访问 https://git-scm.com/download/win
   - 下载最新版本

2. **安装 Git**：
   - 运行下载的安装程序
   - 按照默认设置完成安装

#### 1.4 安装 PM2（可选）

```cmd
npm install -g pm2
npm install -g pm2-windows-startup
```

### 第二步：数据库配置

#### 2.1 创建数据库和用户

1. **打开 MySQL Workbench** 或使用命令行：

```cmd
mysql -u root -p
```

2. **执行以下 SQL 命令**：

```sql
-- 创建数据库
CREATE DATABASE question_bank_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户
CREATE USER 'question_user'@'localhost' IDENTIFIED BY 'your_strong_password';

-- 授权
GRANT ALL PRIVILEGES ON question_bank_db.* TO 'question_user'@'localhost';
FLUSH PRIVILEGES;

-- 退出
EXIT;
```

#### 2.2 配置数据库连接

编辑 `server/config/database.js`：

```javascript
module.exports = {
  development: {
    username: 'question_user',
    password: 'your_strong_password',
    database: 'question_bank_db',
    host: 'localhost',
    dialect: 'mysql',
    timezone: '+08:00'
  },
  production: {
    username: 'question_user',
    password: 'your_strong_password',
    database: 'question_bank_db',
    host: 'localhost',
    dialect: 'mysql',
    timezone: '+08:00',
    logging: false, // 生产环境关闭SQL日志
    pool: {
      max: 20,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
}
```

### 第三步：代码部署

#### 3.1 克隆或下载代码

1. **使用 Git 克隆**（推荐）：
   ```cmd
   # 创建项目目录
   mkdir C:\www\question-bank
   cd C:\www\question-bank
   
   # 克隆代码（替换为实际仓库地址）
   git clone https://github.com/your-username/miniprogram-1-mysql.git .
   ```

2. **或直接下载 ZIP 文件**：
   - 下载项目 ZIP 文件
   - 解压到 `C:\www\question-bank` 目录

#### 3.2 安装依赖

**安装 Server 依赖**：
```cmd
cd C:\www\question-bank\server
npm install
```

**安装 Admin 依赖**：
```cmd
cd C:\www\question-bank\admin
npm install
```

#### 3.3 构建 Admin 前端

```cmd
cd C:\www\question-bank\admin
npm run build
```

构建完成后，`dist` 目录将包含生产环境的静态文件。

### 第四步：配置服务

#### 4.1 配置 IIS（推荐用于生产环境）

1. **启用 IIS 功能**：
   - 打开 "控制面板" → "程序" → "启用或关闭 Windows 功能"
   - 勾选 "Internet Information Services"
   - 展开并勾选以下子项：
     - Web 管理工具
     - 万维网服务
     - 应用程序开发功能

2. **安装 IIS 扩展**：
   - 下载并安装 "URL Rewrite Module"：https://www.iis.net/downloads/microsoft/url-rewrite
   - 下载并安装 "Application Request Routing"：https://www.iis.net/downloads/microsoft/application-request-routing

3. **创建网站**：
   - 打开 IIS 管理器
   - 右键 "网站" → "添加网站"
   - 网站名称：`question-bank`
   - 物理路径：`C:\www\question-bank\admin\dist`
   - 端口：`80`（或自定义端口）

4. **配置反向代理**：
   - 在网站根目录下创建 `web.config` 文件：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <!-- API 请求代理到后端服务 -->
                <rule name="API Proxy" stopProcessing="true">
                    <match url="^api/(.*)" />
                    <action type="Rewrite" url="http://localhost:3002/api/{R:1}" />
                </rule>
                
                <!-- 静态文件请求 -->
                <rule name="Static Files" stopProcessing="true">
                    <match url="^uploads/(.*)" />
                    <action type="Rewrite" url="C:\www\question-bank\server\public\uploads\{R:1}" />
                </rule>
                
                <!-- SPA 路由支持 -->
                <rule name="SPA Routes" stopProcessing="true">
                    <match url=".*" />
                    <conditions logicalGrouping="MatchAll">
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="/" />
                </rule>
            </rules>
        </rewrite>
        
        <!-- 静态文件 MIME 类型 -->
        <staticContent>
            <mimeMap fileExtension=".json" mimeType="application/json" />
            <mimeMap fileExtension=".woff" mimeType="application/font-woff" />
            <mimeMap fileExtension=".woff2" mimeType="application/font-woff2" />
        </staticContent>
        
        <!-- 安全头 -->
        <httpProtocol>
            <customHeaders>
                <add name="X-Frame-Options" value="SAMEORIGIN" />
                <add name="X-XSS-Protection" value="1; mode=block" />
                <add name="X-Content-Type-Options" value="nosniff" />
            </customHeaders>
        </httpProtocol>
    </system.webServer>
</configuration>
```

#### 4.2 配置 PM2（可选）

创建 PM2 配置文件 `server/ecosystem.config.js`：

```javascript
module.exports = {
  apps: [{
    name: 'question-bank-server',
    script: 'app.js',
    cwd: 'C:\\www\\question-bank\\server',
    instances: 1, // Windows 下建议使用 1 个实例
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3002
    },
    error_file: 'C:\\logs\\pm2\\question-bank-error.log',
    out_file: 'C:\\logs\\pm2\\question-bank-out.log',
    log_file: 'C:\\logs\\pm2\\question-bank-combined.log',
    time: true,
    max_memory_restart: '1G'
  }]
}
```

### 第五步：启动服务

#### 5.1 初始化数据库

```cmd
cd C:\www\question-bank\server
set NODE_ENV=production
node -e "
const { sequelize } = require('./config/database');
sequelize.sync({ force: false }).then(() => {
  console.log('数据库同步完成');
  process.exit(0);
}).catch(err => {
  console.error('数据库同步失败:', err);
  process.exit(1);
});
"
```

#### 5.2 启动后端服务

**方法一：使用 PM2（推荐）**
```cmd
cd C:\www\question-bank\server
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

**方法二：直接启动**
```cmd
cd C:\www\question-bank\server
set NODE_ENV=production
node app.js
```

#### 5.3 启动 IIS 服务

1. **启动 IIS**：
   - 打开 "服务" 管理器（services.msc）
   - 找到 "World Wide Web Publishing Service"
   - 右键选择 "启动"，并设置为 "自动启动"

2. **验证服务状态**：
   ```cmd
   # 检查端口监听
   netstat -an | findstr :3002
   netstat -an | findstr :80
   
   # 测试 API
   curl http://localhost:3002/health
   
   # 测试网站
   curl http://localhost
   ```

## 🔧 小程序配置

### 6.1 修改小程序配置

编辑 `miniprogram/utils/server-api.js`，更新服务器地址：

```javascript
// 生产环境配置
const getServerUrl = () => {
  return 'http://your-server-ip'  // 替换为实际服务器IP或域名
}
```

### 6.2 微信小程序配置

1. **登录微信公众平台**：https://mp.weixin.qq.com
2. **配置服务器域名**：
   - 在"开发" -> "开发管理" -> "开发设置"中添加服务器域名
   - request合法域名：`http://your-server-ip`
   - uploadFile合法域名：`http://your-server-ip`
   - downloadFile合法域名：`http://your-server-ip`

3. **上传代码**：
   - 使用微信开发者工具打开 `miniprogram` 目录
   - 点击"上传"按钮上传代码
   - 在微信公众平台提交审核

## 🔒 SSL 证书配置（可选）

### 使用 Let's Encrypt 证书

1. **安装 Certbot**：
   - 下载 Windows 版本的 Certbot
   - 或使用 WSL（Windows Subsystem for Linux）

2. **获取证书**：
   ```bash
   # 在 WSL 中执行
   sudo certbot certonly --standalone -d your-domain.com
   ```

3. **配置 IIS SSL**：
   - 在 IIS 管理器中绑定 HTTPS
   - 选择获取的证书文件

## 📊 监控和维护

### 7.1 日志管理

**PM2 日志**：
```cmd
# 查看应用日志
pm2 logs question-bank-server

# 查看实时日志
pm2 logs question-bank-server --lines 100
```

**IIS 日志**：
- 位置：`C:\inetpub\logs\LogFiles\W3SVC1\`
- 使用 IIS 管理器查看日志

### 7.2 性能监控

```cmd
# PM2 监控
pm2 monit

# 系统资源监控
# 使用任务管理器或性能监视器
```

### 7.3 备份策略

**数据库备份脚本** `backup.bat`：
```batch
@echo off
set DATE=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set DATE=%DATE: =0%
mysqldump -u question_user -p question_bank_db > C:\backup\question_bank_%DATE%.sql
echo 备份完成: question_bank_%DATE%.sql

REM 删除7天前的备份
forfiles /p C:\backup /m question_bank_*.sql /d -7 /c "cmd /c del @path"
```

**设置定时任务**：
1. 打开 "任务计划程序"
2. 创建基本任务
3. 设置触发器为每日
4. 操作选择运行 `backup.bat`

## 🚨 故障排除

### 常见问题

1. **服务无法启动**
   ```cmd
   # 检查端口占用
   netstat -an | findstr :3002
   
   # 检查日志
   pm2 logs question-bank-server
   ```

2. **数据库连接失败**
   ```cmd
   # 检查 MySQL 服务
   sc query mysql80
   
   # 测试连接
   mysql -u question_user -p -h localhost question_bank_db
   ```

3. **IIS 无法访问**
   - 检查防火墙设置
   - 检查 IIS 服务状态
   - 查看 IIS 日志

4. **静态文件无法访问**
   - 检查文件权限
   - 检查 MIME 类型配置
   - 检查 URL 重写规则

## 📋 部署检查清单

- [ ] Node.js 安装完成
- [ ] MySQL 安装和配置完成
- [ ] 数据库创建和用户配置完成
- [ ] 代码部署完成
- [ ] 依赖安装完成
- [ ] Admin 前端构建完成
- [ ] IIS 配置完成
- [ ] PM2 配置完成（可选）
- [ ] 数据库初始化完成
- [ ] 后端服务启动成功
- [ ] IIS 服务启动成功
- [ ] API 接口测试通过
- [ ] 网站访问正常
- [ ] 小程序域名配置完成
- [ ] 监控和备份策略配置完成

## 🔄 更新部署

### 更新代码
```cmd
cd C:\www\question-bank
git pull origin main

# 更新后端
cd server
npm install
pm2 restart question-bank-server

# 更新前端
cd ..\admin
npm install
npm run build
# 重启 IIS 或刷新网站
```

## 🛠️ 开发环境快速启动

### 使用批处理文件

创建 `start-dev.bat`：
```batch
@echo off
echo 启动开发环境...

REM 启动后端服务
start "Server" cmd /k "cd /d C:\www\question-bank\server && npm start"

REM 等待2秒
timeout /t 2

REM 启动前端开发服务器
start "Admin" cmd /k "cd /d C:\www\question-bank\admin && npm run dev"

echo 开发环境启动完成！
echo 后端服务: http://localhost:3002
echo 前端服务: http://localhost:3000
pause
```

## 📞 技术支持

如遇到部署问题，请检查：
1. 服务日志：`pm2 logs question-bank-server`
2. IIS 日志：`C:\inetpub\logs\LogFiles\W3SVC1\`
3. 系统事件日志：事件查看器
4. 数据库连接状态
5. 网络连接和防火墙设置

---

**注意**：Windows 环境部署相对简单，但生产环境建议使用 Windows Server 以获得更好的性能和稳定性。
