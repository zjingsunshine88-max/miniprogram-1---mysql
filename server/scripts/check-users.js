const { sequelize } = require('../config/database')
const { User } = require('../models')

async function checkUsers() {
  try {
    console.log('检查用户数据...')
    
    // 查询所有用户
    const users = await sequelize.query('SELECT * FROM users', { type: sequelize.QueryTypes.SELECT })
    console.log('用户列表:', users)
    
    // 查询管理员用户
    const adminUsers = await sequelize.query('SELECT * FROM users WHERE is_admin = 1', { type: sequelize.QueryTypes.SELECT })
    console.log('管理员用户:', adminUsers)
    
    // 如果没有管理员用户，创建一个
    if (adminUsers.length === 0) {
      console.log('没有找到管理员用户，创建一个...')
      await sequelize.query(`
        INSERT INTO users (phone_number, nick_name, is_admin, created_at, updated_at) 
        VALUES ('13800138000', '管理员', 1, NOW(), NOW())
      `)
      console.log('✅ 管理员用户创建成功')
    }
    
  } catch (error) {
    console.error('检查用户失败:', error)
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  checkUsers()
    .then(() => {
      console.log('检查完成')
      process.exit(0)
    })
    .catch((error) => {
      console.error('检查失败:', error)
      process.exit(1)
    })
}

module.exports = checkUsers
