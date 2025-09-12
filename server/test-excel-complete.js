const XLSX = require('xlsx');
const fs = require('fs');

// 测试完整的Excel文件生成和验证
console.log('开始测试完整的Excel文件生成...');

try {
  // 创建工作簿
  const workbook = XLSX.utils.book_new();
  
  // 创建测试数据 - 模拟真实的题库数据
  const testData = [
    ['题目ID', '章节', '题目类型', '难度', '题目内容', '选项A', '选项B', '选项C', '选项D', '选项E', '选项F', '正确答案', '解析', '图片路径', '创建时间'],
    [1, '第一章', '单选题', '中等', '华为认证中，以下哪个是云计算的核心特征？', '按需自助服务', '资源池化', '快速弹性扩展', '以上都是', '', '', 'D', '云计算的核心特征包括按需自助服务、资源池化、快速弹性扩展等。', '', '2024-01-15 10:00:00'],
    [2, '第一章', '多选题', '困难', '以下哪些属于华为云服务？', 'ECS弹性云服务器', 'RDS关系型数据库', 'OBS对象存储服务', 'VPC虚拟私有云', 'CDN内容分发网络', '以上都是', 'ABCDE', '华为云提供ECS、RDS、OBS、VPC、CDN等多种云服务。', '', '2024-01-15 10:05:00'],
    [3, '第二章', '判断题', '简单', '华为云是基于OpenStack构建的。', '正确', '错误', '', '', '', '', '正确', '华为云确实是基于OpenStack开源云平台构建的。', '', '2024-01-15 10:10:00']
  ];
  
  // 创建工作表
  const worksheet = XLSX.utils.aoa_to_sheet(testData);
  
  // 设置列宽
  const colWidths = [
    { wch: 8 },  // 题目ID
    { wch: 15 }, // 章节
    { wch: 10 }, // 题目类型
    { wch: 8 },  // 难度
    { wch: 50 }, // 题目内容
    { wch: 30 }, // 选项A
    { wch: 30 }, // 选项B
    { wch: 30 }, // 选项C
    { wch: 30 }, // 选项D
    { wch: 30 }, // 选项E
    { wch: 30 }, // 选项F
    { wch: 15 }, // 正确答案
    { wch: 40 }, // 解析
    { wch: 50 }, // 图片路径
    { wch: 20 }  // 创建时间
  ];
  worksheet['!cols'] = colWidths;
  
  // 添加工作表到工作簿
  XLSX.utils.book_append_sheet(workbook, worksheet, '华为认证题库');
  
  // 生成Excel文件buffer
  const excelBuffer = XLSX.write(workbook, { 
    type: 'buffer', 
    bookType: 'xlsx',
    compression: true
  });
  
  console.log('Excel文件生成成功，大小:', excelBuffer.length, 'bytes');
  
  // 验证buffer是否有效
  if (!excelBuffer || excelBuffer.length === 0) {
    throw new Error('Excel文件buffer为空');
  }
  
  // 检查文件头是否正确（Excel文件应该以PK开头，表示ZIP格式）
  const fileHeader = excelBuffer.toString('hex', 0, 4);
  console.log('文件头:', fileHeader);
  
  if (fileHeader !== '504b0304') {
    console.warn('警告: 文件头不正确，可能不是有效的Excel文件');
  }
  
  // 保存到文件进行测试
  fs.writeFileSync('./test-complete-export.xlsx', excelBuffer);
  console.log('测试文件已保存为 test-complete-export.xlsx');
  
  // 尝试读取文件验证
  try {
    const readWorkbook = XLSX.readFile('./test-complete-export.xlsx');
    const sheetNames = readWorkbook.SheetNames;
    console.log('文件读取成功，工作表数量:', sheetNames.length);
    console.log('工作表名称:', sheetNames);
    
    // 读取第一个工作表的数据
    const firstSheet = readWorkbook.Sheets[sheetNames[0]];
    const range = XLSX.utils.decode_range(firstSheet['!ref']);
    console.log('数据范围:', firstSheet['!ref']);
    console.log('行数:', range.e.r + 1, '列数:', range.e.c + 1);
    
  } catch (readError) {
    console.error('读取Excel文件失败:', readError);
  }
  
} catch (error) {
  console.error('Excel文件生成失败:', error);
}
