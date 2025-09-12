const { Sequelize } = require('sequelize');

// MySQL数据库配置
const sequelize = new Sequelize('practice', 'root', '1234', {
  host: 'localhost',
  dialect: 'mysql',
  port: 3306,
  logging: false, // 生产环境关闭SQL日志
  define: {
    timestamps: true, // 自动添加createdAt和updatedAt字段
    underscored: true, // 使用下划线命名
    freezeTableName: true // 冻结表名
  },
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
});

// 测试数据库连接
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ 数据库连接成功');
    return true;
  } catch (error) {
    console.error('❌ 数据库连接失败:', error);
    return false;
  }
};

module.exports = {
  sequelize,
  testConnection
};
