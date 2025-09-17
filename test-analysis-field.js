// 测试analysis字段保存功能
const { Question } = require('./server/models');
const { sequelize } = require('./server/config/database');

async function testAnalysisField() {
  try {
    console.log('🧪 测试analysis字段保存功能...');
    
    // 测试数据
    const testQuestionData = {
      content: '测试题目内容',
      type: '单选题',
      options: [
        { key: 'A', content: '选项A' },
        { key: 'B', content: '选项B' },
        { key: 'C', content: '选项C' },
        { key: 'D', content: '选项D' }
      ],
      answer: 'A',
      explanation: '这是测试解析内容，应该保存到analysis字段中。',
      images: []
    };
    
    console.log('📋 测试数据:');
    console.log('解析内容:', testQuestionData.explanation);
    
    // 连接数据库
    await sequelize.authenticate();
    console.log('✅ 数据库连接成功');
    
    // 创建测试题目
    const question = await Question.create({
      content: testQuestionData.content,
      type: testQuestionData.type,
      options: JSON.stringify(testQuestionData.options),
      answer: testQuestionData.answer,
      analysis: testQuestionData.explanation, // 使用analysis字段
      images: JSON.stringify(testQuestionData.images),
      questionBankId: 1,
      subjectId: 1,
      chapter: '测试章节',
      createBy: 1,
      status: 'active'
    });
    
    console.log('✅ 题目创建成功，ID:', question.id);
    
    // 查询验证
    const savedQuestion = await Question.findByPk(question.id);
    console.log('\n📋 保存后的数据:');
    console.log('题目内容:', savedQuestion.content);
    console.log('答案:', savedQuestion.answer);
    console.log('解析字段(analysis):', savedQuestion.analysis);
    console.log('解析字段长度:', savedQuestion.analysis ? savedQuestion.analysis.length : 0);
    
    // 验证解析内容是否正确保存
    if (savedQuestion.analysis === testQuestionData.explanation) {
      console.log('✅ 解析内容保存成功！');
    } else {
      console.log('❌ 解析内容保存失败！');
      console.log('期望:', testQuestionData.explanation);
      console.log('实际:', savedQuestion.analysis);
    }
    
    // 清理测试数据
    await question.destroy();
    console.log('🧹 测试数据已清理');
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
  } finally {
    await sequelize.close();
  }
}

// 运行测试
testAnalysisField();
