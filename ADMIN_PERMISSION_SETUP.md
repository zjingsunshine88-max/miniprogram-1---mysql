# 管理员权限设置指南

## 问题描述

题目上传功能出现错误：`查询参数对象值不能均为undefined`，同时需要确保只有管理员用户才能访问上传页面。

## 问题分析

### 1. 错误原因
- 云函数中的管理员权限检查使用了 `userId` 参数
- 但是用户信息中可能使用的是 `_id` 或 `id`
- 导致查询参数为空，引发数据库查询错误

### 2. 权限检查问题
- 前端管理员权限检查被硬编码为 `true`
- 没有真正验证用户是否为管理员
- 云函数中的权限检查逻辑错误（从 `admins` 集合查询，实际应该从 `users` 集合查询 `isAdmin` 字段）

## 解决方案

### 1. 修复用户ID传递

#### 修复云函数API调用工具
```javascript
// miniprogram/utils/cloud-api.js
const callCloudFunction = async (action, params = {}) => {
  try {
    // 获取用户ID
    const userInfo = wx.getStorageSync('userInfo')
    const userId = userInfo ? (userInfo._id || userInfo.id) : null
    
    // 如果用户已登录，添加用户ID到参数中
    if (userId) {
      params.userId = userId
    }
    
    console.log('调用云函数:', action, '参数:', params)
    
    const result = await wx.cloud.callFunction({
      name: 'question-bank-api',
      data: Object.assign({ action }, params)
    })
    
    return result.result
  } catch (error) {
    console.error('云函数调用失败:', error)
    throw error
  }
}
```

### 2. 修复管理员权限检查

#### 修复管理员权限验证工具
```javascript
// miniprogram/utils/admin-auth.js
const isAdmin = async () => {
  try {
    const userInfo = wx.getStorageSync('userInfo')
    console.log('检查管理员权限，用户信息:', userInfo)
    
    if (!userInfo) {
      console.log('用户信息不存在')
      return false
    }
    
    const userId = userInfo._id || userInfo.id
    if (!userId) {
      console.log('用户ID不存在')
      return false
    }
    
    console.log('检查用户ID:', userId)
    
    // 通过云函数验证管理员权限
    try {
      const result = await userAPI.checkAdminPermission()
      console.log('云函数管理员权限检查结果:', result)
      return result.code === 200 && result.data && result.data.isAdmin
    } catch (error) {
      console.error('云函数管理员权限检查失败:', error)
      return false
    }
  } catch (error) {
    console.error('检查管理员权限失败:', error)
    return false
  }
}
```

### 3. 修复云函数权限检查

#### 修复管理员权限检查API
```javascript
// cloudfunctions/question-bank-api/index.js
const userAPI = {
  // 检查管理员权限
  async checkAdminPermission(event) {
    const { userId } = event
    
    try {
      console.log('检查管理员权限，用户ID:', userId)
      
      if (!userId) {
        return {
          code: 400,
          message: '用户ID不能为空',
          data: { isAdmin: false }
        }
      }
      
      // 从users集合中查询用户的管理员权限
      const userResult = await db.collection('users').where({
        _id: userId
      }).get()
      
      console.log('用户查询结果:', userResult)
      
      if (userResult.data.length === 0) {
        console.log('用户不存在，用户ID:', userId)
        return {
          code: 404,
          message: '用户不存在',
          data: { isAdmin: false }
        }
      }
      
      const user = userResult.data[0]
      const isAdmin = user.isAdmin === true
      
      console.log('用户信息:', {
        userId: user._id,
        nickName: user.nickName,
        phoneNumber: user.phoneNumber,
        isAdmin: user.isAdmin
      })
      
      return {
        code: 200,
        message: isAdmin ? '用户是管理员' : '用户不是管理员',
        data: { 
          isAdmin: isAdmin,
          userId: userId,
          userInfo: {
            nickName: user.nickName,
            phoneNumber: user.phoneNumber
          }
        }
      }
    } catch (error) {
      console.error('检查管理员权限失败:', error)
      return {
        code: 500,
        message: '检查管理员权限失败',
        error: error.message,
        data: { isAdmin: false }
      }
    }
  }
}
```

