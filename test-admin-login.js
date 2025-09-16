// 管理员登录测试脚本
const axios = require('axios');

// 测试管理员登录
const testAdminLogin = async () => {
  try {
    console.log('🧪 测试管理员登录...');
    
    const response = await axios.post('http://localhost:3002/api/user/admin-login', {
      phoneNumber: '13800138000',
      password: '' // 管理员默认无密码
    });
    
    if (response.data.code === 200) {
      console.log('✅ 管理员登录成功!');
      console.log('📋 登录信息:', {
        token: response.data.data.token ? '已获取' : '未获取',
        user: response.data.data.user
      });
      
      // 保存token到文件（用于测试）
      const fs = require('fs');
      fs.writeFileSync('admin-token.txt', response.data.data.token || '');
      console.log('💾 Token已保存到 admin-token.txt');
      
    } else {
      console.log('❌ 管理员登录失败:', response.data.message);
    }
    
  } catch (error) {
    console.error('❌ 管理员登录测试失败:', error.message);
    
    if (error.response) {
      console.log('📋 错误详情:', {
        status: error.response.status,
        data: error.response.data
      });
    }
  }
};

// 测试API调用（使用token）
const testAPIWithToken = async () => {
  try {
    console.log('\n🧪 测试API调用...');
    
    const fs = require('fs');
    let token = '';
    
    try {
      token = fs.readFileSync('admin-token.txt', 'utf8').trim();
    } catch (e) {
      console.log('❌ 未找到token文件，请先运行登录测试');
      return;
    }
    
    if (!token) {
      console.log('❌ Token为空，请先运行登录测试');
      return;
    }
    
    // 测试激活码API
    const response = await axios.get('http://localhost:3002/api/activation-code?page=1&limit=10', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ API调用成功!');
    console.log('📋 响应数据:', response.data);
    
  } catch (error) {
    console.error('❌ API调用测试失败:', error.message);
    
    if (error.response) {
      console.log('📋 错误详情:', {
        status: error.response.status,
        data: error.response.data
      });
    }
  }
};

// 主函数
const main = async () => {
  console.log('🚀 管理员认证测试开始...\n');
  
  await testAdminLogin();
  await testAPIWithToken();
  
  console.log('\n✅ 测试完成!');
  console.log('💡 如果测试成功，说明管理员认证正常');
  console.log('💡 如果测试失败，请检查数据库连接和用户创建');
};

// 运行测试
if (require.main === module) {
  main().catch(console.error);
}

module.exports = { testAdminLogin, testAPIWithToken };
