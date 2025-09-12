const { sequelize } = require('../config/database')

async function setAdmin() {
  try {
    console.log('设置管理员权限...')
    
    // 将admin@example.com用户设置为管理员
    await sequelize.query('UPDATE users SET is_admin = 1 WHERE email = "admin@example.com"')
    console.log('✅ 管理员权限设置成功')
    
    // 验证设置结果
    const adminUsers = await sequelize.query('SELECT * FROM users WHERE is_admin = 1', { type: sequelize.QueryTypes.SELECT })
    console.log('管理员用户列表:', adminUsers)
    
  } catch (error) {
    console.error('设置管理员权限失败:', error)
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  setAdmin()
    .then(() => {
      console.log('设置完成')
      process.exit(0)
    })
    .catch((error) => {
      console.error('设置失败:', error)
      process.exit(1)
    })
}

module.exports = setAdmin
