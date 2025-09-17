// 测试372-test.txt文件的解析功能
const fs = require('fs');
const path = require('path');
const DocumentParser = require('./server/utils/documentParser');

async function test372Parsing() {
  try {
    console.log('🧪 测试372-test.txt文件解析功能...');
    
    // 读取测试文件
    const filePath = path.join(__dirname, 'docs', '372-test.txt');
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    
    console.log(`文件路径: ${filePath}`);
    console.log(`文件大小: ${fileContent.length} 字符`);
    console.log(`文件行数: ${fileContent.split('\n').length} 行\n`);
    
    const parser = new DocumentParser();
    const questions = await parser.extractQuestions({ text: fileContent }, '372-test.txt');
    
    console.log(`解析到 ${questions.length} 道题目\n`);
    
    // 显示解析结果
    questions.forEach((q, index) => {
      console.log(`--- 题目 ${index + 1} (编号: ${q.number}) ---`);
      console.log('题目类型:', q.type);
      console.log('题目内容长度:', q.content ? q.content.length : 0);
      
      // 显示题目内容预览
      if (q.content) {
        console.log('题目内容预览:');
        const lines = q.content.split('\n');
        lines.slice(0, 3).forEach((line, lineIndex) => {
          console.log(`  ${lineIndex + 1}. ${line}`);
        });
        if (lines.length > 3) {
          console.log(`  ... (还有 ${lines.length - 3} 行)`);
        }
      }
      
      console.log('选项数量:', q.options.length);
      q.options.forEach((opt, optIndex) => {
        const optPreview = opt.content.length > 50 ? opt.content.substring(0, 50) + '...' : opt.content;
        console.log(`  ${opt.key}. ${optPreview}`);
      });
      
      console.log('答案:', q.answer);
      console.log('解析长度:', q.explanation ? q.explanation.length : 0);
      if (q.explanation && q.explanation.length > 0) {
        const expPreview = q.explanation.length > 100 ? q.explanation.substring(0, 100) + '...' : q.explanation;
        console.log('解析内容:', expPreview);
      }
      console.log('是否有效:', q.isValid);
      console.log('');
    });
    
    // 详细统计
    const totalQuestions = questions.length;
    const validQuestions = questions.filter(q => q.isValid).length;
    const questionsWithContent = questions.filter(q => q.content && q.content.trim().length > 0).length;
    const questionsWithOptions = questions.filter(q => q.options.length > 0).length;
    const questionsWithAnswer = questions.filter(q => q.answer && q.answer.trim().length > 0).length;
    const questionsWithExplanation = questions.filter(q => q.explanation && q.explanation.trim().length > 0).length;
    
    console.log('📊 解析效果统计:');
    console.log(`总题目数: ${totalQuestions}`);
    console.log(`有效题目数: ${validQuestions}`);
    console.log(`有题目内容的题目: ${questionsWithContent}`);
    console.log(`有选项的题目: ${questionsWithOptions}`);
    console.log(`有答案的题目: ${questionsWithAnswer}`);
    console.log(`有解析的题目: ${questionsWithExplanation}`);
    console.log(`解析成功率: ${(validQuestions / totalQuestions * 100).toFixed(1)}%`);
    
    // 检查多行题目
    const multiLineQuestions = questions.filter(q => {
      if (!q.content) return false;
      return q.content.includes('\n');
    });
    
    console.log(`\n📝 多行题目统计:`);
    console.log(`多行题目数: ${multiLineQuestions.length}`);
    
    if (multiLineQuestions.length > 0) {
      console.log('多行题目详情:');
      multiLineQuestions.forEach((q, index) => {
        const lineCount = q.content.split('\n').length;
        console.log(`  题目 ${q.number}: ${lineCount} 行`);
      });
    }
    
    // 检查特殊格式题目
    const specialFormatQuestions = questions.filter(q => {
      if (!q.content) return false;
      return q.content.includes('题目：') || q.content.includes('选项：');
    });
    
    console.log(`\n🏷️ 特殊格式题目统计:`);
    console.log(`带标记的题目数: ${specialFormatQuestions.length}`);
    
    if (specialFormatQuestions.length > 0) {
      console.log('⚠️  发现题目内容中包含标记:');
      specialFormatQuestions.forEach((q, index) => {
        console.log(`  题目 ${q.number}: 包含标记`);
      });
    } else {
      console.log('✅ 所有题目都正确解析，没有多余的标记');
    }
    
    // 检查选项内容质量
    const optionsWithNewlines = questions.filter(q => {
      return q.options.some(opt => opt.content.includes('\n'));
    });
    
    console.log(`\n📋 选项内容统计:`);
    console.log(`有多行选项的题目数: ${optionsWithNewlines.length}`);
    
    // 检查解析质量
    const questionsWithColons = questions.filter(q => {
      if (!q.explanation) return false;
      return q.explanation.includes(':') || q.explanation.includes('：');
    });
    
    console.log(`\n🔍 解析内容质量:`);
    console.log(`解析内容中有冒号的题目数: ${questionsWithColons.length}`);
    
    if (questionsWithColons.length > 0) {
      console.log('⚠️  部分解析内容可能仍有冒号问题');
    } else {
      console.log('✅ 所有解析内容都已清理冒号');
    }
    
    // 总结
    console.log(`\n🎯 解析总结:`);
    if (validQuestions === totalQuestions && questionsWithContent === totalQuestions && questionsWithOptions === totalQuestions && questionsWithAnswer === totalQuestions) {
      console.log('🎉 完美！所有题目都成功解析');
    } else {
      console.log('⚠️  部分题目解析可能存在问题，请检查具体内容');
    }
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
    console.error('错误堆栈:', error.stack);
  }
}

// 运行测试
test372Parsing();
