// 激活HTTP触发器的CLI脚本
const { execSync } = require('child_process')

console.log('🔧 激活admin-api云函数的HTTP触发器...')

try {
  // 方法1: 使用tcb fn config命令
  console.log('\n📝 方法1: 使用tcb fn config命令')
  try {
    execSync('tcb fn config set admin-api --trigger http', { stdio: 'inherit' })
    console.log('✅ HTTP触发器配置成功')
  } catch (error) {
    console.log('❌ tcb fn config命令失败，尝试其他方法')
  }
  
  // 方法2: 使用tcb fn deploy命令
  console.log('\n📝 方法2: 使用tcb fn deploy命令')
  try {
    execSync('tcb fn deploy admin-api --trigger http', { stdio: 'inherit' })
    console.log('✅ 云函数部署成功')
  } catch (error) {
    console.log('❌ tcb fn deploy命令失败')
  }
  
  // 方法3: 使用tcb fn list命令检查状态
  console.log('\n📝 方法3: 检查云函数状态')
  try {
    execSync('tcb fn list', { stdio: 'inherit' })
  } catch (error) {
    console.log('❌ 无法列出云函数')
  }
  
} catch (error) {
  console.error('❌ 激活HTTP触发器失败:', error.message)
  console.log('\n💡 建议手动在微信开发者工具中配置HTTP触发器')
}

console.log('\n📋 手动配置步骤:')
console.log('1. 打开微信开发者工具')
console.log('2. 进入云开发控制台')
console.log('3. 找到admin-api云函数')
console.log('4. 点击"触发器"选项卡')
console.log('5. 点击"添加触发器"')
console.log('6. 选择"HTTP触发器"')
console.log('7. 设置访问路径为 /admin-api')
console.log('8. 重新部署云函数')
