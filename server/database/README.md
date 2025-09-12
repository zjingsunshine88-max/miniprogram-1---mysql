# 数据库表结构文件说明

本目录包含了MySQL数据库表结构创建的相关SQL文件。

## 文件说明

### 1. `create_tables.sql` - 完整版表结构
- 包含完整的表结构定义
- 包含详细的注释和索引
- 包含外键约束（已注释，可根据需要启用）
- 包含性能优化索引
- 适合生产环境使用

### 2. `simple_create_tables.sql` - 简化版表结构
- 包含基本的表结构定义
- 包含必要的唯一约束
- 不包含复杂索引和外键约束
- 适合快速部署和测试

### 3. `init_database.sql` - 初始化脚本
- 包含数据库创建和表结构
- 包含示例数据
- 包含默认管理员用户
- 适合首次部署使用

## 使用方法

### 方法一：使用MySQL命令行
```bash
# 登录MySQL
mysql -u root -p

# 执行SQL文件
source /path/to/init_database.sql
```

### 方法二：使用MySQL Workbench或其他图形化工具
1. 打开MySQL Workbench
2. 连接到MySQL服务器
3. 打开SQL文件
4. 执行SQL脚本

### 方法三：使用命令行直接执行
```bash
mysql -u root -p < init_database.sql
```

## 数据库配置

- **数据库名**: practice
- **字符集**: utf8mb4
- **排序规则**: utf8mb4_unicode_ci
- **存储引擎**: InnoDB

## 表结构说明

### 1. users (用户表)
- 存储用户基本信息
- 支持微信登录和手机号登录
- 包含管理员权限字段

### 2. questions (题目表)
- 存储题目信息
- 支持多种题型（单选、多选、判断、填空）
- 包含选项、答案、解析等字段

### 3. answer_records (答题记录表)
- 存储用户答题记录
- 记录答题时间、正确性等信息
- 支持不同答题模式

### 4. favorites (收藏表)
- 存储用户收藏的题目
- 支持收藏备注功能

### 5. error_records (错题记录表)
- 存储用户错题记录
- 用于错题本功能

### 6. verification_codes (验证码表)
- 存储短信验证码
- 支持过期时间管理

## 默认数据

### 管理员用户
- **手机号**: 13800138000
- **昵称**: 系统管理员
- **权限**: 管理员
- **状态**: 激活

### 示例题目
- 包含5道示例题目
- 涵盖计算机基础和网络技术
- 包含不同难度等级

## 注意事项

1. **字符集**: 确保MySQL服务器支持utf8mb4字符集
2. **权限**: 确保数据库用户有创建数据库和表的权限
3. **外键约束**: 默认不启用外键约束，如需启用请取消注释相关语句
4. **索引**: 完整版包含性能优化索引，可根据实际查询需求调整
5. **备份**: 在生产环境部署前，建议先备份现有数据

## 故障排除

### 字符集问题
如果遇到字符集问题，请确保：
```sql
-- 检查数据库字符集
SHOW VARIABLES LIKE 'character_set%';

-- 设置正确的字符集
SET NAMES utf8mb4;
```

### 权限问题
如果遇到权限问题，请确保用户有足够权限：
```sql
-- 授予权限
GRANT ALL PRIVILEGES ON practice.* TO 'username'@'localhost';
FLUSH PRIVILEGES;
```

### 表已存在错误
如果表已存在，可以：
1. 使用 `DROP TABLE IF EXISTS` 语句
2. 或者使用 `CREATE TABLE IF NOT EXISTS` 语句
3. 或者先删除现有表再创建

## 后续操作

数据库创建完成后，可以：

1. **启动服务器**: `npm start` 或 `npm run dev`
2. **测试连接**: 访问 `http://localhost:3002/health`
3. **初始化管理员**: 运行 `npm run init-admin`
4. **导入题目**: 通过管理后台或API导入题目数据
