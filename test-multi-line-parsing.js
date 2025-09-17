// 测试多行题目解析功能
const DocumentParser = require('./server/utils/documentParser');

// 测试内容（基于您的372-test.txt格式）
const testContent = `1.[多选]
图示为经过STP计算收敛后的稳定拓扑，则下列说法正确的有

A.SWA为网络中的根桥
B.该BPDU为配置BPDU,目的地址为01-80-C2-00-00-00
C.该BPDU的发送周期为HelloTime
D.端口保存该BPDU的老化时间为MaxAge
答案：ABCD

2.[单选]关于配置BPDU和TCNBPDU,说法正确的有
A.配置BPDU仅从指定端口发出，TCNBPDU仅从根端口发出
B.配置BPDU通常仅由根桥周期性发出，TCNBPDU除根桥外其他网桥都可能发出
C.配置BPDU通常仅从根端口接收，TCNBPDU仅从指定端口接收
D.Alternate端口既不会发送配BPDU也不会发送TCNBPDU
答案：ABCD

3.[单选]关于TCNBPDU的产生，下列说法正确的有
A.启用STP的非根桥交换机如果某端口连接了PC机，当该端口进入Forwarding状交换机不会产生TCNBPDU
B.网络中某交换机的指定端口链路断掉，则该交换机一定会产生TCNBPDU
C.网络中某交换机的Alternate端口链路断掉，则该交换机不会产生TCNBPDU
D.当交换机某端口选择为指定端口或根端口时，交换机会立即发送TCNBPDU
答案：C

4.[多选]二台路由器通过局域网连接在一起，组成VRRP备份组如果路由器RTA收到路由器RTB发送的VRRP协议报文，报文Priority字段AuthType字段值为2,则

A. 路由器RTB启用VRRPv2协议
B.路由器RTB启用VRRPV3协议
C.路由器RTB为VRRPIP地址拥有者
D.路由器RTB启用了VRRP简单字符认证
答案：AC

5.[单选]

题目：
二台路由器通过局域网连接在一起，组成VRRP备份组各接口上配置如下:
[RTA-GigabitEthernet1/0]displaythis
ipaddress192.168.0.252255.255.255.0
vrrpvrid1virtual-ip192.168.1.254
vrrpvrid1priority120
[RTB-GigabitEthernet1/0]displaythis
ipaddress192.168.0.253255.255.255.0
vrrpvrid1virtual-ip192.168.1.254
从上述信息可以得知

选项：
A.RTA为备份组Master路由器
B.RTB为备份组Master路由器
C.RTA、RTB都处于VRRPInitialize状态
D.RTA、RTB都处于VRRPMaster状态
答案：C

6.[单选]
题目：
二台路由器通过局域网连接在一起，组成VRRP备份组在各接口上对VRRP计时器配置如下：
[RTA-GigabitEthernet1/0]vrrpvrid1timeradvertise5
[RTB-GigabitEthernet1/0]vrrpvrid1timeradvertise5
VRRP备份组1运行正常，RTA为Master,RTB为Backup若设备运行一段时间后，路由器RTA故障,则路由器RTB从Backup变成Master的时间可能为
选项：
A.3秒
B.5秒
C.12秒
D.20秒
答案：C

7.[多选]在PIM-DM组网中，关于SPT形成的过程(不考虑状态刷新机制)，描述正确的有
A.经过扩散-剪枝过程，形成组播源到组播接收者之间的SPT
B.扩散-剪枝过程周期进行
C.被剪枝的接口不再向下游发送组播报文
D.只要网络拓扑、单播路由信息不变，形成的SPT树就不会改变
答案：AB

8.[单选]进行三层组播配置之前，首先需要进行的配置是
A.进入IGMP视图
B.SB置IGMpi议版本
C.配置PIM协议
D.通过multicastrouting-enable命令全局启用组播
答案：D

9.[多选]如果需要在一个三层网络中实现组播数据的转发，至少配置如下协议或功能
A.IGMPSnooping功能
B.IGMP协议
C.PIM协议
D.BSR配置
答案：BC

10.[单选]以下属于汇聚层功能的是(选择一项或多项)
A.拥有大量的接口，用于与最终用户计算机相连
B.接入安全控制
C.高速的包交换
D.复杂的路由策略
答案：D`;

