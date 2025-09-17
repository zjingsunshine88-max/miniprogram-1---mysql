// 测试冒号修复功能
const DocumentParser = require('./server/utils/documentParser');

// 测试内容（包含各种冒号情况）
const testContent = `1.[单选]关于H3CAFCUDP端口保护说法错误的是？

A.开放端口是指设备会允许此端口的连接
B.TTL验证是指检测UDP包中的TTL值是否一样
C.同步连接是指选中后，此端口先得有TCP连接才会接受UDP连接
D.延时提交和TCP端口保护中的含义一样

答案：D

解析:
:这是解析内容，开头的冒号应该被去掉
这是第二行解析内容
:这是第三行，开头也有冒号

2. [多选]H3C堡垒机可以通过应用发布服务器发布应用，下面应用发布服务器说法错误的是？

A.应用发布服务器支持winserver2008和winserver2012
B.可通过应用发布服务器发布数据库客户端
C.可通过应用发布服务器发布Chrome、IE浏览器
D.RemoteApp程序处不需填写Slrdp
E.发布应用时是通过添加rdpapp服务实现的

答案：AB

解析:
:应用发布服务器支持winserver2008
:可通过应用发布服务器发布Chrome、IE浏览器
RemoteApp程序处不填写Slrdp时调用mstsc

3. [单选]关于透明模式说法正确的是？

A.透明模式是指设备对用户透明
B.透明模式可以隐藏设备存在
C.透明模式部署简单
D.以上都正确

答案：D

解析:
:透明模式、反向代理模式部署简单`;

async function testColonFix() {
  try {
    console.log('🧪 测试冒号修复功能...');
    
    const parser = new DocumentParser();
    const questions = await parser.extractQuestions({ text: testContent }, 'test.txt');
    
    console.log(`解析到 ${questions.length} 道题目\n`);
    
    // 显示解析结果
    questions.forEach((q, index) => {
      console.log(`--- 题目 ${index + 1} ---`);
      console.log('内容:', q.content ? q.content.substring(0, 50) + '...' : '无内容');
      console.log('答案:', q.answer);
      console.log('解析长度:', q.explanation ? q.explanation.length : 0);
      
      if (q.explanation) {
        console.log('解析内容:');
        console.log('```');
        console.log(q.explanation);
        console.log('```');
        
        // 检查是否还有开头的冒号
        const lines = q.explanation.split('\n');
        lines.forEach((line, lineIndex) => {
          if (line.trim().startsWith(':')) {
            console.log(`⚠️  第${lineIndex + 1}行仍有开头冒号: "${line}"`);
          }
        });
        
        // 检查是否有中文冒号
        if (q.explanation.includes('：')) {
          console.log('⚠️  解析内容中仍包含中文冒号');
        }
        
        if (!q.explanation.includes(':') && !q.explanation.includes('：')) {
          console.log('✅ 解析内容中没有多余的冒号');
        }
      } else {
        console.log('⚠️  解析内容为空');
      }
      
      console.log('是否有效:', q.isValid);
      console.log('');
    });
    
    // 统计修复效果
    const totalQuestions = questions.length;
    const questionsWithExplanation = questions.filter(q => q.explanation && q.explanation.trim().length > 0).length;
    const questionsWithColons = questions.filter(q => {
      if (!q.explanation) return false;
      const lines = q.explanation.split('\n');
      return lines.some(line => line.trim().startsWith(':') || line.trim().startsWith('：'));
    }).length;
    
    console.log('📊 修复效果统计:');
    console.log(`总题目数: ${totalQuestions}`);
    console.log(`有解析内容的题目: ${questionsWithExplanation}`);
    console.log(`仍有开头冒号的题目: ${questionsWithColons}`);
    console.log(`修复成功率: ${((questionsWithExplanation - questionsWithColons) / questionsWithExplanation * 100).toFixed(1)}%`);
    
    if (questionsWithColons === 0) {
      console.log('🎉 冒号修复成功！所有解析内容都没有多余的冒号');
    } else {
      console.log('⚠️  仍有部分解析内容包含多余的冒号，需要进一步修复');
    }
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
  }
}

// 运行测试
testColonFix();
