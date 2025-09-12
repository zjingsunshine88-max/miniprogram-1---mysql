const DocumentParser = require('./utils/documentParser');
const path = require('path');

async function testSmartParser() {
  console.log('开始测试智能文档解析器...');
  
  const parser = new DocumentParser();
  
  // 测试文本解析
  const testText = `
1. 以下哪个选项是正确的？
A. 选项A的内容
B. 选项B的内容
C. 选项C的内容
D. 选项D的内容
答案：A
解析：这是解析内容

2. 第二道题目...
A. 选项A
B. 选项B
答案：B
解析：解析内容

3. 第三道题目
A. 选项A
B. 选项B
C. 选项C
D. 选项D
E. 选项E
答案：ABCD
解析：这是多选题的解析
`;

  try {
    // 模拟文档内容
    const mockContent = {
      text: testText,
      images: []
    };
    
    const questions = await parser.extractQuestions(mockContent, 'test.txt');
    
    console.log('解析结果:');
    console.log(`共解析出 ${questions.length} 道题目`);
    
    questions.forEach((question, index) => {
      console.log(`\n题目 ${index + 1}:`);
      console.log(`  题号: ${question.number}`);
      console.log(`  内容: ${question.content}`);
      console.log(`  类型: ${question.type}`);
      console.log(`  选项数量: ${question.options.length}`);
      console.log(`  答案: ${question.answer}`);
      console.log(`  解析: ${question.explanation}`);
      console.log(`  是否有效: ${question.isValid}`);
    });
    
    console.log('\n测试完成！');
  } catch (error) {
    console.error('测试失败:', error);
  }
}

// 运行测试
testSmartParser();
