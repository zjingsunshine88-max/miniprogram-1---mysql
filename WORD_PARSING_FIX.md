# Word文档解析修复说明

## 🚨 问题描述

从截图可以看出，Word文档解析出现了严重问题：
- 系统显示Word文档的原始XML内容而不是解析后的文本
- 题目内容显示为：`word/_rels/document.xml.relsPK□Y3word/footi89word/theme/theme1.xn_M__@___X@word/syword/styles.xmRword/webs□e2word/font`
- 选项和答案字段为空
- 数据验证失败

## 🔧 修复方案

### 1. 添加文本提取功能

**问题原因**：Word文档包含XML标签和二进制内容，需要先提取纯文本。

**解决方案**：
```javascript
// 从Word文档内容中提取文本
extractTextFromWord(content) {
  const textLines = []
  const lines = content.split('\n')
  
  for (let line of lines) {
    // 跳过XML标签和二进制内容
    if (line.includes('<?xml') || line.includes('<') || line.includes('PK') || 
        line.includes('word/') || line.includes('_rels/') || line.includes('theme/')) {
      continue
    }
    
    // 清理特殊字符
    let cleanLine = line
      .replace(/[^\u4e00-\u9fa5a-zA-Z0-9\s\.、，。？！：；""''（）【】]/g, '')
      .replace(/\s+/g, ' ')
      .trim()
    
    if (cleanLine && cleanLine.length > 2) {
      textLines.push(cleanLine)
    }
  }
  
  return textLines.join('\n')
}
```

### 2. 改进Word文档解析逻辑

**增强功能**：
- 支持多种答案格式（答案：A、答案 A、A等）
- 自动识别多选题（根据答案长度）
- 支持科目和章节信息提取
- 增强错误处理和调试信息

```javascript
parseWordContent(content) {
  console.log('开始解析Word文档内容:', content.substring(0, 500))
  
  const questions = []
  const lines = content.split('\n').filter(line => line.trim())
  
  let currentQuestion = null
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    
    // 检测题目开始
    const questionMatch = line.match(/^(\d+)[\.、\s]*(.+)/)
    if (questionMatch) {
      if (currentQuestion) {
        // 根据答案判断题目类型
        if (currentQuestion.answer && currentQuestion.answer.length > 1) {
          currentQuestion.type = '多选题'
        }
        questions.push(currentQuestion)
      }
      
      currentQuestion = {
        type: '单选题',
        content: questionMatch[2].trim(),
        optionA: '', optionB: '', optionC: '', optionD: '',
        answer: '', analysis: '', difficulty: '中等',
        subject: '通用', chapter: '通用'
      }
    } else if (currentQuestion) {
      // 检测选项
      const optionMatch = line.match(/^([A-D])[\.、\s]*(.+)/)
      if (optionMatch) {
        const option = optionMatch[1]
        const content = optionMatch[2].trim()
        currentQuestion[`option${option}`] = content
      } else if (line.includes('答案') || line.includes('正确答案')) {
        // 多种答案格式支持
        let foundAnswer = false
        
        // 格式1：答案：A
        const answerMatch1 = line.match(/[答案正确答案：]\s*([A-D,\s;]+)/)
        if (answerMatch1) {
          const cleanAnswer = answerMatch1[1].replace(/[,;\s]/g, '')
          if (/^[A-D]+$/.test(cleanAnswer)) {
            currentQuestion.answer = cleanAnswer
            if (cleanAnswer.length > 1) {
              currentQuestion.type = '多选题'
            }
            foundAnswer = true
          }
        }
        
        // 格式2：答案 A
        if (!foundAnswer) {
          const answerMatch2 = line.match(/[答案正确答案]\s+([A-D,\s;]+)/)
          if (answerMatch2) {
            const cleanAnswer = answerMatch2[1].replace(/[,;\s]/g, '')
            if (/^[A-D]+$/.test(cleanAnswer)) {
              currentQuestion.answer = cleanAnswer
              if (cleanAnswer.length > 1) {
                currentQuestion.type = '多选题'
              }
              foundAnswer = true
            }
          }
        }
        
        // 格式3：直接匹配 A、B、C、D
        if (!foundAnswer) {
          const answerMatch3 = line.match(/([A-D,\s;]+)/)
          if (answerMatch3) {
            const cleanAnswer = answerMatch3[1].replace(/[,;\s]/g, '')
            if (/^[A-D]+$/.test(cleanAnswer)) {
              currentQuestion.answer = cleanAnswer
              if (cleanAnswer.length > 1) {
                currentQuestion.type = '多选题'
              }
              foundAnswer = true
            }
          }
        }
      } else if (line.includes('解析') || line.includes('说明')) {
        // 检测解析
        const analysisMatch = line.match(/[解析说明：]\s*(.+)/)
        if (analysisMatch) {
          currentQuestion.analysis = analysisMatch[1].trim()
        } else {
          currentQuestion.analysis = line
        }
      } else if (line.includes('难度')) {
        // 检测难度
        const difficultyMatch = line.match(/难度[：\s]*(简单|中等|困难)/)
        if (difficultyMatch) {
          currentQuestion.difficulty = difficultyMatch[1]
        }
      } else if (line.includes('科目') || line.includes('学科')) {
        // 检测科目
        const subjectMatch = line.match(/[科目学科：]\s*(.+)/)
        if (subjectMatch) {
          currentQuestion.subject = subjectMatch[1].trim()
        }
      } else if (line.includes('章节') || line.includes('单元')) {
        // 检测章节
        const chapterMatch = line.match(/[章节单元：]\s*(.+)/)
        if (chapterMatch) {
          currentQuestion.chapter = chapterMatch[1].trim()
        }
      }
    }
  }
  
  // 添加最后一个题目
  if (currentQuestion) {
    if (currentQuestion.answer && currentQuestion.answer.length > 1) {
      currentQuestion.type = '多选题'
    }
    questions.push(currentQuestion)
  }
  
  return questions
}
```

