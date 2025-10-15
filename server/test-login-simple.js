#!/usr/bin/env node

const http = require('http')
const https = require('https')

console.log('🧪 测试管理员登录API（简单版本）...')

// API配置
const API_BASE_URL = 'https://practice.insightdata.top/api'

function makeRequest(url, data) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url)
    const isHttps = urlObj.protocol === 'https:'
    const client = isHttps ? https : http
    
    const postData = JSON.stringify(data)
    
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'Origin': 'https://admin.practice.insightdata.top:8443',
        'User-Agent': 'Node.js Test Script'
      }
    }
    
    const req = client.request(options, (res) => {
      let responseData = ''
      
      res.on('data', (chunk) => {
        responseData += chunk
      })
      
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData)
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: parsedData
          })
        } catch (error) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: responseData
          })
        }
      })
    })
    
    req.on('error', (error) => {
      reject(error)
    })
    
    req.setTimeout(10000, () => {
      req.destroy()
      reject(new Error('Request timeout'))
    })
    
    req.write(postData)
    req.end()
  })
}

async function testLogin(username, password, userType) {
  try {
    console.log(`\n🔍 测试 ${userType}...`)
    console.log(`用户名: ${username}`)
    console.log(`密码: ${password}`)
    
    const response = await makeRequest(`${API_BASE_URL}/user/admin-login`, {
      username: username,
      password: password
    })
    
    console.log('📊 响应状态:', response.status)
    console.log('📊 响应头:', JSON.stringify(response.headers, null, 2))
    console.log('📊 响应数据:', JSON.stringify(response.data, null, 2))
    
    if (response.status === 200 && response.data.code === 200) {
      console.log('✅ 登录成功!')
      return response.data.data.token
    } else {
      console.log('❌ 登录失败')
      return null
    }
    
  } catch (error) {
    console.log('❌ 请求失败:', error.message)
    return null
  }
}

async function testAllLogins() {
  console.log('🚀 开始测试所有登录方式...\n')
  
  // 测试数据 - 根据数据库中的用户信息
  const testUsers = [
    {
      name: '管理员用户（手机号）',
      username: '13800138000',
      password: '123456'
    },
    {
      name: '管理员用户（昵称）',
      username: '管理员',
      password: '123456'
    },
    {
      name: '邮箱用户',
      username: 'admin@example.com',
      password: 'admin123'
    }
  ]
  
  let successCount = 0
  
  for (const user of testUsers) {
    const token = await testLogin(user.username, user.password, user.name)
    if (token) {
      successCount++
    }
    
    // 等待一下再测试下一个
    await new Promise(resolve => setTimeout(resolve, 1000))
  }
  
  console.log(`\n📊 测试结果: ${successCount}/${testUsers.length} 个用户登录成功`)
  
  if (successCount === 0) {
    console.log('\n💡 建议:')
    console.log('1. 检查API服务是否正常运行')
    console.log('2. 检查CORS配置是否正确')
    console.log('3. 检查数据库连接')
    console.log('4. 检查用户数据是否存在')
    console.log('5. 检查密码是否正确')
  }
}

// 运行测试
testAllLogins()
