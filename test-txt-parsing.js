// 测试TXT文档解析功能
const DocumentParser = require('./server/utils/documentParser');

// 测试内容（基于您提供的文档）
const testContent = `1.[单选]关于H3CAFCUDP端口保护说法错误的是？

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
RemoteApp程序处不填写Slrdp时调用mstsc`;

async function testTxtParsing() {
  try {
    console.log('🧪 开始测试TXT文档解析...');
    
    const parser = new DocumentParser();
    
    // 测试解析功能
    const questions = await parser.extractQuestions({ text: testContent }, 'test.txt');
    
    console.log('\n📋 解析结果:');
    console.log(`解析到 ${questions.length} 道题目`);
    
    questions.forEach((q, index) => {
      console.log(`\n--- 题目 ${index + 1} ---`);
      console.log('序号:', q.number);
      console.log('内容:', q.content);
      console.log('类型:', q.type);
      console.log('选项数量:', q.options.length);
      console.log('选项:', q.options.map(opt => `${opt.key}. ${opt.content}`).join('\n     '));
      console.log('答案:', q.answer);
      console.log('解析:', q.explanation);
      console.log('是否有效:', q.isValid);
      if (!q.isValid) {
        console.log('无效原因:', q.invalidReasons);
      }
    });
    
    // 分析问题
    console.log('\n🔍 问题分析:');
    const problems = [];
    
    questions.forEach((q, index) => {
      if (!q.explanation || q.explanation.trim() === '') {
        problems.push(`题目${index + 1}: 解析内容为空`);
      }
      if (!q.isValid) {
        problems.push(`题目${index + 1}: ${q.invalidReasons.join(', ')}`);
      }
    });
    
    if (problems.length > 0) {
      console.log('发现的问题:');
      problems.forEach(problem => console.log('  -', problem));
    } else {
      console.log('✅ 所有题目解析正常');
    }
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
  }
}

// 运行测试
testTxtParsing();
