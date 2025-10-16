# Git忽略配置指南

## 概述

已为项目配置 `.gitignore` 文件，避免将不必要的文件提交到Git仓库。

## 已忽略的文件和目录

### Node.js相关
- `node_modules/` - Node.js依赖包
- `npm-debug.log*` - npm调试日志
- `yarn-debug.log*` - yarn调试日志
- `yarn-error.log*` - yarn错误日志
- `package-lock.json` - npm锁定文件

### 项目特定目录
- `admin/node_modules/` - Admin项目依赖
- `admin/package-lock.json` - Admin项目锁定文件
- `admin/dist/` - Admin构建输出目录
- `server/node_modules/` - Server项目依赖
- `server/package-lock.json` - Server项目锁定文件
- `server/logs/` - Server日志目录
- `server/temp/` - Server临时文件目录
- `server/public/uploads/` - Server上传文件目录

### 环境变量文件
- `.env` - 环境变量文件
- `.env.local` - 本地环境变量
- `.env.development` - 开发环境变量
- `.env.production` - 生产环境变量
- `*.env` - 所有环境变量文件

### 系统文件
- `.DS_Store` - macOS系统文件
- `Thumbs.db` - Windows缩略图缓存
- `desktop.ini` - Windows桌面配置文件

### IDE配置
- `.vscode/` - VS Code配置
- `.idea/` - IntelliJ IDEA配置
- `*.swp`, `*.swo`, `*~` - Vim临时文件

### 临时文件
- `*.tmp`, `*.temp` - 临时文件
- `*.log` - 日志文件

### 构建文件
- `dist/`, `build/`, `out/` - 构建输出目录

### 数据库文件
- `*.db`, `*.sqlite`, `*.sqlite3` - 数据库文件

### 测试覆盖率
- `coverage/` - 测试覆盖率报告
- `.nyc_output/` - NYC测试输出

### PM2日志
- `.pm2/` - PM2进程管理器日志

### 其他
- `.cache/`, `.temp/` - 缓存和临时目录

## 使用方法

### 1. 初始化Git仓库（如果还没有）

```bash
# 运行初始化脚本
init-git.bat

# 或手动初始化
git init
```

### 2. 检查.gitignore是否生效

```bash
# 查看被忽略的文件
git status --ignored

# 查看.gitignore文件内容
cat .gitignore
```

### 3. 提交代码

```bash
# 添加所有文件（.gitignore会自动生效）
git add .

# 查看将要提交的文件
git status

# 提交代码
git commit -m "Initial commit"

# 添加远程仓库
git remote add origin <your-repository-url>

# 推送到远程仓库
git push -u origin main
```

## 验证忽略配置

### 检查node_modules是否被忽略

```bash
# 查看git状态
git status

# 应该看不到admin/node_modules和server/node_modules
```

### 强制检查

```bash
# 检查特定文件是否被忽略
git check-ignore -v admin/node_modules
git check-ignore -v server/node_modules

# 应该返回匹配的.gitignore规则
```

## 常见问题

### Q1: node_modules仍然出现在git status中
**A**: 如果node_modules之前已经被git追踪，需要先从git中移除：
```bash
git rm -r --cached admin/node_modules
git rm -r --cached server/node_modules
git commit -m "Remove node_modules from git"
```

### Q2: 如何忽略其他文件
**A**: 编辑 `.gitignore` 文件，添加新的规则：
```bash
# 忽略特定文件
filename.txt

# 忽略特定目录
directory_name/

# 忽略特定扩展名
*.extension

# 忽略特定模式
pattern*
```

### Q3: 如何取消忽略文件
**A**: 从 `.gitignore` 中删除相应规则，然后：
```bash
git rm --cached filename
git commit -m "Remove file from gitignore"
```

## 最佳实践

1. **不要提交依赖包** - 使用package.json管理依赖
2. **不要提交环境变量** - 使用.env.example作为模板
3. **不要提交构建文件** - 在构建服务器上重新构建
4. **不要提交临时文件** - 定期清理临时目录
5. **不要提交日志文件** - 使用日志管理系统

## 相关命令

```bash
# 查看被忽略的文件
git status --ignored

# 查看.gitignore规则
git check-ignore -v <file>

# 从git中移除已追踪的文件
git rm --cached <file>

# 强制添加被忽略的文件
git add -f <file>
```

## 注意事项

1. `.gitignore` 只对未追踪的文件生效
2. 已经被git追踪的文件需要先移除
3. 修改 `.gitignore` 后需要重新提交
4. 每个项目都应该有自己的 `.gitignore` 文件
