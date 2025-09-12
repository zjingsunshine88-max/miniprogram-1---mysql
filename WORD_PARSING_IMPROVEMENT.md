# Word文档解析改进方案

## 问题描述
用户上传Word文档时，解析出的题目内容为乱码（如"n jROaWdw4r3N e*1D97NXPX"），表明原有的文本提取逻辑无法正确处理Word文档的二进制格式。

## 改进方案

### 1. 文件读取改进
**修改文件：** `miniprogram/pages/question-upload/index.js`

#### 1.1 智能文件读取
```javascript
// 根据文件扩展名选择读取方式
readFileContent(filePath, fileName) {
  const fileExtension = fileName ? fileName.toLowerCase().split('.').pop() : ''
  
  // Office文档使用二进制读取
  if (['docx', 'doc', 'xlsx', 'xls'].includes(fileExtension)) {
    return this.readBinaryFile(filePath)
  } else {
    return this.readTextFile(filePath)
  }
}
```

#### 1.2 二进制文件处理
- 检测ArrayBuffer格式
- 转换为字符串处理
- 支持UTF-8和GBK编码回退

### 2. Word文档文本提取

#### 2.1 多格式支持
- **.docx**: 解析ZIP结构中的document.xml
- **.doc**: 处理OLE复合文档格式
- **XML格式**: 提取XML标签中的文本
- **纯文本**: 直接返回内容

#### 2.2 智能文本提取算法
```javascript
extractTextGeneric(content) {
  // 字符级别扫描，识别可读文本段
  // 支持中文、英文、数字、标点符号
  // 过滤二进制和控制字符
}
```

### 3. 用户体验改进

#### 3.1 格式建议
在上传页面添加了详细的格式说明：
- 📊 **推荐**：Excel/CSV格式（解析准确度最高）
- 📝 **TXT格式**：简单易用
- ⚠️ **Word格式**：实验性支持，建议转换为TXT

#### 3.2 错误排查指导
- 检查文件编码（推荐UTF-8）
- 将Word内容复制到记事本保存为TXT
- 使用Excel模板格式

## 技术实现细节

### 3.1 文件类型检测
```javascript
// .docx检测
if (content.includes('PK') && content.includes('word/')) {
  return this.extractFromDocx(content)
}

// .doc检测  
else if (content.includes('Microsoft Office Word')) {
  return this.extractFromDoc(content)
}

// XML格式检测
else if (content.includes('<?xml') || content.includes('<w:')) {
  return this.extractFromXML(content)
}
```

### 3.2 .docx文档解析
```javascript
extractFromDocx(content) {
  // 1. 定位document.xml部分
  const documentXmlMatch = content.match(/word\/document\.xml.*?<\/w:document>/s)
  
  // 2. 提取<w:t>标签中的文本
  const textMatches = xmlContent.match(/<w:t[^>]*>([^<]*)<\/w:t>/g)
  
  // 3. 合并文本内容
  return textParts.join(' ')
}
```

### 3.3 通用文本提取
```javascript
extractTextGeneric(content) {
  let currentText = ''
  for (let i = 0; i < content.length; i++) {
    const char = content[i]
    const charCode = char.charCodeAt(0)
    
    // 可读字符检测
    if ((charCode >= 32 && charCode <= 126) ||     // ASCII
        (charCode >= 0x4e00 && charCode <= 0x9fff) || // 中文
        /[\s\n\r\t]/.test(char)) {                  // 空白
      currentText += char
    } else {
      // 保存有效文本段
      if (currentText.trim().length > 5) {
        textLines.push(currentText.trim())
      }
      currentText = ''
    }
  }
}
```

## 预期效果

### 4.1 支持的Word格式
- ✅ `.docx`（现代Office格式）
- ✅ `.doc`（旧版Office格式）
- ✅ 纯文本Word文档
- ✅ XML格式的Word内容

### 4.2 解析改进
- 大幅提高Word文档文本提取准确性
- 减少乱码和解析错误
- 保持与原有TXT/CSV解析的兼容性

### 4.3 用户体验
- 清晰的格式建议和错误提示
- 多种文件格式支持
- 智能格式检测和处理

## 使用建议

### 5.1 最佳实践
1. **优先使用Excel/CSV格式**：解析准确度最高
2. **TXT格式**：适合简单题目导入
3. **Word格式**：作为备选方案

### 5.2 问题排查
如果遇到Word文档解析问题：
1. 检查文件是否损坏
2. 尝试另存为TXT格式
3. 使用Excel模板重新整理数据
4. 查看控制台日志了解具体错误

## 版本兼容性
- ✅ 向后兼容原有功能
- ✅ 不影响现有TXT/CSV解析
- ✅ 渐进式改进，出错时优雅降级

## 未来优化方向
1. 支持更多Office格式
2. 增加图片/表格内容识别
3. 提供格式转换工具
4. 批量文件上传支持
