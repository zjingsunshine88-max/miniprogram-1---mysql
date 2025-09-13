const { Sequelize } = require('sequelize');

// 根据环境加载配置
const config = process.env.NODE_ENV === 'production' 
  ? require('./production').database
  : {
      host: 'localhost',
      dialect: 'mysql',
      port: 3306,
      username: 'root',
      password: 'LOVEjing96..',
      database: 'practice',
      logging: false,
      define: {
        timestamps: true,
        underscored: true,
        freezeTableName: true
      },
      pool: {
        max: 5,
        min: 0,
        acquire: 30000,
        idle: 10000
      }
    };

// MySQL数据库配置
const sequelize = new Sequelize(config.database, config.username, config.password, {
  host: config.host,
  dialect: config.dialect,
  port: config.port,
  logging: config.logging,
  define: {
    timestamps: true, // 自动添加createdAt和updatedAt字段
    underscored: true, // 使用下划线命名
    freezeTableName: true // 冻结表名
  },
  pool: config.pool
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
