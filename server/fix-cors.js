#!/usr/bin/env node

const fs = require('fs')
const path = require('path')

console.log('🔧 修复CORS配置...')

// 读取app.js文件
const appJsPath = path.join(__dirname, 'app.js')
let appJsContent = fs.readFileSync(appJsPath, 'utf8')

// 更新CORS配置
const newCorsConfig = `// 配置CORS，允许小程序和后台管理系统访问
app.use(cors({
  origin: [
    'http://223.93.139.87:3001',
    'http://localhost:3001',
    'https://practice.insightdata.top',
    'https://admin.practice.insightdata.top',
    'https://admin.practice.insightdata.top:8443'
  ],
  credentials: true,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],
  optionsSuccessStatus: 200
}));`

// 替换CORS配置
appJsContent = appJsContent.replace(
  /\/\/ 配置CORS，允许小程序和后台管理系统访[\s\S]*?optionsSuccessStatus: 200[\s\S]*?\}\);/,
  newCorsConfig
)

// 写回文件
fs.writeFileSync(appJsPath, appJsContent)
console.log('✅ CORS配置已更新')

// 同时更新生产环境配置
const productionConfigPath = path.join(__dirname, 'config', 'production.js')
if (fs.existsSync(productionConfigPath)) {
  let productionConfig = fs.readFileSync(productionConfigPath, 'utf8')
  
  // 更新生产环境的CORS配置
  productionConfig = productionConfig.replace(
    /origin: process\.env\.CORS_ORIGIN \? process\.env\.CORS_ORIGIN\.split\(','\) : \[.*?\]/,
    "origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : ['https://practice.insightdata.top', 'https://admin.practice.insightdata.top', 'https://admin.practice.insightdata.top:8443']"
  )
  
  fs.writeFileSync(productionConfigPath, productionConfig)
  console.log('✅ 生产环境CORS配置已更新')
}

console.log('\n📝 修复内容:')
console.log('- 添加了 https://practice.insightdata.top')
console.log('- 添加了 https://admin.practice.insightdata.top')
console.log('- 添加了 https://admin.practice.insightdata.top:8443')
console.log('\n🚀 请重启API服务使配置生效')
