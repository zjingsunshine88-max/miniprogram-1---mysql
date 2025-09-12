const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function testActivationCodeVerification() {
  console.log('=== 测试激活码验证功能 ===\n');

  try {
    // 1. 先登录获取token
    console.log('1. 用户登录...');
    const loginResponse = await fetch('http://localhost:3002/api/user/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        phone: '13800138000',
        password: '123456'
      })
    });

    const loginResult = await loginResponse.json();
    console.log('登录结果:', loginResult);

    if (loginResult.code !== 200) {
      console.log('登录失败，无法继续测试');
      return;
    }

    const token = loginResult.data.token;
    console.log('获取到token:', token.substring(0, 20) + '...\n');

    // 2. 获取激活码列表
    console.log('2. 获取激活码列表...');
    const listResponse = await fetch('http://localhost:3002/api/activation-code', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    const listResult = await listResponse.json();
    console.log('激活码列表:', listResult);

    if (listResult.code === 200 && listResult.data && listResult.data.length > 0) {
      const activationCode = listResult.data[0];
      console.log('找到激活码:', activationCode.code);
      
      // 3. 测试验证激活码
      console.log('\n3. 验证激活码...');
      const verifyResponse = await fetch('http://localhost:3002/api/activation-code/verify', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          code: activationCode.code
        })
      });

      const verifyResult = await verifyResponse.json();
      console.log('验证结果:', verifyResult);

      // 4. 获取用户已激活的科目
      console.log('\n4. 获取用户已激活的科目...');
      const subjectsResponse = await fetch('http://localhost:3002/api/activation-code/user/subjects', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      const subjectsResult = await subjectsResponse.json();
      console.log('已激活科目:', subjectsResult);

    } else {
      console.log('没有找到激活码，请先在管理后台创建激活码');
    }

  } catch (error) {
    console.error('测试过程中出现错误:', error);
  }

  console.log('\n=== 测试完成 ===');
}

// 运行测试
testActivationCodeVerification();
