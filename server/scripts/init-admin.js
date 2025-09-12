const { sequelize } = require('../config/database');
const { User } = require('../models');

// 初始化管理员用户
const initAdmin = async () => {
  try {
    console.log('开始初始化管理员用户...');
    
    // 检查是否已存在管理员
    const existingAdmin = await User.findOne({
      where: { isAdmin: true }
    });
    
    if (existingAdmin) {
      console.log('管理员用户已存在:', {
        id: existingAdmin.id,
        phoneNumber: existingAdmin.phoneNumber,
        nickName: existingAdmin.nickName
      });
      return;
    }
    
    // 创建默认管理员用户
    const admin = await User.create({
      phoneNumber: '13800138000',
      nickName: '系统管理员',
      isAdmin: true,
      lastLoginTime: new Date()
    });
    
    console.log('管理员用户创建成功:', {
      id: admin.id,
      phoneNumber: admin.phoneNumber,
      nickName: admin.nickName,
      isAdmin: admin.isAdmin
    });
    
  } catch (error) {
    console.error('初始化管理员用户失败:', error);
  }
};

// 如果直接运行此脚本
if (require.main === module) {
  const start = async () => {
    try {
      // 测试数据库连接
      await sequelize.authenticate();
      console.log('✅ 数据库连接成功');
      
      // 同步数据库模型
      await sequelize.sync({ alter: true });
      console.log('✅ 数据库模型同步完成');
      
      // 初始化管理员
      await initAdmin();
      
      console.log('✅ 初始化完成');
      process.exit(0);
    } catch (error) {
      console.error('❌ 初始化失败:', error);
      process.exit(1);
    }
  };
  
  start();
}

module.exports = { initAdmin };
