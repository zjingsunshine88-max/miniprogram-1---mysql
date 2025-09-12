const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');
const { sequelize } = require('./config/database');

async function testPreviewParse() {
  try {
    console.log('=== 测试预览解析API ===\n');

    // 1. 先登录获取token
    console.log('1. 管理员登录...');
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

    if (loginResult.code !== 200) {
      console.log('登录失败，无法继续测试');
      return;
    }

    const token = loginResult.data.token;
    console.log('获取到token:', token.substring(0, 20) + '...\n');

    // 2. 检查是否有测试文件
    const testFilePath = path.join(__dirname, '../docs/H3CSE-Security(GB0-551) 2025-9-1 151956 1.docx');
    
    if (!fs.existsSync(testFilePath)) {
      console.log('测试文件不存在:', testFilePath);
      console.log('请确保文档文件存在于 docs 目录中');
      return;
    }

    console.log('2. 找到测试文件:', testFilePath);
    console.log('文件大小:', fs.statSync(testFilePath).size, 'bytes\n');

    // 3. 测试预览解析
    console.log('3. 测试预览解析...');
    
    const formData = new FormData();
    formData.append('file', fs.createReadStream(testFilePath));

    const previewResponse = await fetch('http://localhost:3002/api/enhanced-question/preview-parse', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        ...formData.getHeaders()
      },
      body: formData
    });

    const previewResult = await previewResponse.json();
    console.log('预览解析结果:', previewResult);

    if (previewResult.code === 200) {
      console.log('\n✅ 预览解析成功！');
      console.log('解析的题目数量:', previewResult.data.total);
      console.log('有效题目数量:', previewResult.data.valid);
      console.log('无效题目数量:', previewResult.data.invalid);
      
      if (previewResult.data.questions && previewResult.data.questions.length > 0) {
        console.log('\n前3个题目预览:');
        previewResult.data.questions.slice(0, 3).forEach((q, index) => {
          console.log(`题目${index + 1}:`, {
            number: q.number,
            type: q.type,
            content: q.content?.substring(0, 50) + '...',
            isValid: q.isValid
          });
        });
      }
    } else {
      console.log('❌ 预览解析失败:', previewResult.message);
    }

  } catch (error) {
    console.error('测试过程中出现错误:', error);
  } finally {
    await sequelize.close();
  }

  console.log('\n=== 测试完成 ===');
}

// 运行测试
testPreviewParse();
