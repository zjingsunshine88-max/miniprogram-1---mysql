const fetch = require('node-fetch');

async function testAPI() {
  try {
    console.log('测试题库API...');
    
    // 先登录获取token
    const loginResponse = await fetch('http://localhost:3002/api/user/admin-login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'admin@example.com',
        password: 'admin123'
      })
    });
    
    const loginResult = await loginResponse.json();
    console.log('登录结果:', loginResult);
    
    if (loginResult.code === 200) {
      const token = loginResult.data.token;
      console.log('获取到token:', token.substring(0, 20) + '...');
      
      // 测试题库API
      const bankResponse = await fetch('http://localhost:3002/api/question-bank', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      const bankResult = await bankResponse.json();
      console.log('题库API响应:', JSON.stringify(bankResult, null, 2));
      
      // 测试科目API
      if (bankResult.data && bankResult.data.list && bankResult.data.list.length > 0) {
        const bankId = bankResult.data.list[0].id;
        console.log(`\n测试科目API，题库ID: ${bankId}`);
        
        const subjectResponse = await fetch(`http://localhost:3002/api/subject?questionBankId=${bankId}`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        const subjectResult = await subjectResponse.json();
        console.log('科目API响应:', JSON.stringify(subjectResult, null, 2));
      }
    }
    
  } catch (error) {
    console.error('测试失败:', error);
  }
}

testAPI();
