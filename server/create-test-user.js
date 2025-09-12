const bcrypt = require('bcrypt');
const { User } = require('./models/associations');
const { sequelize } = require('./config/database');

async function createTestUser() {
  try {
    console.log('创建测试用户...');
    
    // 检查用户是否已存在
    const existingUser = await User.findOne({
      where: { phone_number: '13800138000' }
    });
    
    if (existingUser) {
      // 更新现有用户，添加密码
      const hashedPassword = await bcrypt.hash('123456', 10);
      await existingUser.update({
        password: hashedPassword,
        nick_name: '测试用户'
      });
      console.log('已更新现有用户密码');
    } else {
      // 创建新用户
      const hashedPassword = await bcrypt.hash('123456', 10);
      await User.create({
        phone_number: '13800138000',
        password: hashedPassword,
        nick_name: '测试用户',
        is_admin: 0,
        status: 'active'
      });
      console.log('已创建新测试用户');
    }
    
    console.log('测试用户创建完成');
    console.log('手机号: 13800138000');
    console.log('密码: 123456');
    
  } catch (error) {
    console.error('创建测试用户失败:', error);
  } finally {
    await sequelize.close();
  }
}

createTestUser();
