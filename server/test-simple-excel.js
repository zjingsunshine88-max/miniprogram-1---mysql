const XLSX = require('xlsx');
const fs = require('fs');

console.log('测试简单的Excel文件生成...');

try {
  // 创建最简单的工作簿
  const workbook = XLSX.utils.book_new();
  
  // 创建简单的测试数据
  const data = [
    ['题目ID', '题目内容', '答案'],
    [1, '测试题目1', 'A'],
    [2, '测试题目2', 'B']
  ];
  
  // 创建工作表
  const worksheet = XLSX.utils.aoa_to_sheet(data);
  
  // 添加工作表
  XLSX.utils.book_append_sheet(workbook, worksheet, '测试题库');
  
  // 生成Excel文件
  const excelBuffer = XLSX.write(workbook, { 
    type: 'buffer', 
    bookType: 'xlsx'
  });
  
  console.log('Excel文件大小:', excelBuffer.length, 'bytes');
  
  // 检查文件头
  const header = excelBuffer.toString('hex', 0, 4);
  console.log('文件头:', header);
  
  // 保存文件
  fs.writeFileSync('./simple-test.xlsx', excelBuffer);
  console.log('文件已保存为 simple-test.xlsx');
  
  // 尝试读取验证
  const readWorkbook = XLSX.readFile('./simple-test.xlsx');
  console.log('读取成功，工作表:', readWorkbook.SheetNames);
  
} catch (error) {
  console.error('错误:', error);
}
