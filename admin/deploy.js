#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')

// 部署配置
const config = require('./deploy-config.js')

console.log('🚀 开始部署Admin系统到微信云静态托管...')

// 步骤1: 检查依赖
console.log('\n📦 检查依赖...')
try {
  execSync('npm install', { stdio: 'inherit' })
  console.log('✅ 依赖安装完成')
} catch (error) {
  console.error('❌ 依赖安装失败:', error.message)
  process.exit(1)
}

// 步骤2: 更新API配置
console.log('\n🔧 更新API配置...')
try {
  const apiConfigPath = path.join(__dirname, 'src/api/admin.js')
  let apiConfig = fs.readFileSync(apiConfigPath, 'utf8')
  
  // 替换云函数URL
  apiConfig = apiConfig.replace(
    /functionUrl: 'https:\/\/[^']+'/,
    `functionUrl: '${config.cloudFunction.adminApiUrl}'`
  )
  
  fs.writeFileSync(apiConfigPath, apiConfig)
  console.log('✅ API配置更新完成')
} catch (error) {
  console.error('❌ API配置更新失败:', error.message)
  process.exit(1)
}

// 步骤3: 构建项目
console.log('\n🔨 构建项目...')
try {
  execSync('npm run build', { stdio: 'inherit' })
  console.log('✅ 项目构建完成')
} catch (error) {
  console.error('❌ 项目构建失败:', error.message)
  process.exit(1)
}

// 步骤4: 检查构建结果
console.log('\n📁 检查构建结果...')
const distPath = path.join(__dirname, config.build.outDir)
if (!fs.existsSync(distPath)) {
  console.error('❌ 构建目录不存在:', distPath)
  process.exit(1)
}

const files = fs.readdirSync(distPath)
console.log('✅ 构建文件列表:')
files.forEach(file => {
  const stats = fs.statSync(path.join(distPath, file))
  console.log(`  - ${file} (${stats.isDirectory() ? '目录' : '文件'})`)
})

// 步骤5: 生成部署说明
console.log('\n📋 生成部署说明...')
const deployGuide = `
# Admin系统部署说明

## 部署信息
- 环境ID: ${config.envId}
- 静态托管域名: ${config.hosting.domain}
- 云函数URL: ${config.cloudFunction.adminApiUrl}

## 部署步骤

### 1. 上传静态文件
1. 打开微信云开发控制台
2. 进入"静态网站托管"
3. 上传 \`${config.build.outDir}\` 目录下的所有文件

### 2. 配置云函数
1. 确保 \`admin-api\` 云函数已部署
2. 配置HTTP触发器
3. 获取云函数URL并更新配置

### 3. 初始化数据库
1. 创建 \`admins\` 集合
2. 添加管理员账号
3. 设置数据库权限

### 4. 测试访问
访问地址: ${config.hosting.domain}

## 管理员账号
- 用户名: admin
- 密码: 123456

## 注意事项
1. 确保云函数已正确部署
2. 检查数据库权限设置
3. 验证API调用是否正常
4. 测试所有功能模块

## 故障排除
1. 如果页面无法访问，检查静态托管配置
2. 如果API调用失败，检查云函数部署和触发器配置
3. 如果登录失败，检查数据库中的管理员账号
`

fs.writeFileSync(path.join(__dirname, 'DEPLOY_GUIDE.md'), deployGuide)
console.log('✅ 部署说明已生成: DEPLOY_GUIDE.md')

// 步骤6: 显示部署信息
console.log('\n🎉 部署准备完成!')
console.log('\n📊 部署信息:')
console.log(`  - 环境ID: ${config.envId}`)
console.log(`  - 静态托管域名: ${config.hosting.domain}`)
console.log(`  - 云函数URL: ${config.cloudFunction.adminApiUrl}`)
console.log(`  - 构建目录: ${config.build.outDir}`)

console.log('\n📝 下一步操作:')
console.log('1. 在微信云开发控制台上传静态文件')
console.log('2. 配置云函数HTTP触发器')
console.log('3. 初始化数据库和管理员账号')
console.log('4. 测试访问和功能')

console.log('\n📖 详细说明请查看: DEPLOY_GUIDE.md')
