const { QuestionBank } = require('./models/associations');

async function checkQuestionBanks() {
  try {
    console.log('检查题库数据...');
    
    const banks = await QuestionBank.findAll();
    
    console.log(`找到 ${banks.length} 个题库:`);
    
    if (banks.length === 0) {
      console.log('数据库中没有题库数据，创建默认题库...');
      
      // 创建默认题库
      const defaultBank = await QuestionBank.create({
        name: '默认题库',
        description: '系统默认题库',
        status: 'active',
        createdBy: 1
      });
      
      console.log('创建默认题库成功:', defaultBank.name);
    } else {
      banks.forEach((bank, index) => {
        console.log(`${index + 1}. ID: ${bank.id}, 名称: ${bank.name}, 状态: ${bank.status}`);
      });
    }
    
    process.exit(0);
  } catch (error) {
    console.error('检查题库失败:', error);
    process.exit(1);
  }
}

checkQuestionBanks();
