// 测试H3C文档解析功能
const DocumentParser = require('./server/utils/documentParser');

// 基于您提供的H3C文档内容
const h3cContent = `1.[单选]关于H3CAFCUDP端口保护说法错误的是？

A.开放端口是指设备会允许此端口的连接，如果没有选开放端口，设备就拦截外网进来的连接此端口的数据
B.TTL验证是指检测UDP包中的TTL值是否一样（对UDP数据的IP头部TTL进行统计，如果是某个数值的TTL频率过高会进行屏蔽，可在一定程度上防御UDP类攻击）
C.同步连接是指选中后，此端口（或范围）先得有TCP连接才会接受UDP连接，否则拦截UDP的数据包
D.延时提交和TCP端口保护中的含义一样，是指设置此选项的端口，系统将无限缓存该连接，除非客户端有数据发送，或者该连接被重置

答案：D

解析:



2. [多选]H3C堡垒机可以通过应用发布服务器发布应用，下面应用发布服务器说法错误的是？

A.应用发布服务器支持winserver2008和winserver2012
B.可通过应用发布服务器发布数据库客户端，对部分工具可实现账号密码自动代填、自动登录
C.可通过应用发布服务器发布Chrome、IE浏览器，并可对部分url进行账号密码代填、自动登录
D.RemoteApp程序处不需填写Slrdp
E.发布应用时是通过添加rdpapp服务实现的

答案：AB

解析:
应用发布服务器支持winserver2008
可通过应用发布服务器发布Chrome、IE浏览器，并可对部分url进行账号密码代填、自动登录
RemoteApp程序处不填写Slrdp时调用mstsc

3.[多选]H3CWAF支持的部署模式有？

A.网桥模式
B.透明模式
C.路由模式
D.反向代理模式
E.旁路模式

答案：BDE
 
解析:
透明模式、反向代理模式、旁路监听/阻断模式、混合模式四种`;

async function testH3CParsing() {
  try {
    console.log('🧪 开始测试H3C文档解析...');
    console.log('📄 文档内容预览:');
    console.log(h3cContent.substring(0, 200) + '...');
    console.log('\n' + '='.repeat(50));
    
    const parser = new DocumentParser();
    
    // 测试解析功能
    const questions = await parser.extractQuestions({ text: h3cContent }, 'h3c-test.txt');
    
    console.log('\n📋 解析结果统计:');
    console.log(`总题目数: ${questions.length}`);
    console.log(`有效题目: ${questions.filter(q => q.isValid).length}`);
    console.log(`无效题目: ${questions.filter(q => !q.isValid).length}`);
    
    console.log('\n📝 详细解析结果:');
    questions.forEach((q, index) => {
      console.log(`\n--- 题目 ${index + 1} ---`);
      console.log('序号:', q.number);
      console.log('内容:', q.content ? q.content.substring(0, 100) + '...' : '无内容');
      console.log('类型:', q.type);
      console.log('选项数量:', q.options.length);
      
      if (q.options.length > 0) {
        console.log('选项:');
        q.options.forEach(opt => {
          console.log(`  ${opt.key}. ${opt.content.substring(0, 80)}${opt.content.length > 80 ? '...' : ''}`);
        });
      }
      
      console.log('答案:', q.answer);
      console.log('解析长度:', q.explanation ? q.explanation.length : 0);
      console.log('解析内容:', q.explanation ? q.explanation.substring(0, 100) + '...' : '无解析');
      console.log('是否有效:', q.isValid);
      
      if (!q.isValid && q.invalidReasons) {
        console.log('无效原因:', q.invalidReasons.join(', '));
      }
    });
    
    // 分析具体问题
    console.log('\n🔍 问题分析:');
    const analysis = {
      noContent: 0,
      noOptions: 0,
      noAnswer: 0,
      noExplanation: 0,
      shortExplanation: 0
    };
    
    questions.forEach((q, index) => {
      if (!q.content || q.content.trim().length < 10) {
        analysis.noContent++;
        console.log(`题目${index + 1}: 内容过短或为空`);
      }
      if (!q.options || q.options.length < 2) {
        analysis.noOptions++;
        console.log(`题目${index + 1}: 选项数量不足 (${q.options ? q.options.length : 0})`);
      }
      if (!q.answer || q.answer.trim().length === 0) {
        analysis.noAnswer++;
        console.log(`题目${index + 1}: 答案为空`);
      }
      if (!q.explanation || q.explanation.trim().length === 0) {
        analysis.noExplanation++;
        console.log(`题目${index + 1}: 解析为空`);
      } else if (q.explanation.trim().length < 10) {
        analysis.shortExplanation++;
        console.log(`题目${index + 1}: 解析内容过短 (${q.explanation.trim().length}字符)`);
      }
    });
    
    console.log('\n📊 问题统计:');
    console.log('内容问题:', analysis.noContent);
    console.log('选项问题:', analysis.noOptions);
    console.log('答案问题:', analysis.noAnswer);
    console.log('解析问题:', analysis.noExplanation);
    console.log('解析过短:', analysis.shortExplanation);
    
    // 提供改进建议
    console.log('\n💡 改进建议:');
    if (analysis.noExplanation > 0) {
      console.log('1. 解析为空的问题：');
      console.log('   - 检查解析模式是否匹配文档格式');
      console.log('   - 确认解析内容是否在多行中');
      console.log('   - 验证解析标记是否正确识别');
    }
    
    if (analysis.noOptions > 0) {
      console.log('2. 选项识别问题：');
      console.log('   - 检查选项模式是否匹配文档格式');
      console.log('   - 确认选项标记（A.、B.等）是否正确');
    }
    
    if (analysis.noAnswer > 0) {
      console.log('3. 答案识别问题：');
      console.log('   - 检查答案模式是否匹配文档格式');
      console.log('   - 确认答案标记（答案：A）是否正确');
    }
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
  }
}

// 运行测试
testH3CParsing();
