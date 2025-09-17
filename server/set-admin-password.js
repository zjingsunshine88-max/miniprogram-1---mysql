const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

// 数据库连接配置
const dbConfig = {
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: 'LOVEjing96..',
  database: 'practice'
};

async function setAdminPassword() {
  let connection;
  
  try {
    console.log('正在连接数据库...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ 数据库连接成功');
    
    // 查找管理员用户
    const [admins] = await connection.execute(
      "SELECT * FROM users WHERE is_admin = 1"
    );
    
    if (admins.length === 0) {
      console.log('❌ 没有找到管理员用户');
      return;
    }
    
    console.log('📋 找到管理员用户:');
    admins.forEach(admin => {
      console.log(`  - ID: ${admin.id}, 用户名: ${admin.nick_name}, 手机: ${admin.phone_number}, 邮箱: ${admin.email}`);
    });
    
    // 为每个管理员用户设置密码
    for (const admin of admins) {
      const password = '123456'; // 默认密码
      const hashedPassword = await bcrypt.hash(password, 10);
      
      // 更新密码
      await connection.execute(
        "UPDATE users SET password = ? WHERE id = ?",
        [hashedPassword, admin.id]
      );
      
      console.log(`✅ 已为用户 ${admin.nick_name || admin.email} 设置密码: ${password}`);
    }
    
    // 显示更新后的用户信息
    const [updatedAdmins] = await connection.execute(
      "SELECT id, nick_name, phone_number, email, is_admin FROM users WHERE is_admin = 1"
    );
    
    console.log('\n📋 更新后的管理员用户:');
    updatedAdmins.forEach(admin => {
      console.log(`  - ID: ${admin.id}, 用户名: ${admin.nick_name}, 手机: ${admin.phone_number}, 邮箱: ${admin.email}, 管理员: ${admin.is_admin}`);
    });
    
    console.log('\n🔑 默认登录信息:');
    console.log('  用户名: admin (或使用邮箱/手机号)');
    console.log('  密码: 123456');
    
  } catch (error) {
    console.error('❌ 操作失败:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// 运行脚本
setAdminPassword();
