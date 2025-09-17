const mysql = require('mysql2/promise');

// 数据库连接配置
const dbConfig = {
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: 'LOVEjing96..',
  database: 'practice'
};

async function checkDatabaseStructure() {
  let connection;
  
  try {
    console.log('正在连接数据库...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ 数据库连接成功');
    
    // 检查数据库中的表
    const [tables] = await connection.execute("SHOW TABLES");
    console.log('\n📋 数据库中的表:');
    tables.forEach(table => {
      console.log(`  - ${Object.values(table)[0]}`);
    });
    
    // 检查users表结构
    if (tables.some(table => Object.values(table)[0] === 'users')) {
      console.log('\n📋 users表结构:');
      const [columns] = await connection.execute("DESCRIBE users");
      columns.forEach(column => {
        console.log(`  - ${column.Field}: ${column.Type} ${column.Null === 'NO' ? 'NOT NULL' : 'NULL'} ${column.Key ? `(${column.Key})` : ''}`);
      });
      
      // 查看users表中的数据
      const [users] = await connection.execute("SELECT * FROM users LIMIT 5");
      console.log('\n📋 users表数据 (前5条):');
      if (users.length > 0) {
        console.log(JSON.stringify(users, null, 2));
      } else {
        console.log('  - 表中没有数据');
      }
    }
    
  } catch (error) {
    console.error('❌ 操作失败:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// 运行脚本
checkDatabaseStructure();
