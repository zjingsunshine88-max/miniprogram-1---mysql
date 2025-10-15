#!/usr/bin/env node

const axios = require('axios')

console.log('🧪 测试管理员登录API...')

// API配置
const API_BASE_URL = 'https://practice.insightdata.top/api'

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

async function testLogin(username, password, userType) {
    try {
        console.log(`\n🔍 测试 ${userType}...`)
        console.log(`用户名: ${username}`)
        console.log(`密码: ${password}`)
        
        const response = await axios.post(`${API_BASE_URL}/user/admin-login`, {
            username: username,
            password: password
        }, {
            timeout: 10000,
            headers: {
                'Content-Type': 'application/json',
                'Origin': 'https://admin.practice.insightdata.top:8443'
            }
        })
        
        console.log('✅ 登录成功!')
        console.log('响应数据:', JSON.stringify(response.data, null, 2))
        
        if (response.data.code === 200) {
            console.log('🎉 登录成功，获取到token')
            return response.data.data.token
        } else {
            console.log('❌ 登录失败:', response.data.message)
            return null
        }
        
    } catch (error) {
        console.log('❌ 登录请求失败')
        console.log('错误信息:', error.message)
        
        if (error.response) {
            console.log('状态码:', error.response.status)
            console.log('响应数据:', JSON.stringify(error.response.data, null, 2))
            console.log('响应头:', JSON.stringify(error.response.headers, null, 2))
        }
        
        return null
    }
}

async function testAllLogins() {
    console.log('🚀 开始测试所有登录方式...\n')
    
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
        console.log('3. 检查数据库中的用户数据')
        console.log('4. 检查密码是否正确')
        console.log('5. 检查用户是否为管理员 (is_admin = 1)')
    }
}

// 运行测试
testAllLogins()
