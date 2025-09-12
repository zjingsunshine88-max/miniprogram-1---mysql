const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function testCreateActivationCode() {
  try {
    console.log('测试创建激活码...');
    
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
      
      // 测试创建激活码
      const createResponse = await fetch('http://localhost:3002/api/activation-code', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          name: '测试激活码',
          description: '这是一个测试激活码',
          subjectIds: [1, 2, 3], // 使用前3个科目
          expiresAt: null
        })
      });
      
      const createResult = await createResponse.json();
      console.log('创建激活码结果:', JSON.stringify(createResult, null, 2));
    }
    
  } catch (error) {
    console.error('测试失败:', error);
  }
}

testCreateActivationCode();
