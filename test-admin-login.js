const axios = require('axios');

async function testAdminLogin() {
  try {
    console.log('测试管理员登录...');
    
    // 测试使用邮箱登录
    const response1 = await axios.post('http://223.93.139.87:3002/api/user/admin-login', {
      username: 'admin@example.com',
      password: '123456'
    });
    
    console.log('✅ 邮箱登录成功:', response1.data);
    
  } catch (error) {
    if (error.response) {
      console.log('❌ 邮箱登录失败:', error.response.data);
    } else {
      console.log('❌ 请求失败:', error.message);
    }
  }
  
  try {
    // 测试使用用户名登录
    const response2 = await axios.post('http://223.93.139.87:3002/api/user/admin-login', {
      username: 'admin',
      password: '123456'
    });
    
    console.log('✅ 用户名登录成功:', response2.data);
    
  } catch (error) {
    if (error.response) {
      console.log('❌ 用户名登录失败:', error.response.data);
    } else {
      console.log('❌ 请求失败:', error.message);
    }
  }
  
  try {
    // 测试使用手机号登录
    const response3 = await axios.post('http://223.93.139.87:3002/api/user/admin-login', {
      username: '13800138000',
      password: '123456'
    });
    
    console.log('✅ 手机号登录成功:', response3.data);
    
  } catch (error) {
    if (error.response) {
      console.log('❌ 手机号登录失败:', error.response.data);
    } else {
      console.log('❌ 请求失败:', error.message);
    }
  }
}

testAdminLogin();