async function testMultiLineParsing() {
  try {
    console.log('🧪 测试多行题目解析功能...');
    
    const parser = new DocumentParser();
    const questions = await parser.extractQuestions({ text: testContent }, 'test.txt');
    
    console.log(`解析到 ${questions.length} 道题目\n`);
    
    // 显示解析结果
    questions.forEach((q, index) => {
      console.log(`--- 题目 ${index + 1} ---`);
      console.log('题目编号:', q.number);
      console.log('题目类型:', q.type);
      console.log('题目内容长度:', q.content ? q.content.length : 0);
      console.log('题目内容:');
      if (q.content) {
        // 显示前100个字符
        const preview = q.content.length > 100 ? q.content.substring(0, 100) + '...' : q.content;
        console.log(preview);
      }
      
      console.log('选项数量:', q.options.length);
      q.options.forEach((opt, optIndex) => {
        console.log(`  ${opt.key}. ${opt.content}`);
      });
      
      console.log('答案:', q.answer);
      console.log('解析长度:', q.explanation ? q.explanation.length : 0);
      console.log('是否有效:', q.isValid);
      console.log('');
    });
    
    // 统计解析效果
    const totalQuestions = questions.length;
    const validQuestions = questions.filter(q => q.isValid).length;
    const questionsWithContent = questions.filter(q => q.content && q.content.trim().length > 0).length;
    const questionsWithOptions = questions.filter(q => q.options.length > 0).length;
    const questionsWithAnswer = questions.filter(q => q.answer && q.answer.trim().length > 0).length;
    
    console.log('📊 解析效果统计:');
    console.log(`总题目数: ${totalQuestions}`);
    console.log(`有效题目数: ${validQuestions}`);
    console.log(`有题目内容的题目: ${questionsWithContent}`);
    console.log(`有选项的题目: ${questionsWithOptions}`);
    console.log(`有答案的题目: ${questionsWithAnswer}`);
    console.log(`解析成功率: ${(validQuestions / totalQuestions * 100).toFixed(1)}%`);
    
    // 检查特殊格式的题目（带题目：和选项：标记的）
    const specialFormatQuestions = questions.filter(q => {
      if (!q.content) return false;
      return q.content.includes('题目：') || q.content.includes('选项：');
    });
    
    console.log(`\n📋 特殊格式题目统计:`);
    console.log(`带标记的题目数: ${specialFormatQuestions.length}`);
    
    if (specialFormatQuestions.length > 0) {
      console.log('⚠️  发现题目内容中包含标记，可能需要进一步优化');
      specialFormatQuestions.forEach((q, index) => {
        console.log(`题目 ${q.number}: 包含标记`);
      });
    } else {
      console.log('✅ 所有题目都正确解析，没有多余的标记');
    }
    
    // 检查多行题目解析效果
    const multiLineQuestions = questions.filter(q => {
      if (!q.content) return false;
      return q.content.includes('\n');
    });
    
    console.log(`\n📝 多行题目统计:`);
    console.log(`多行题目数: ${multiLineQuestions.length}`);
    
    if (multiLineQuestions.length > 0) {
      console.log('✅ 成功解析多行题目');
      multiLineQuestions.forEach((q, index) => {
        const lineCount = q.content.split('\n').length;
        console.log(`题目 ${q.number}: ${lineCount} 行`);
      });
    }
    
  } catch (error) {
    console.error('❌ 测试失败:', error);
    console.error('错误堆栈:', error.stack);
  }
}

// 运行测试
testMultiLineParsing();
