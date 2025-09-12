# 云函数API迁移到MySQL服务器

## 概述

本项目已成功将云函数中的API迁移到本地MySQL服务器，小程序现在可以直接调用server中的API，而不需要依赖云函数。

## 数据库配置

- **数据库类型**: MySQL
- **数据库名**: practice
- **主机**: localhost
- **端口**: 3306
- **用户名**: root
- **密码**: (空)

## 安装和启动

### 1. 安装依赖

```bash
cd server
npm install
```

### 2. 初始化数据库

```bash
# 同步数据库模型
npm run init-db

# 初始化管理员用户
npm run init-admin
```

### 3. 启动服务器

```bash
# 开发模式
npm run dev

# 生产模式
npm start
```

服务器将在端口3002启动（根据内存中的配置[[memory:6591047]]）。

## API端点

### 云函数兼容API

所有云函数的API现在都可以通过以下端点访问：

**基础URL**: `http://localhost:3002/api/cloud-function`

**请求方式**: POST

**请求格式**:
```json
{
  "action": "user.login",
  "phoneNumber": "13800138000",
  "password": "password"
}
```

### 用户相关API

| Action | 描述 | 参数 |
|--------|------|------|
| `user.sendVerificationCode` | 发送验证码 | `phoneNumber` |
| `user.loginWithVerificationCode` | 验证码登录 | `phoneNumber`, `verificationCode` |
| `user.loginWithPhone` | 手机号登录 | `phoneNumber` |
| `user.login` | 微信登录 | `userInfo`, `code` |
| `user.getInfo` | 获取用户信息 | `token` |
| `user.getStats` | 获取用户统计 | `userId` |
| `user.checkAdminPermission` | 检查管理员权限 | `userId` |

### 题目相关API

| Action | 描述 | 参数 |
|--------|------|------|
| `question.getList` | 获取题目列表 | `subject`, `chapter`, `limit`, `page` |
| `question.getDetail` | 获取题目详情 | `id` |
| `question.getById` | 通过ID获取题目 | `questionId` |
| `question.getRandom` | 随机获取题目 | `subject`, `chapter`, `limit` |
| `question.submitAnswer` | 提交答题记录 | `questionId`, `userAnswer`, `isCorrect`, `userId` |
| `question.getUserRecords` | 获取用户答题记录 | `userId`, `page`, `limit` |
| `question.getErrorQuestions` | 获取错题列表 | `userId`, `page`, `limit` |
| `question.importQuestions` | 批量导入题目 | `questions`, `userId` |
| `question.getStats` | 获取题目统计 | - |
| `question.deleteQuestionBank` | 删除题库 | `subject`, `userId` |
| `question.addToFavorites` | 添加到收藏 | `questionId`, `userId` |
| `question.getFavorites` | 获取收藏列表 | `userId`, `page`, `limit` |
| `question.addToErrorBook` | 添加到错题本 | `questionId`, `userId` |
| `question.removeFromFavorites` | 从收藏中移除 | `questionId`, `userId` |
| `question.removeFromErrorBook` | 从错题本中移除 | `questionId`, `userId` |

## 数据库表结构

### users (用户表)
- `id`: 主键
- `phoneNumber`: 手机号
- `nickName`: 昵称
- `avatarUrl`: 头像URL
- `isAdmin`: 是否为管理员
- `lastLoginTime`: 最后登录时间

### questions (题目表)
- `id`: 主键
- `subject`: 科目
- `chapter`: 章节
- `type`: 题目类型
- `content`: 题目内容
- `options`: 选项(JSON格式)
- `answer`: 正确答案
- `analysis`: 解析
- `difficulty`: 难度

### answer_records (答题记录表)
- `id`: 主键
- `userId`: 用户ID
- `questionId`: 题目ID
- `userAnswer`: 用户答案
- `isCorrect`: 是否正确
- `subject`: 科目
- `chapter`: 章节

### favorites (收藏表)
- `id`: 主键
- `userId`: 用户ID
- `questionId`: 题目ID
- `questionContent`: 题目内容
- `subject`: 科目
- `chapter`: 章节

### error_records (错题记录表)
- `id`: 主键
- `userId`: 用户ID
- `questionId`: 题目ID
- `userAnswer`: 用户答案
- `correctAnswer`: 正确答案
- `subject`: 科目
- `chapter`: 章节

### verification_codes (验证码表)
- `id`: 主键
- `phoneNumber`: 手机号
- `code`: 验证码
- `used`: 是否已使用
- `expireTime`: 过期时间

## 小程序配置更新

在小程序中，需要将云函数调用改为HTTP API调用：

### 原来的云函数调用
```javascript
wx.cloud.callFunction({
  name: 'question-bank-api',
  data: {
    action: 'user.login',
    phoneNumber: '13800138000'
  }
})
```

### 新的HTTP API调用
```javascript
wx.request({
  url: 'http://localhost:3002/api/cloud-function',
  method: 'POST',
  data: {
    action: 'user.login',
    phoneNumber: '13800138000'
  }
})
```

## 默认管理员账户

- **手机号**: 13800138000
- **权限**: 管理员
- **功能**: 可以导入题目、删除题库等管理操作

## 注意事项

1. 确保MySQL服务已启动
2. 确保数据库`practice`已创建
3. 首次运行需要执行初始化脚本
4. 开发环境下验证码会直接返回，生产环境需要配置短信服务
5. 所有API都保持了与云函数相同的接口格式，确保小程序兼容性

## 故障排除

### 数据库连接失败
- 检查MySQL服务是否启动
- 检查数据库配置是否正确
- 检查数据库`practice`是否存在

### API调用失败
- 检查服务器是否启动
- 检查端口3002是否被占用
- 检查请求格式是否正确

### 权限问题
- 确保用户已登录
- 检查管理员权限设置
- 使用默认管理员账户进行测试