#### 修复题目导入API
```javascript
// cloudfunctions/question-bank-api/index.js
const questionAPI = {
  // 批量导入题目
  async importQuestions(event) {
    const { questions, userId } = event
    
    try {
      console.log('批量导入题目，用户ID:', userId, '题目数量:', questions.length)
      
      // 检查必要参数
      if (!userId) {
        console.error('用户ID为空')
        return {
          code: 400,
          message: '用户ID不能为空'
        }
      }
      
      if (!questions || !Array.isArray(questions) || questions.length === 0) {
        console.error('题目数据无效')
        return {
          code: 400,
          message: '题目数据无效'
        }
      }
      
      // 验证管理员权限
      console.log('检查管理员权限，用户ID:', userId)
      const userResult = await db.collection('users').where({
        _id: userId
      }).get()
      
      console.log('用户查询结果:', userResult)
      
      if (userResult.data.length === 0) {
        console.log('用户不存在，用户ID:', userId)
        return {
          code: 404,
          message: '用户不存在'
        }
      }
      
      const user = userResult.data[0]
      const isAdmin = user.isAdmin === true
      
      if (!isAdmin) {
        console.log('用户不是管理员，用户ID:', userId)
        return {
          code: 403,
          message: '权限不足，仅限管理员操作'
        }
      }
      
      console.log('管理员权限验证通过，用户:', {
        userId: user._id,
        nickName: user.nickName,
        phoneNumber: user.phoneNumber,
        isAdmin: user.isAdmin
      })
      
      // 批量添加题目
      const addPromises = questions.map(question => {
        // 构建选项数组
        const options = []
        if (question.optionA) options.push({ key: 'A', content: question.optionA })
        if (question.optionB) options.push({ key: 'B', content: question.optionB })
        if (question.optionC) options.push({ key: 'C', content: question.optionC })
        if (question.optionD) options.push({ key: 'D', content: question.optionD })
        
        return db.collection('questions').add({
          data: {
            type: question.type || '单选题',
            content: question.content,
            options: options,
            answer: question.answer,
            analysis: question.analysis || '',
            difficulty: question.difficulty || '中等',
            subject: question.subject || '通用',
            chapter: question.chapter || '通用',
            createTime: new Date(),
            createBy: userId
          }
        })
      })
      
      const results = await Promise.all(addPromises)
      
      return {
        code: 200,
        message: `成功导入 ${results.length} 道题目`,
        data: {
          importedCount: results.length,
          totalCount: questions.length
        }
      }
    } catch (error) {
      console.error('批量导入题目失败:', error)
      return {
        code: 500,
        message: '导入题目失败',
        error: error.message
      }
    }
  }
}
```

### 4. 设置管理员用户

#### 在数据库中设置管理员权限
```javascript
// 在微信云开发控制台中，找到users集合中对应用户的记录
// 将isAdmin字段设置为true

// 示例用户记录结构：
{
  "_id": "用户的真实ID",
  "nickName": "用户昵称",
  "phoneNumber": "手机号",
  "isAdmin": true,  // 设置为true表示管理员
  "createTime": "2024-01-01T00:00:00.000Z",
  "lastLoginTime": "2024-01-01T00:00:00.000Z"
}
```

#### 或者使用云函数更新用户权限
```javascript
// 调用云函数更新用户权限
wx.cloud.callFunction({
  name: 'question-bank-api',
  data: {
    action: 'user.updateAdminPermission',
    userId: '用户的真实ID',
    isAdmin: true
  }
})
```

## 测试步骤

### 1. 检查用户登录状态
```javascript
// 在控制台中执行
const userInfo = wx.getStorageSync('userInfo')
console.log('用户信息:', userInfo)
console.log('用户ID:', userInfo ? (userInfo._id || userInfo.id) : '未登录')
```

### 2. 测试管理员权限检查
```javascript
// 在控制台中执行
const testScript = require('./test-question-upload.js')
testScript.testQuestionUpload()
```

### 3. 手动测试题目上传
```javascript
// 创建测试题目
const testQuestions = [
  {
    type: '单选题',
    content: '测试题目',
    optionA: 'A',
    optionB: 'B',
    optionC: 'C',
    optionD: 'D',
    answer: 'A',
    subject: '测试',
    chapter: '测试章节',
    isValid: true
  }
]

// 调用上传API
wx.cloud.callFunction({
  name: 'question-bank-api',
  data: {
    action: 'question.importQuestions',
    questions: testQuestions
  }
}).then(result => {
  console.log('上传结果:', result)
})
```

## 常见问题

### 1. 用户ID为空
**原因**: 用户未登录或用户信息格式不正确
**解决**: 确保用户已登录，检查用户信息格式

### 2. 管理员权限检查失败
**原因**: 用户在users集合中isAdmin字段不为true
**解决**: 在数据库中为对应用户设置isAdmin为true

### 3. 题目数据格式错误
**原因**: 题目数据缺少必要字段
**解决**: 确保题目数据包含type、content、answer等必要字段

### 4. 数据库查询错误
**原因**: 查询参数为空或格式不正确
**解决**: 检查查询参数，确保不为空且格式正确

## 权限管理建议

### 1. 管理员用户管理
- 定期检查管理员列表
- 及时移除离职管理员
- 记录管理员操作日志

### 2. 权限分级
- 超级管理员：可以管理其他管理员
- 普通管理员：可以上传和管理题目
- 普通用户：只能查看和答题

### 3. 安全措施
- 定期更换管理员密码
- 记录所有管理操作
- 限制管理员数量

## 总结

通过以上修复，可以解决：
1. ✅ **用户ID传递问题**: 确保正确获取和传递用户ID
2. ✅ **管理员权限检查**: 实现真正的权限验证（从users集合查询isAdmin字段）
3. ✅ **题目上传功能**: 修复参数错误，确保正常上传
4. ✅ **错误处理**: 添加详细的错误信息和调试日志

修复后，只有真正的管理员用户（users集合中isAdmin为true的用户）才能访问题目上传功能，并且上传过程会更加稳定可靠。
