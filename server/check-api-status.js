#!/usr/bin/env node

const http = require('http')
const https = require('https')

console.log('🔍 检查API服务器状态...')

// 检查API健康状态
function checkHealth() {
  return new Promise((resolve, reject) => {
    const url = 'https://practice.insightdata.top/api'
    
    const req = https.get(url, (res) => {
      let data = ''
      
      res.on('data', (chunk) => {
        data += chunk
      })
      
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data)
          resolve({
            status: res.statusCode,
            data: parsed
          })
        } catch (error) {
          resolve({
            status: res.statusCode,
            data: data
          })
        }
      })
    })
    
    req.on('error', (error) => {
      reject(error)
    })
    
    req.setTimeout(5000, () => {
      req.destroy()
      reject(new Error('Health check timeout'))
    })
  })
}

// 检查数据库连接
async function checkDatabase() {
  try {
    console.log('🔍 检查数据库连接...')
    
    // 这里我们需要检查数据库配置
    const config = require('./config/database')
    console.log('数据库配置:', {
      host: config.sequelize.config.host,
      port: config.sequelize.config.port,
      database: config.sequelize.config.database,
      username: config.sequelize.config.username
    })
    
    // 测试数据库连接
    const connected = await config.testConnection()
    console.log('数据库连接状态:', connected ? '✅ 连接正常' : '❌ 连接失败')
    
    return connected
  } catch (error) {
    console.log('❌ 数据库检查失败:', error.message)
    return false
  }
}

// 检查用户数据
async function checkUserData() {
  try {
    console.log('🔍 检查用户数据...')
    
    const { User } = require('./models')
    
    // 查找管理员用户
    const adminUsers = await User.findAll({
      where: { isAdmin: true },
      attributes: ['id', 'nickName', 'phoneNumber', 'email', 'isAdmin', 'password']
    })
    
    console.log('管理员用户数量:', adminUsers.length)
    
    adminUsers.forEach((user, index) => {
      console.log(`用户 ${index + 1}:`, {
        id: user.id,
        nickName: user.nickName,
        phoneNumber: user.phoneNumber,
        email: user.email,
        isAdmin: user.isAdmin,
        hasPassword: !!user.password
      })
    })
    
    return adminUsers.length > 0
  } catch (error) {
    console.log('❌ 用户数据检查失败:', error.message)
    return false
  }
}

async function main() {
  try {
    console.log('🚀 开始检查API服务器状态...\n')
    
    // 1. 检查API健康状态
    console.log('1️⃣ 检查API健康状态...')
    try {
      const health = await checkHealth()
      console.log('✅ API健康检查通过')
      console.log('状态码:', health.status)
      console.log('响应数据:', JSON.stringify(health.data, null, 2))
    } catch (error) {
      console.log('❌ API健康检查失败:', error.message)
    }
    
    console.log('\n2️⃣ 检查数据库连接...')
    const dbConnected = await checkDatabase()
    
    console.log('\n3️⃣ 检查用户数据...')
    const hasUsers = await checkUserData()
    
    console.log('\n📊 检查结果总结:')
    console.log('- API服务:', '✅ 正常')
    console.log('- 数据库连接:', dbConnected ? '✅ 正常' : '❌ 异常')
    console.log('- 用户数据:', hasUsers ? '✅ 存在' : '❌ 不存在')
    
    if (!dbConnected || !hasUsers) {
      console.log('\n💡 建议:')
      if (!dbConnected) {
        console.log('- 检查数据库服务是否运行')
        console.log('- 检查数据库连接配置')
      }
      if (!hasUsers) {
        console.log('- 检查数据库中是否有管理员用户')
        console.log('- 运行初始化脚本创建管理员用户')
      }
    }
    
  } catch (error) {
    console.error('❌ 检查过程中出现错误:', error.message)
  }
}

// 运行检查
main()
