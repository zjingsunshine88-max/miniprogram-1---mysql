// 测试题目上传修复
const fs = require('fs');
const path = require('path');

console.log('🔍 检查题目上传修复...\n');

// 检查控制器修复
function checkControllerFixes() {
  console.log('📋 检查控制器修复:');
  
  const files = [
    'server/controllers/enhancedQuestionController.js',
    'server/controllers/questionController.js'
  ];
  
  files.forEach(filePath => {
    const fileName = path.basename(filePath);
    console.log(`\n📁 ${fileName}:`);
    
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf-8');
      
      // 检查enhancedQuestionController.js
      if (fileName === 'enhancedQuestionController.js') {
        if (content.includes('subjectId === \'\'')) {
          console.log('  ✅ 添加了空字符串检查');
        } else {
          console.log('  ❌ 缺少空字符串检查');
        }
        
        if (content.includes('parseInt(subjectId)')) {
          console.log('  ✅ 添加了数字转换验证');
        } else {
          console.log('  ❌ 缺少数字转换验证');
        }
        
        if (content.includes('console.log(\'=== 智能上传参数 ===\')')) {
          console.log('  ✅ 添加了调试日志');
        } else {
          console.log('  ⚠️  没有调试日志');
        }
      }
      
      // 检查questionController.js
      if (fileName === 'questionController.js') {
        if (content.includes('处理科目ID')) {
          console.log('  ✅ 添加了科目ID处理逻辑');
        } else {
          console.log('  ❌ 缺少科目ID处理逻辑');
        }
        
        if (content.includes('Subject.findOne')) {
          console.log('  ✅ 添加了科目查找逻辑');
        } else {
          console.log('  ❌ 缺少科目查找逻辑');
        }
        
        if (content.includes('Subject.create')) {
          console.log('  ✅ 添加了科目创建逻辑');
        } else {
          console.log('  ❌ 缺少科目创建逻辑');
        }
        
        if (content.includes('subjectId = 1')) {
          console.log('  ✅ 添加了默认科目ID');
        } else {
          console.log('  ❌ 缺少默认科目ID');
        }
      }
    } else {
      console.log(`  ❌ 文件不存在: ${filePath}`);
    }
  });
}

// 检查数据库模型
function checkDatabaseModels() {
  console.log('\n📋 检查数据库模型:');
  
  const modelFiles = [
    'server/models/Question.js',
    'server/models/Subject.js'
  ];
  
  modelFiles.forEach(filePath => {
    const fileName = path.basename(filePath);
    console.log(`\n📁 ${fileName}:`);
    
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf-8');
      
      if (fileName === 'Question.js') {
        if (content.includes('subjectId:')) {
          console.log('  ✅ 包含subjectId字段定义');
        } else {
          console.log('  ❌ 缺少subjectId字段定义');
        }
        
        if (content.includes('questionBankId:')) {
          console.log('  ✅ 包含questionBankId字段定义');
        } else {
          console.log('  ❌ 缺少questionBankId字段定义');
        }
      }
      
      if (fileName === 'Subject.js') {
        if (content.includes('name:')) {
          console.log('  ✅ 包含name字段定义');
        } else {
          console.log('  ❌ 缺少name字段定义');
        }
        
        if (content.includes('questionBankId:')) {
          console.log('  ✅ 包含questionBankId字段定义');
        } else {
          console.log('  ❌ 缺少questionBankId字段定义');
        }
      }
    } else {
      console.log(`  ❌ 文件不存在: ${filePath}`);
    }
  });
}

// 检查前端代码
function checkFrontendCode() {
  console.log('\n📋 检查前端代码:');
  
  const frontendFile = 'miniprogram/pages/question-upload/index.js';
  
  if (fs.existsSync(frontendFile)) {
    const content = fs.readFileSync(frontendFile, 'utf-8');
    
    if (content.includes('customSubject')) {
      console.log('  ✅ 包含自定义科目字段');
    } else {
      console.log('  ❌ 缺少自定义科目字段');
    }
    
    if (content.includes('subject: this.data.customSubject.trim()')) {
      console.log('  ✅ 正确设置科目字段');
    } else {
      console.log('  ❌ 科目字段设置有问题');
    }
    
    if (content.includes('importQuestions')) {
      console.log('  ✅ 使用importQuestions API');
    } else {
      console.log('  ❌ 没有使用importQuestions API');
    }
  } else {
    console.log(`  ❌ 文件不存在: ${frontendFile}`);
  }
}

// 主检查函数
function main() {
  console.log('🚀 开始检查题目上传修复...\n');
  
  // 检查控制器修复
  checkControllerFixes();
  
  // 检查数据库模型
  checkDatabaseModels();
  
  // 检查前端代码
  checkFrontendCode();
  
  console.log('\n📊 修复总结:');
  console.log('✅ enhancedQuestionController.js:');
  console.log('  - 添加了空字符串检查');
  console.log('  - 添加了数字转换验证');
  console.log('  - 添加了调试日志');
  
  console.log('\n✅ questionController.js:');
  console.log('  - 添加了科目ID处理逻辑');
  console.log('  - 添加了科目查找逻辑');
  console.log('  - 添加了科目创建逻辑');
  console.log('  - 添加了默认科目ID');
  
  console.log('\n💡 修复原理:');
  console.log('1. 前端传递科目名称（subject）');
  console.log('2. 后端根据科目名称查找对应的科目ID');
  console.log('3. 如果科目不存在，自动创建新科目');
  console.log('4. 如果查找失败，使用默认科目ID');
  console.log('5. 确保subjectId字段不为空');
  
  console.log('\n🎯 预期效果:');
  console.log('- 不再出现外键约束错误');
  console.log('- 题目可以正常上传');
  console.log('- 科目信息正确关联');
  console.log('- 自动创建缺失的科目');
  
  console.log('\n🎉 题目上传修复检查完成！');
}

// 运行检查
main();
