# 管理员权限故障排除指南

## 🚨 常见错误及解决方案

### 错误1：动态导入模块失败
```
GET http://127.0.0.1:37579/utils/admin-auth.js 403 (Forbidden)
TypeError: Failed to fetch dynamically imported module
```

#### 原因分析
- 微信小程序不支持动态导入（`import()`）
- 路径解析问题
- 模块加载失败

#### 解决方案
1. **使用静态导入**：
   ```javascript
   // ❌ 错误方式
   const { isAdmin } = await import('../../utils/admin-auth.js')
   
   // ✅ 正确方式
   import { isAdmin } from '../../utils/admin-auth.js'
   ```

2. **检查文件路径**：
   - 确保 `admin-auth.js` 文件存在
   - 使用正确的相对路径
   - 检查文件名大小写

3. **更新页面代码**：
   ```javascript
   // pages/profile/index.js
   import { isAdmin, showAdminRequired } from '../../utils/admin-auth.js'
   
   // 在方法中直接使用
   async onQuestionUpload() {
     const adminStatus = await isAdmin()
     // ...
   }
   ```

### 错误2：管理员权限检查失败
```
检查管理员权限失败: TypeError: Failed to fetch
```

#### 原因分析
- 云函数调用失败
- 网络连接问题
- 用户信息格式错误

#### 解决方案
1. **检查用户登录状态**：
   ```javascript
   const userInfo = wx.getStorageSync('userInfo')
   if (!userInfo || !userInfo.id) {
     // 用户未登录
     return false
   }
   ```

2. **添加错误处理**：
   ```javascript
   try {
     const adminStatus = await isAdmin()
     return adminStatus
   } catch (error) {
     console.error('权限检查失败:', error)
     return false
   }
   ```

3. **检查云函数部署**：
   - 确保云函数已正确部署
   - 检查云函数日志
   - 验证云函数权限

### 错误3：权限验证逻辑错误
```
权限不足，此功能仅限管理员使用
```

#### 原因分析
- 用户ID不在管理员列表中
- 管理员列表配置错误
- 云函数权限检查逻辑问题

#### 解决方案
1. **检查管理员列表**：
   ```javascript
   // utils/admin-auth.js
   const ADMIN_USER_IDS = [
     'admin_user_001', // 确保这些ID正确
     'admin_user_002'
   ]
   ```

2. **验证用户ID**：
   ```javascript
   // 检查用户信息格式
   const userInfo = wx.getStorageSync('userInfo')
   console.log('用户信息:', userInfo)
   console.log('用户ID:', userInfo?.id)
   ```

3. **测试权限检查**：
   ```javascript
   // 测试本地权限检查
   const isLocalAdmin = ADMIN_USER_IDS.includes(userInfo.id)
   console.log('本地权限检查:', isLocalAdmin)
   
   // 测试云函数权限检查
   const cloudResult = await userAPI.checkAdminPermission()
   console.log('云函数权限检查:', cloudResult)
   ```

## 🔧 调试步骤

### 步骤1：检查文件结构
```
miniprogram/
├── utils/
│   ├── admin-auth.js ✅
│   └── cloud-api.js ✅
├── pages/
│   ├── profile/
│   │   └── index.js ✅
│   └── question-upload/
│       └── index.js ✅
```

### 步骤2：验证导入语句
```javascript
// ✅ 正确的静态导入
import { isAdmin, showAdminRequired } from '../../utils/admin-auth.js'
import { userAPI } from '../../utils/cloud-api.js'

// ❌ 错误的动态导入
const { isAdmin } = await import('../../utils/admin-auth.js')
```

### 步骤3：检查用户登录
```javascript
// 在页面加载时检查用户状态
onLoad() {
  const userInfo = wx.getStorageSync('userInfo')
  console.log('当前用户信息:', userInfo)
  
  if (userInfo) {
    this.setData({
      userInfo: userInfo,
      isLoggedIn: true
    })
  }
}
```

