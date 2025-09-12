const { ActivationCode, ActivationCodeSubject, Subject, QuestionBank, User } = require('./models/associations');

async function testActivationCode() {
  try {
    console.log('测试激活码功能...');
    
    // 检查表是否存在
    const activationCodes = await ActivationCode.findAll();
    console.log('激活码表存在，当前激活码数量:', activationCodes.length);
    
    // 检查科目表
    const subjects = await Subject.findAll({
      include: [
        {
          model: QuestionBank,
          as: 'questionBank',
          attributes: ['id', 'name']
        }
      ]
    });
    console.log('科目数量:', subjects.length);
    
    if (subjects.length > 0) {
      console.log('可用科目:');
      subjects.forEach(subject => {
        console.log(`- ${subject.questionBank.name} - ${subject.name} (ID: ${subject.id})`);
      });
    }
    
    // 检查用户表
    const users = await User.findAll();
    console.log('用户数量:', users.length);
    
    console.log('激活码功能测试完成！');
    process.exit(0);
  } catch (error) {
    console.error('测试失败:', error);
    process.exit(1);
  }
}

testActivationCode();
