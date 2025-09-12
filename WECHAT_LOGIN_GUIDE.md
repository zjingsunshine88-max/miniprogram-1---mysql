# 微信登录功能实现指南

## 功能概述

实现了完整的微信授权登录功能，包括：
- 微信用户信息授权
- 云函数登录处理
- 用户信息存储和显示
- 登录状态管理

## 实现内容

### 1. 登录页面 (`miniprogram/pages/login/`)

#### 功能特性
- **微信授权登录**：使用 `wx.getUserProfile` 获取用户信息
- **登录状态管理**：显示加载状态，防止重复点击
- **错误处理**：完善的错误提示和异常处理
- **美观界面**：渐变背景，现代化设计

#### 核心代码
```javascript
// 微信登录流程
async onWechatLogin() {
  // 1. 获取微信用户信息
  const userProfile = await this.getUserProfile()
  
  // 2. 获取微信登录凭证
  const loginResult = await this.getWechatLoginCode()
  
  // 3. 调用云函数登录
  const loginResponse = await this.loginToServer(userProfile, loginResult.code)
  
  // 4. 保存用户信息并跳转
  if (loginResponse) {
    wx.setStorageSync('userInfo', response.data.userInfo)
    wx.setStorageSync('token', response.data.token)
    wx.switchTab({ url: '/miniprogram/pages/profile/index' })
  }
}
```

### 2. 个人中心页面 (`miniprogram/pages/profile/`)

#### 功能特性
- **登录状态显示**：根据登录状态显示不同内容
- **用户信息展示**：头像、昵称、统计数据
- **功能菜单**：答题记录、错题本、收藏等
- **登录引导**：未登录时显示登录提示

#### 状态管理
```javascript
// 登录状态检查
loadUserInfo() {
  const userInfo = wx.getStorageSync('userInfo')
  const token = wx.getStorageSync('token')
  
  if (userInfo && token) {
    this.setData({
      userInfo: userInfo,
      isLoggedIn: true
    })
  } else {
    this.setData({
      userInfo: null,
      isLoggedIn: false
    })
  }
}
```

### 3. 云函数API (`cloudfunctions/question-bank-api/`)

#### 新增功能
- **微信登录处理**：`user.login`
- **用户信息获取**：`user.getUserInfo`
- **用户统计获取**：`user.getStats`

#### 登录流程
```javascript
// 云函数登录处理
async login(event) {
  const { userInfo, code } = event
  
  // 1. 生成openid（实际应该调用微信API）
  const openid = `openid_${Date.now()}_${Math.random()}`
  
  // 2. 检查用户是否存在
  const existingUser = await db.collection('users').where({ openid }).get()
  
  // 3. 创建或更新用户信息
  if (existingUser.data.length > 0) {
    // 更新现有用户
    await db.collection('users').doc(user._id).update({ data: userInfo })
  } else {
    // 创建新用户
    await db.collection('users').add({ data: { openid, ...userInfo } })
  }
  
  // 4. 生成token并返回
  const token = `token_${user._id}_${Date.now()}`
  return { code: 200, data: { token, userInfo } }
}
```

## 使用流程

### 1. 用户登录
1. 用户点击"微信一键登录"
2. 弹出微信授权对话框
3. 用户确认授权
4. 获取用户信息和登录凭证
5. 调用云函数进行登录
6. 保存用户信息到本地存储
7. 跳转到个人中心页面

### 2. 登录状态检查
1. 页面加载时检查本地存储
2. 如果有用户信息和token，显示已登录状态
3. 如果没有，显示未登录状态

### 3. 功能访问控制
1. 未登录用户点击功能时提示登录
2. 已登录用户可以正常使用所有功能
3. 退出登录时清除本地存储

## 界面展示

### 登录页面
- 渐变背景设计
- 微信绿色登录按钮
- 功能说明和用户协议
- 加载状态显示

### 个人中心页面
- **未登录状态**：
  - 显示默认头像
  - 昵称显示"未登录"
  - 显示"点击登录"提示
  - 统计数据为0
  - 底部显示登录提示卡片

- **已登录状态**：
  - 显示用户微信头像
  - 显示用户微信昵称
  - 显示用户统计数据
  - 显示退出登录按钮

## 技术要点

### 1. 微信授权
- 使用 `wx.getUserProfile` 获取用户信息
- 使用 `wx.login` 获取登录凭证
- 处理授权失败和取消的情况

### 2. 数据存储
- 使用 `wx.setStorageSync` 保存用户信息
- 使用 `wx.getStorageSync` 读取用户信息
- 使用 `wx.removeStorageSync` 清除用户信息

### 3. 状态管理
- 页面级别的登录状态管理
- 全局的用户信息管理
- 登录状态的实时更新

### 4. 错误处理
- 网络请求失败处理
- 授权失败处理
- 用户取消授权处理
- 云函数调用失败处理

## 注意事项

### 1. 微信API限制
- `wx.getUserProfile` 需要用户主动触发
- 每次调用都会弹出授权对话框
- 用户可能拒绝授权

### 2. 数据安全
- 实际项目中应该使用真实的微信API获取openid
- token应该有过期时间
- 用户信息应该加密存储

### 3. 用户体验
- 登录过程应该有加载提示
- 错误信息应该友好易懂
- 登录成功后应该有成功提示

## 扩展功能

### 1. 可以添加的功能
- 用户头像上传
- 用户昵称修改
- 学习目标设置
- 学习计划制定
- 学习提醒设置

### 2. 可以优化的地方
- 添加登录状态持久化
- 添加自动登录功能
- 添加登录状态检查
- 添加用户信息同步

## 测试建议

### 1. 功能测试
- 测试微信授权登录流程
- 测试登录状态显示
- 测试退出登录功能
- 测试未登录状态下的功能限制

### 2. 异常测试
- 测试网络异常情况
- 测试授权失败情况
- 测试用户取消授权情况
- 测试云函数调用失败情况

### 3. 界面测试
- 测试不同屏幕尺寸下的显示效果
- 测试加载状态的显示
- 测试错误提示的显示
- 测试按钮的交互效果