### 3. 改进Excel/CSV解析

**增强功能**：
- 支持引号内的逗号
- 自动识别多选题
- 更好的错误处理

```javascript
parseExcelContent(content) {
  console.log('开始解析Excel/CSV内容')
  
  const lines = content.split('\n')
  const questions = []
  
  // 跳过标题行
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim()
    if (!line) continue
    
    // 处理CSV格式，支持引号内的逗号
    const columns = this.parseCSVLine(line)
    
    if (columns.length >= 4) {
      const question = {
        type: columns[0]?.trim() || '单选题',
        content: columns[1]?.trim() || '',
        optionA: columns[2]?.trim() || '',
        optionB: columns[3]?.trim() || '',
        optionC: columns[4]?.trim() || '',
        optionD: columns[5]?.trim() || '',
        answer: columns[6]?.trim() || '',
        analysis: columns[7]?.trim() || '',
        difficulty: columns[8]?.trim() || '中等',
        subject: columns[9]?.trim() || '通用',
        chapter: columns[10]?.trim() || '通用'
      }
      
      // 根据答案长度判断题目类型
      if (question.answer && question.answer.length > 1) {
        question.type = '多选题'
      }
      
      questions.push(question)
    }
  }
  
  return questions
}

// 解析CSV行，支持引号内的逗号
parseCSVLine(line) {
  const columns = []
  let current = ''
  let inQuotes = false
  
  for (let i = 0; i < line.length; i++) {
    const char = line[i]
    
    if (char === '"') {
      inQuotes = !inQuotes
    } else if (char === ',' && !inQuotes) {
      columns.push(current.trim())
      current = ''
    } else {
      current += char
    }
  }
  
  // 添加最后一列
  columns.push(current.trim())
  
  return columns
}
```

### 4. 增强数据验证

**改进功能**：
- 支持更多判断题答案格式
- 更详细的错误信息
- 更好的调试信息

