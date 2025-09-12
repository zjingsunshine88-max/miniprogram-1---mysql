const DocumentParser = require('./utils/documentParser');
const path = require('path');

async function testWordParser() {
  console.log('开始测试Word文档解析...');
  
  const parser = new DocumentParser();
  
  // 测试Word文档路径
  const wordFilePath = path.join(__dirname, '../docs/超融合GB0-621.docx');
  
  try {
    console.log('正在解析Word文档:', wordFilePath);
    
    const questions = await parser.parseDocument(wordFilePath, 'docx');
    
    console.log('解析结果:');
    console.log(`共解析出 ${questions.length} 道题目`);
    
    questions.forEach((question, index) => {
      console.log(`\n题目 ${index + 1}:`);
      console.log(`  题号: ${question.number}`);
      console.log(`  内容: ${question.content?.substring(0, 100)}...`);
      console.log(`  类型: ${question.type}`);
      console.log(`  选项数量: ${question.options?.length || 0}`);
      console.log(`  答案: ${question.answer}`);
      console.log(`  解析: ${question.explanation?.substring(0, 50)}...`);
      console.log(`  图片数量: ${question.images?.length || 0}`);
      console.log(`  是否有效: ${question.isValid}`);
    });
    
    console.log('\nWord文档解析测试完成！');
  } catch (error) {
    console.error('Word文档解析测试失败:', error);
    console.log('可能的原因:');
    console.log('1. 文档格式不支持');
    console.log('2. 文档内容结构不符合预期');
    console.log('3. 依赖包未正确安装');
  }
}

// 运行测试
testWordParser();
