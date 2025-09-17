// 清理现有数据库中解析内容的多余冒号
const { Question } = require('./server/models');
const { sequelize } = require('./server/config/database');

async function cleanExistingColons() {
  try {
    console.log('🧹 清理现有数据库中解析内容的多余冒号...');
    
    // 连接数据库
    await sequelize.authenticate();
    console.log('✅ 数据库连接成功');
    
    // 查找所有有解析内容的题目
    const questions = await Question.findAll({
      where: {
        analysis: {
          [sequelize.Op.ne]: null
        }
      }
    });
    
    console.log(`找到 ${questions.length} 道有解析内容的题目`);
    
    let cleanedCount = 0;
    let totalColonsRemoved = 0;
    
    for (const question of questions) {
      if (!question.analysis) continue;
      
      const originalAnalysis = question.analysis;
      let cleanedAnalysis = originalAnalysis;
      
      // 按行处理，去掉每行开头的冒号
      const lines = cleanedAnalysis.split('\n');
      const cleanedLines = lines.map(line => {
        const cleanedLine = line.replace(/^[：:]\s*/, '').trim();
        if (cleanedLine !== line) {
          totalColonsRemoved++;
        }
        return cleanedLine;
      });
      
      cleanedAnalysis = cleanedLines.join('\n').trim();
      
      // 如果有变化，更新数据库
      if (cleanedAnalysis !== originalAnalysis) {
        await question.update({ analysis: cleanedAnalysis });
        cleanedCount++;
        
        console.log(`\n--- 题目 ID: ${question.id} ---`);
        console.log('原始解析:');
        console.log(originalAnalysis);
        console.log('清理后解析:');
        console.log(cleanedAnalysis);
        console.log('✅ 已更新');
      }
    }
    
    console.log('\n📊 清理统计:');
    console.log(`总题目数: ${questions.length}`);
    console.log(`需要清理的题目: ${cleanedCount}`);
    console.log(`清理的冒号总数: ${totalColonsRemoved}`);
    console.log(`清理成功率: ${(cleanedCount / questions.length * 100).toFixed(1)}%`);
    
    if (cleanedCount > 0) {
      console.log('\n🎉 数据库清理完成！');
    } else {
      console.log('\n✅ 数据库中没有需要清理的冒号');
    }
    
  } catch (error) {
    console.error('❌ 清理失败:', error);
  } finally {
    await sequelize.close();
  }
}

// 运行清理
cleanExistingColons();