```javascript
validateData(questions) {
  console.log('开始验证数据，题目数:', questions.length)
  
  const validatedQuestions = []
  const errorMessages = []
  
  questions.forEach((question, index) => {
    const rowNum = index + 1
    const errors = []
    
    // 验证必填字段
    if (!question.content) errors.push('题目内容不能为空')
    if (!question.answer) errors.push('正确答案不能为空')
    
    // 验证题目类型
    const validTypes = ['单选题', '多选题', '判断题']
    if (question.type && !validTypes.includes(question.type)) {
      errors.push('题目类型必须是：单选题、多选题、判断题')
    }
    
    // 验证难度等级
    const validDifficulties = ['简单', '中等', '困难']
    if (question.difficulty && !validDifficulties.includes(question.difficulty)) {
      errors.push('难度等级必须是：简单、中等、困难')
    }
    
    // 验证选择题选项
    if (question.type === '单选题' || question.type === '多选题') {
      const options = [question.optionA, question.optionB, question.optionC, question.optionD].filter(opt => opt && opt.trim())
      if (options.length < 2) {
        errors.push('选择题至少需要包含两个选项')
      }
    }
    
    // 验证答案格式
    if (question.type === '单选题') {
      const validAnswers = ['A', 'B', 'C', 'D']
      if (question.answer && !validAnswers.includes(question.answer)) {
        errors.push('单选题答案必须是A、B、C、D之一')
      }
    } else if (question.type === '多选题') {
      const cleanAnswer = question.answer.replace(/[,;\s]/g, '')
      if (!/^[A-D]+$/.test(cleanAnswer)) {
        errors.push('多选题答案必须是A、B、C、D的组合')
      } else {
        question.answer = cleanAnswer
      }
    } else if (question.type === '判断题') {
      const validAnswers = ['正确', '错误', '对', '错', 'T', 'F', 'Y', 'N']
      if (question.answer && !validAnswers.includes(question.answer)) {
        errors.push('判断题答案必须是：正确/错误/对/错/T/F/Y/N')
      }
    }
    
    const isValid = errors.length === 0
    validatedQuestions.push({
      ...question,
      isValid,
      errors: errors.length > 0 ? `第${rowNum}行：${errors.join('，')}` : ''
    })
    
    if (errors.length > 0) {
      errorMessages.push(`第${rowNum}行：${errors.join('，')}`)
    }
  })
  
  console.log('数据验证完成，有效题目数:', validatedQuestions.filter(q => q.isValid).length)
  console.log('错误题目数:', validatedQuestions.filter(q => !q.isValid).length)
  
  return validatedQuestions
}
```

### 5. 更新云函数处理

**改进功能**：
- 支持判断题答案格式标准化
- 更好的错误处理
- 详细的日志信息

```javascript
// 批量导入题目
async importQuestions(event) {
  const { questions, userId } = event
  
  try {
    console.log('批量导入题目，用户ID:', userId, '题目数量:', questions.length)
    
    // 验证管理员权限
    const adminResult = await db.collection('admins').where({
      userId: userId
    }).get()
    
    if (adminResult.data.length === 0) {
      return {
        code: 403,
        message: '权限不足，仅限管理员操作'
      }
    }
    
    // 批量添加题目
    const addPromises = questions.map(question => {
      // 构建选项数组
      const options = []
      if (question.optionA) options.push({ key: 'A', content: question.optionA })
      if (question.optionB) options.push({ key: 'B', content: question.optionB })
      if (question.optionC) options.push({ key: 'C', content: question.optionC })
      if (question.optionD) options.push({ key: 'D', content: question.optionD })
      
      // 处理判断题答案格式
      let normalizedAnswer = question.answer
      if (question.type === '判断题') {
        if (['对', 'T', 'Y'].includes(question.answer)) {
          normalizedAnswer = '正确'
        } else if (['错', 'F', 'N'].includes(question.answer)) {
          normalizedAnswer = '错误'
        }
      }
      
      return db.collection('questions').add({
        data: {
          type: question.type || '单选题',
          content: question.content,
          options: options,
          answer: normalizedAnswer,
          analysis: question.analysis || '',
          difficulty: question.difficulty || '中等',
          subject: question.subject || '通用',
          chapter: question.chapter || '通用',
          createTime: new Date(),
          createBy: userId
        }
      })
    })
    
    const results = await Promise.all(addPromises)
    
    console.log('题目导入成功，导入数量:', results.length)
    
    return {
      code: 200,
      message: `成功导入 ${results.length} 道题目`,
      data: {
        importedCount: results.length,
        totalCount: questions.length
      }
    }
  } catch (error) {
    console.error('批量导入题目失败:', error)
    return {
      code: 500,
      message: '导入题目失败',
      error: error.message
    }
  }
}
```

## 📋 测试步骤

### 1. 测试Word文档解析
```bash
node test-word-parsing.js
```

### 2. 测试Excel/CSV解析
```bash
node test-question-upload.js
```

### 3. 测试云函数导入
```bash
node test-cloud-function.js
```

## 🎯 预期结果

修复后应该能够：
1. ✅ 正确提取Word文档中的文本内容
2. ✅ 正确解析题目、选项、答案、解析等信息
3. ✅ 自动识别单选题和多选题
4. ✅ 支持多种答案格式
5. ✅ 正确验证数据并显示错误信息
6. ✅ 成功导入题目到数据库

## 📞 故障排除

如果仍有问题，请检查：
1. Word文档格式是否正确
2. 文件编码是否为UTF-8
3. 云函数是否正确部署
4. 数据库权限是否正确配置

---

**注意**：修复后请重新部署云函数并重新编译小程序。