### 步骤4：测试权限检查
```javascript
// 在控制台测试权限检查
async testAdminPermission() {
  try {
    const userInfo = wx.getStorageSync('userInfo')
    console.log('用户信息:', userInfo)
    
    if (!userInfo || !userInfo.id) {
      console.log('用户未登录')
      return false
    }
    
    const ADMIN_USER_IDS = ['admin_user_001', 'admin_user_002']
    const isLocalAdmin = ADMIN_USER_IDS.includes(userInfo.id)
    console.log('本地权限检查:', isLocalAdmin)
    
    const cloudResult = await userAPI.checkAdminPermission()
    console.log('云函数权限检查:', cloudResult)
    
    return isLocalAdmin || (cloudResult.code === 200 && cloudResult.data.isAdmin)
  } catch (error) {
    console.error('权限检查失败:', error)
    return false
  }
}
```

## 🧪 测试方法

### 1. 本地测试
```javascript
// 在微信开发者工具控制台运行
const testUsers = [
  { id: 'admin_user_001', expected: true },
  { id: 'admin_user_002', expected: true },
  { id: 'normal_user_001', expected: false },
  { id: 'test_user', expected: false }
]

testUsers.forEach(user => {
  const isAdmin = ['admin_user_001', 'admin_user_002'].includes(user.id)
  console.log(`${user.id}: ${isAdmin === user.expected ? '✅' : '❌'}`)
})
```

### 2. 云函数测试
```javascript
// 测试云函数调用
wx.cloud.callFunction({
  name: 'question-bank-api',
  data: {
    action: 'user.checkAdminPermission',
    userId: 'admin_user_001'
  }
}).then(res => {
  console.log('云函数响应:', res)
}).catch(err => {
  console.error('云函数错误:', err)
})
```

### 3. 页面功能测试
1. 使用管理员账号登录
2. 点击"题库上传"功能
3. 检查是否正常进入上传页面
4. 使用普通用户账号测试权限限制

## 📋 检查清单

### 文件检查
- [ ] `admin-auth.js` 文件存在
- [ ] `cloud-api.js` 文件存在
- [ ] 导入路径正确
- [ ] 使用静态导入

### 代码检查
- [ ] 移除了动态导入
- [ ] 添加了错误处理
- [ ] 权限检查逻辑正确
- [ ] 用户信息格式正确

### 云函数检查
- [ ] 云函数已部署
- [ ] `checkAdminPermission` 方法存在
- [ ] 云函数日志正常
- [ ] 权限检查返回正确结果

### 用户数据检查
- [ ] 用户已登录
- [ ] 用户信息包含ID
- [ ] 管理员ID配置正确
- [ ] 本地存储正常

## 🚀 快速修复

如果遇到权限问题，请按以下步骤快速修复：

1. **立即修复**：
   ```javascript
   // 在 profile/index.js 中
   import { isAdmin, showAdminRequired } from '../../utils/admin-auth.js'
   
   async onQuestionUpload() {
     if (!this.data.isLoggedIn) {
       this.showLoginModal()
       return
     }
     
     try {
       const adminStatus = await isAdmin()
       if (adminStatus) {
         wx.navigateTo({ url: '/pages/question-upload/index' })
       } else {
         wx.showModal({
           title: '权限不足',
           content: '此功能仅限管理员使用',
           showCancel: false,
           confirmText: '知道了'
         })
       }
     } catch (error) {
       console.error('检查管理员权限失败:', error)
       wx.showModal({
         title: '权限不足',
         content: '此功能仅限管理员使用',
         showCancel: false,
         confirmText: '知道了'
       })
     }
   }
   ```

2. **重新编译**：
   - 在微信开发者工具中重新编译
   - 清除缓存并重新运行

3. **测试验证**：
   - 使用管理员账号测试
   - 使用普通用户账号测试
   - 检查控制台错误信息

## 📞 获取帮助

如果问题仍然存在，请：

1. **收集错误信息**：
   - 控制台错误日志
   - 云函数执行日志
   - 用户操作步骤

2. **检查环境**：
   - 微信开发者工具版本
   - 小程序基础库版本
   - 云开发环境配置

3. **联系支持**：
   - 提供详细的错误信息
   - 包含复现步骤
   - 附上相关代码片段

---

**注意**：确保在修复后重新部署云函数并重新编译小程序。
