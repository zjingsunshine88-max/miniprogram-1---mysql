const mysql = require('mysql2');

// 测试不同的数据库密码
const passwords = ['', '1234', '123456', 'root', 'password', 'admin'];

async function testConnection(password) {
  return new Promise((resolve) => {
    const connection = mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: password,
      database: 'practice'
    });
    
    connection.connect((err) => {
      if (err) {
        console.log(`密码 "${password}" 连接失败:`, err.message);
        resolve(false);
      } else {
        console.log(`✅ 密码 "${password}" 连接成功！`);
        connection.end();
        resolve(true);
      }
    });
  });
}

async function main() {
  console.log('测试数据库连接...\n');
  
  for (const password of passwords) {
    const success = await testConnection(password);
    if (success) {
      console.log(`\n找到正确的密码: "${password}"`);
      break;
    }
  }
}

main().catch(console.error);
