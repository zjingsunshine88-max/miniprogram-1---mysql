const DocumentParser = require('./utils/documentParser');
const path = require('path');

async function testDocumentParser() {
  try {
    console.log('=== 测试文档解析器 ===\n');
    
    const parser = new DocumentParser();
    
    // 检查测试文件是否存在
    const testFilePath = path.join(__dirname, '../docs/H3CSE-Security(GB0-551) 2025-9-1 151956 1.docx');
    console.log('测试文件路径:', testFilePath);
    
    const fs = require('fs');
    if (!fs.existsSync(testFilePath)) {
      console.log('❌ 测试文件不存在');
      return;
    }
    
    console.log('✅ 测试文件存在');
    console.log('文件大小:', fs.statSync(testFilePath).size, 'bytes\n');
    
    // 测试解析
    console.log('开始解析文档...');
    const questions = await parser.parseDocument(testFilePath, 'docx');
    
    console.log('✅ 解析完成！');
    console.log('题目总数:', questions.length);
    console.log('有效题目:', questions.filter(q => q.isValid).length);
    console.log('无效题目:', questions.filter(q => !q.isValid).length);
    
    if (questions.length > 0) {
      console.log('\n前3个题目预览:');
      questions.slice(0, 3).forEach((q, index) => {
        console.log(`\n题目${index + 1}:`);
        console.log('  序号:', q.number);
        console.log('  类型:', q.type);
        console.log('  内容:', q.content?.substring(0, 100) + '...');
        console.log('  选项数量:', q.options?.length || 0);
        console.log('  答案:', q.answer);
        console.log('  是否有效:', q.isValid);
        if (q.errors && q.errors.length > 0) {
          console.log('  错误:', q.errors);
        }
      });
    }
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
    console.error('错误堆栈:', error.stack);
  }
  
  console.log('\n=== 测试完成 ===');
}

testDocumentParser();
