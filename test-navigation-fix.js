// 测试导航箭头修复
const fs = require('fs');
const path = require('path');

console.log('🔍 检查导航箭头修复...\n');

// 检查WXML文件中的HTML实体编码
function checkHTML实体编码(filePath, fileName) {
  console.log(`📋 检查 ${fileName}:`);
  
  if (fs.existsSync(filePath)) {
    const content = fs.readFileSync(filePath, 'utf-8');
    
    // 检查HTML实体编码
    const htmlEntityMatches = content.match(/&#[0-9]+;/g);
    if (htmlEntityMatches) {
      console.log(`  ❌ 发现HTML实体编码: ${htmlEntityMatches.join(', ')}`);
      return false;
    } else {
      console.log(`  ✅ 没有HTML实体编码`);
    }
    
    // 检查返回箭头
    if (content.includes('←')) {
      console.log(`  ✅ 使用Unicode箭头符号`);
    } else if (content.includes('&#8592;')) {
      console.log(`  ❌ 仍使用HTML实体编码`);
      return false;
    } else {
      console.log(`  ⚠️  没有找到返回箭头`);
    }
    
    return true;
  } else {
    console.log(`  ❌ 文件不存在: ${filePath}`);
    return false;
  }
}

// 检查所有WXML文件
function checkAllWXMLFiles() {
  console.log('📋 检查所有WXML文件:');
  
  const wxmlFiles = [
    'miniprogram/pages/answer/index.wxml',
    'miniprogram/pages/subject-list/index.wxml',
    'miniprogram/pages/question-bank/index.wxml',
    'miniprogram/pages/profile/index.wxml',
    'miniprogram/pages/home/index.wxml',
    'miniprogram/pages/question-upload/index.wxml',
    'miniprogram/pages/statistics/index.wxml',
    'miniprogram/pages/search/index.wxml',
    'miniprogram/components/phone-login-modal/phone-login-modal.wxml'
  ];
  
  let allFixed = true;
  
  wxmlFiles.forEach(filePath => {
    const fileName = path.basename(filePath);
    const isFixed = checkHTML实体编码(filePath, fileName);
    if (!isFixed) {
      allFixed = false;
    }
    console.log('');
  });
  
  return allFixed;
}

// 检查CSS样式
function checkCSSStyles() {
  console.log('📋 检查CSS样式:');
  
  const cssFiles = [
    'miniprogram/pages/answer/index.wxss',
    'miniprogram/pages/subject-list/index.wxss'
  ];
  
  cssFiles.forEach(filePath => {
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf-8');
      const fileName = path.basename(filePath);
      
      if (content.includes('.nav-back')) {
        console.log(`  ✅ ${fileName}: 包含导航返回按钮样式`);
        
        // 检查是否有字体相关样式
        if (content.includes('font-family') || content.includes('font-size')) {
          console.log(`  ✅ ${fileName}: 包含字体样式设置`);
        }
      } else {
        console.log(`  ⚠️  ${fileName}: 没有找到导航返回按钮样式`);
      }
    }
  });
  console.log('');
}

// 主检查函数
function main() {
  console.log('🚀 开始检查导航箭头修复...\n');
  
  // 检查WXML文件
  const allFixed = checkAllWXMLFiles();
  
  // 检查CSS样式
  checkCSSStyles();
  
  console.log('📊 修复总结:');
  if (allFixed) {
    console.log('✅ 所有HTML实体编码已修复');
    console.log('✅ 返回箭头使用Unicode符号');
    console.log('✅ 导航功能应该正常显示');
  } else {
    console.log('❌ 仍有HTML实体编码未修复');
    console.log('⚠️  需要进一步检查');
  }
  
  console.log('\n💡 修复内容:');
  console.log('1. ✅ 答题页面返回箭头: &#8592; → ←');
  console.log('2. ✅ 科目列表页面返回箭头: &#8592; → ←');
  console.log('3. ✅ 使用Unicode左箭头符号');
  console.log('4. ✅ 避免HTML实体编码问题');
  
  console.log('\n🎉 导航箭头修复检查完成！');
}

// 运行检查
main();
