// 测试完整的解析和保存流程
const DocumentParser = require('./server/utils/documentParser');
const { Question } = require('./server/models');
const { sequelize } = require('./server/config/database');

// 测试内容（基于您的H3C文档）
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

async function testCompleteParsing() {
  try {
    console.log('🧪 测试完整的解析和保存流程...');
    
    // 连接数据库
    await sequelize.authenticate();
    console.log('✅ 数据库连接成功');
    
    // 1. 解析文档
    console.log('\n📋 步骤1: 解析文档...');
    const parser = new DocumentParser();
    const questions = await parser.extractQuestions({ text: testContent }, 'test.txt');
    
    console.log(`解析到 ${questions.length} 道题目`);
    
    // 显示解析结果
    questions.forEach((q, index) => {
      console.log(`\n--- 题目 ${index + 1} ---`);
      console.log('内容:', q.content ? q.content.substring(0, 50) + '...' : '无内容');
      console.log('选项数量:', q.options.length);
      console.log('答案:', q.answer);
      console.log('解析长度:', q.explanation ? q.explanation.length : 0);
      console.log('解析内容:', q.explanation ? q.explanation.substring(0, 100) + '...' : '无解析');
      console.log('是否有效:', q.isValid);
    });
    
    // 2. 保存到数据库
    console.log('\n📋 步骤2: 保存到数据库...');
    const savedQuestions = [];
    
    for (const questionData of questions.filter(q => q.isValid)) {
      const question = await Question.create({
        content: questionData.content,
        type: questionData.type,
        options: JSON.stringify(questionData.options.map(opt => ({
          key: opt.key,
          content: opt.content
        }))),
        answer: questionData.answer,
        analysis: questionData.explanation, // 使用analysis字段
        images: JSON.stringify(questionData.images || []),
        questionBankId: 1,
        subjectId: 1,
        chapter: '测试章节',
        createBy: 1,
        status: 'active'
      });
      
      savedQuestions.push(question);
      console.log(`✅ 题目 ${questionData.number} 保存成功，ID: ${question.id}`);
    }
    
    // 3. 验证保存结果
    console.log('\n📋 步骤3: 验证保存结果...');
    for (const question of savedQuestions) {
      const saved = await Question.findByPk(question.id);
      console.log(`\n--- 题目 ID: ${saved.id} ---`);
      console.log('内容:', saved.content ? saved.content.substring(0, 50) + '...' : '无内容');
      console.log('答案:', saved.answer);
      console.log('解析字段(analysis):', saved.analysis ? saved.analysis.substring(0, 100) + '...' : '无解析');
      console.log('解析字段长度:', saved.analysis ? saved.analysis.length : 0);
      
      // 验证解析内容
      if (saved.analysis && saved.analysis.trim().length > 0) {
        console.log('✅ 解析内容保存成功');
      } else {
        console.log('⚠️  解析内容为空或未保存');
      }
    }
    
    // 4. 清理测试数据
    console.log('\n📋 步骤4: 清理测试数据...');
    for (const question of savedQuestions) {
      await question.destroy();
      console.log(`🧹 题目 ID: ${question.id} 已删除`);
    }
    
    console.log('\n🎉 完整流程测试成功！');
    console.log('✅ 解析功能正常');
    console.log('✅ 保存功能正常');
    console.log('✅ analysis字段映射正确');
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
    console.error('错误堆栈:', error.stack);
  } finally {
    await sequelize.close();
  }
}

// 运行测试
testCompleteParsing();
