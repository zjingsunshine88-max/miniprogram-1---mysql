# 环境配置说明

## 📋 环境配置概览

本项目支持开发环境和生产环境的不同配置，包括不同的MySQL密码。

### 🔧 开发环境配置

| 配置项 | 值 | 说明 |
|--------|----|----|
| NODE_ENV | development | 环境标识 |
| DB_HOST | localhost | 数据库主机 |
| DB_PORT | 3306 | 数据库端口 |
| DB_USERNAME | root | 数据库用户名 |
| **DB_PASSWORD** | **1234** | **开发环境密码** |
| DB_NAME | practice | 数据库名称 |
| HOST | localhost | 服务器主机 |
| PORT | 3002 | 服务器端口 |

### 🚀 生产环境配置

| 配置项 | 值 | 说明 |
|--------|----|----|
| NODE_ENV | production | 环境标识 |
| DB_HOST | 223.93.139.87 | 数据库主机 |
| DB_PORT | 3306 | 数据库端口 |
| DB_USERNAME | root | 数据库用户名 |
| **DB_PASSWORD** | **LOVEjing96..** | **生产环境密码** |
| DB_NAME | practice | 数据库名称 |
| HOST | 223.93.139.87 | 服务器主机 |
| PORT | 3002 | 服务器端口 |

## 🚀 启动方式

### 开发环境启动

#### 方式一：使用开发环境启动脚本
```batch
# 自动设置开发环境变量并启动
start-server-dev.bat
```

#### 方式二：使用服务器启动器
```batch
# 选择开发环境启动选项
server-launcher.bat
# 选择选项 1: 开发环境启动服务器
```

#### 方式三：手动启动
```batch
# 设置开发环境变量
set-dev-env.bat

# 启动服务器
cd server
npm run dev
```

### 生产环境启动

#### 方式一：使用生产环境启动脚本
```batch
# 设置生产环境变量
set-prod-env.bat

# 使用PM2启动
start-services.bat
```

#### 方式二：使用服务器启动器
```batch
# 选择生产环境启动选项
server-launcher.bat
# 选择选项 3: 生产环境启动服务器
```

## 🧪 数据库连接测试

### 测试开发环境数据库
```batch
# 使用测试工具
test-db-connection.bat
# 选择选项 1: 测试开发环境数据库连接

# 或手动测试
mysql -u root -p1234 -e "SELECT 1;"
```

### 测试生产环境数据库
```batch
# 使用测试工具
test-db-connection.bat
# 选择选项 2: 测试生产环境数据库连接

# 或手动测试
mysql -h 223.93.139.87 -u root -pLOVEjing96.. -e "SELECT 1;"
```

## 📁 配置文件说明

### 数据库配置文件

1. **server/config/database.js** - 主数据库配置文件
   - 根据NODE_ENV自动选择环境配置
   - 开发环境使用 development.js
   - 生产环境使用 production.js

2. **server/config/development.js** - 开发环境配置
   - 密码: 1234
   - 主机: localhost
   - 启用SQL日志

3. **server/config/production.js** - 生产环境配置
   - 密码: LOVEjing96..
   - 主机: 223.93.139.87
   - 关闭SQL日志

### 环境变量设置脚本

1. **set-dev-env.bat** - 设置开发环境变量
2. **set-prod-env.bat** - 设置生产环境变量

## 🔍 故障排除

### 开发环境数据库连接失败

1. **检查MySQL服务**
   ```batch
   net start mysql
   ```

2. **验证密码**
   ```batch
   mysql -u root -p1234 -e "SELECT 1;"
   ```

3. **创建数据库**
   ```batch
   mysql -u root -p1234 -e "CREATE DATABASE IF NOT EXISTS practice;"
   ```

### 生产环境数据库连接失败

1. **检查网络连接**
   ```batch
   ping 223.93.139.87
   ```

2. **验证密码**
   ```batch
   mysql -h 223.93.139.87 -u root -pLOVEjing96.. -e "SELECT 1;"
   ```

3. **检查防火墙**
   - 确保3306端口开放

## 💡 最佳实践

1. **开发环境**
   - 使用简单密码便于开发
   - 启用详细日志便于调试
   - 使用localhost避免网络问题

2. **生产环境**
   - 使用复杂密码保证安全
   - 关闭详细日志提高性能
   - 使用固定IP确保稳定

3. **环境隔离**
   - 不同环境使用不同的配置文件
   - 通过环境变量控制配置
   - 避免硬编码配置信息

## 📞 技术支持

如果遇到配置问题：

1. 运行 `test-db-connection.bat` 测试数据库连接
2. 检查环境变量是否正确设置
3. 确认MySQL服务正常运行
4. 验证密码是否正确
5. 检查网络连接（生产环境）
