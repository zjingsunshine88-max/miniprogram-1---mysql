# 宝塔面板题目上传权限修复指南

## 问题描述

在宝塔面板部署后，题目上传功能返回500错误：
```
EACCES: permission denied, mkdir '/www/wwwroot/temp'
```

这是因为Node.js进程没有足够的权限在 `/www/wwwroot` 目录下创建 `temp` 目录。

## 解决方案

### 方案一：在宝塔面板中手动创建目录（推荐）

#### 步骤1：打开宝塔面板文件管理器
1. 登录宝塔面板
2. 点击左侧菜单 "文件"
3. 进入 `/www/wwwroot` 目录

#### 步骤2：创建必要的目录
在 `/www/wwwroot` 目录下创建以下目录结构：
```
/www/wwwroot/
├── temp/              # 临时文件目录
└── public/
    └── uploads/
        └── images/    # 图片上传目录
```

#### 步骤3：设置目录权限
1. 选中 `temp` 目录，点击 "权限"
2. 设置权限为 `755`
3. 设置所有者/用户组为 `www:www`
4. 勾选 "应用到子目录"
5. 点击 "确定"

6. 同样设置 `public` 目录及其子目录的权限

#### 步骤4：验证权限
在宝塔面板终端中执行：
```bash
cd /www/wwwroot
ls -la temp
ls -la public/uploads
```

应该看到类似输出：
```
drwxr-xr-x 2 www www 4096 Oct 16 07:10 temp
drwxr-xr-x 3 www www 4096 Oct 16 07:10 public
```

### 方案二：使用命令行创建（需要SSH访问）

```bash
# 进入项目目录
cd /www/wwwroot

# 创建目录
mkdir -p temp public/uploads/images

# 设置权限
chmod -R 755 temp public/uploads

# 设置所有者
chown -R www:www temp public/uploads

# 验证
ls -la | grep -E 'temp|public'
```

### 方案三：使用代码自动修复

#### 运行修复脚本
```bash
cd /www/wwwroot
node fix-upload-permission.js
```

#### 重启API服务
```bash
# 如果使用PM2
pm2 restart all

# 如果使用systemd
systemctl restart your-api-service

# 如果使用宝塔面板Node项目管理
# 在宝塔面板中重启Node项目
```

## 环境变量配置（可选）

如果需要使用自定义临时目录，可以设置环境变量：

### 在宝塔面板Node项目中设置
1. 打开宝塔面板 "软件商店"
2. 找到 "PM2管理器" 或 "Node项目管理"
3. 选择你的项目
4. 添加环境变量：
   ```
   TEMP_DIR=/tmp/question-upload
   ```

### 在启动脚本中设置
```bash
export TEMP_DIR=/tmp/question-upload
node app.js
```

## 验证修复

### 1. 检查目录是否存在
```bash
ls -la /www/wwwroot/temp
ls -la /www/wwwroot/public/uploads/images
```

### 2. 测试上传功能
1. 登录管理后台
2. 进入"题目管理" -> "智能上传"
3. 选择题库和科目
4. 上传一个测试文件
5. 点击"确认导入"

### 3. 查看日志
```bash
# 查看API服务日志
pm2 logs

# 或查看宝塔面板日志
tail -f /www/wwwroot/logs/error.log
```

## 常见问题

### Q1: 仍然提示权限不足
**A**: 确保目录所有者是 `www:www`，权限是 `755`

### Q2: 无法在宝塔面板中创建目录
**A**: 检查当前用户是否有 `/www/wwwroot` 的写权限

### Q3: 重启服务后问题仍然存在
**A**: 确保环境变量已正确设置，并重启所有相关服务

### Q4: 临时文件占用磁盘空间
**A**: 定期清理临时目录：
```bash
rm -rf /www/wwwroot/temp/*
```

## 预防措施

### 1. 定期清理临时文件
创建定时任务：
```bash
# 每天凌晨2点清理临时文件
0 2 * * * rm -rf /www/wwwroot/temp/*
```

### 2. 监控磁盘空间
在宝塔面板中设置磁盘空间告警

### 3. 日志监控
定期检查错误日志，及时发现权限问题

## 技术支持

如果问题仍然存在，请提供以下信息：
1. 操作系统版本
2. Node.js版本
3. 目录权限信息 (`ls -la /www/wwwroot`)
4. 错误日志详情
5. 宝塔面板版本
