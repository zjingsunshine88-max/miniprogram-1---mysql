#!/usr/bin/env node

const path = require('path')
const fs = require('fs')

console.log('🔍 测试路径解析...\n')

// 模拟__dirname的值
const mockDirname = '/www/wwwroot/server/controllers'
const mockMiddlewareDirname = '/www/wwwroot/server/middlewares'

console.log('📁 当前目录结构:')
console.log('  /www/wwwroot/')
console.log('    └── server/')
console.log('        ├── temp/')
console.log('        ├── public/')
console.log('        │   └── uploads/')
console.log('        │       └── images/')
console.log('        ├── controllers/')
console.log('        │   └── enhancedQuestionController.js')
console.log('        └── middlewares/')
console.log('            └── multer.js')

console.log('\n📊 路径解析测试:')

// 测试1: 从controllers目录解析temp目录
console.log('\n1️⃣ 从controllers目录解析temp目录:')
const tempDirFromController = path.join(mockDirname, '../temp')
console.log(`   __dirname: ${mockDirname}`)
console.log(`   解析路径: ${tempDirFromController}`)
console.log(`   预期路径: /www/wwwroot/server/temp`)
console.log(`   是否正确: ${tempDirFromController === '/www/wwwroot/server/temp' ? '✅' : '❌'}`)

// 测试2: 从middlewares目录解析temp目录
console.log('\n2️⃣ 从middlewares目录解析temp目录:')
const tempDirFromMiddleware = path.join(mockMiddlewareDirname, '../temp')
console.log(`   __dirname: ${mockMiddlewareDirname}`)
console.log(`   解析路径: ${tempDirFromMiddleware}`)
console.log(`   预期路径: /www/wwwroot/server/temp`)
console.log(`   是否正确: ${tempDirFromMiddleware === '/www/wwwroot/server/temp' ? '✅' : '❌'}`)

// 测试3: 从controllers目录解析public目录
console.log('\n3️⃣ 从controllers目录解析public目录:')
const publicDirFromController = path.join(mockDirname, '../public')
console.log(`   __dirname: ${mockDirname}`)
console.log(`   解析路径: ${publicDirFromController}`)
console.log(`   预期路径: /www/wwwroot/server/public`)
console.log(`   是否正确: ${publicDirFromController === '/www/wwwroot/server/public' ? '✅' : '❌'}`)

// 测试4: 从middlewares目录解析public目录
console.log('\n4️⃣ 从middlewares目录解析public目录:')
const publicDirFromMiddleware = path.join(mockMiddlewareDirname, '../public')
console.log(`   __dirname: ${mockMiddlewareDirname}`)
console.log(`   解析路径: ${publicDirFromMiddleware}`)
console.log(`   预期路径: /www/wwwroot/server/public`)
console.log(`   是否正确: ${publicDirFromMiddleware === '/www/wwwroot/server/public' ? '✅' : '❌'}`)

// 测试5: 检查目录是否存在
console.log('\n📂 检查实际目录是否存在:')

const directoriesToCheck = [
  '/www/wwwroot/server/temp',
  '/www/wwwroot/server/public',
  '/www/wwwroot/server/public/uploads',
  '/www/wwwroot/server/public/uploads/images'
]

directoriesToCheck.forEach(dir => {
  const exists = fs.existsSync(dir)
  console.log(`   ${dir}: ${exists ? '✅ 存在' : '❌ 不存在'}`)
  
  if (exists) {
    try {
      const stats = fs.statSync(dir)
      console.log(`      类型: ${stats.isDirectory() ? '目录' : '文件'}`)
      console.log(`      权限: ${stats.mode.toString(8)}`)
    } catch (error) {
      console.log(`      错误: ${error.message}`)
    }
  }
})

console.log('\n📝 总结:')
console.log('如果所有路径解析都是 ✅，说明路径配置正确')
console.log('如果实际目录都存在 ✅，说明目录结构正确')
console.log('重启API服务后，题目上传功能应该能正常工作')
