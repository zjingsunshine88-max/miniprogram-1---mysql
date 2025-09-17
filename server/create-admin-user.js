const mysql = require('mysql2/promise');

// 数据库连接配置
const dbConfig = {
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: 'LOVEjing96..',
  database: 'practice'
};

async function createAdminUser() {
  let connection;
  
  try {
    console.log('正在连接数据库...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ 数据库连接成功');
    
    // 检查用户表是否存在
    const [tables] = await connection.execute("SHOW TABLES LIKE 'users'");
    if (tables.length === 0) {
      console.log('❌ 用户表不存在，请先初始化数据库');
      return;
    }
    
    // 检查是否已存在管理员用户
    const [existingAdmins] = await connection.execute(
      "SELECT * FROM users WHERE isAdmin = 1 OR nickName = 'admin' OR phoneNumber = '13800138000'"
    );
    
    if (existingAdmins.length > 0) {
      console.log('✅ 管理员用户已存在:');
      existingAdmins.forEach(admin => {
        console.log(`  - ID: ${admin.id}, 用户名: ${admin.nickName}, 手机: ${admin.phoneNumber}, 管理员: ${admin.isAdmin}`);
      });
    } else {
      console.log('创建默认管理员用户...');
      
      // 创建管理员用户
      const [result] = await connection.execute(
        `INSERT INTO users (phoneNumber, nickName, isAdmin, status, createdAt, updatedAt) 
         VALUES (?, ?, ?, ?, NOW(), NOW())`,
        ['13800138000', 'admin', 1, 'active']
      );
      
      console.log('✅ 管理员用户创建成功，ID:', result.insertId);
    }
    
    // 显示所有用户
    const [allUsers] = await connection.execute("SELECT id, phoneNumber, nickName, isAdmin, status FROM users");
    console.log('\n📋 当前用户列表:');
    allUsers.forEach(user => {
      console.log(`  - ID: ${user.id}, 用户名: ${user.nickName}, 手机: ${user.phoneNumber}, 管理员: ${user.isAdmin}, 状态: ${user.status}`);
    });
    
  } catch (error) {
    console.error('❌ 操作失败:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// 运行脚本
createAdminUser();
