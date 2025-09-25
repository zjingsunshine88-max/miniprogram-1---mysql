const DocumentParser = require('../utils/documentParser');
const path = require('path');
const fs = require('fs');
const { Question, QuestionBank, Subject } = require('../models/associations');

/**
 * 增强的题目控制器
 * 支持智能文档解析和题目上传
 */
class EnhancedQuestionController {
  constructor() {
    this.documentParser = new DocumentParser();
  }

  /**
   * 智能上传题目
   */
  async smartUpload(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '未提供认证token' };
        return;
      }

      const { questionBankId, subjectId, fileType } = ctx.request.body;
      
      console.log('=== 智能上传参数 ===');
      console.log('questionBankId:', questionBankId);
      console.log('subjectId:', subjectId);
      console.log('fileType:', fileType);
      console.log('subjectId类型:', typeof subjectId);
      console.log('subjectId是否为空字符串:', subjectId === '');
      console.log('========================');
      
      if (!questionBankId || !subjectId || subjectId === '') {
        ctx.body = { code: 400, message: '请选择题库和科目' };
        return;
      }

      // 获取上传的文件
      const file = ctx.request.file;
      if (!file) {
        ctx.body = { code: 400, message: '请选择要上传的文件' };
        return;
      }

      // 验证文件类型
      const allowedTypes = ['docx', 'doc', 'xlsx', 'xls', 'pdf', 'txt'];
      const fileExtension = path.extname(file.originalname).toLowerCase().slice(1);
      
      if (!allowedTypes.includes(fileExtension)) {
        ctx.body = { code: 400, message: '不支持的文件格式' };
        return;
      }

      // 创建临时目录
      const tempDir = path.join(__dirname, '../../temp');
      await fs.promises.mkdir(tempDir, { recursive: true });

      // 保存上传的文件
      const tempFilePath = path.join(tempDir, `${Date.now()}_${file.originalname}`);
      await fs.promises.copyFile(file.path, tempFilePath);

      try {
        // 解析文档
        const parsedQuestions = await this.documentParser.parseDocument(tempFilePath, fileExtension);
        
        console.log('=== 智能上传解析结果 ===');
        console.log('解析到的题目数量:', parsedQuestions.length);
        parsedQuestions.forEach((q, index) => {
          console.log(`题目 ${index + 1}:`, {
            content: q.content,
            options: q.options,
            answer: q.answer,
            isValid: q.isValid
          });
        });
        console.log('========================');
        
        // 验证解析结果
        const validQuestions = parsedQuestions.filter(q => q.isValid);
        const invalidQuestions = parsedQuestions.filter(q => !q.isValid);

        // 验证subjectId是否为有效数字
        const subjectIdNum = parseInt(subjectId);
        if (isNaN(subjectIdNum) || subjectIdNum <= 0) {
          ctx.body = { code: 400, message: '科目ID无效' };
          return;
        }

        // 保存题目到数据库
        const savedQuestions = [];
        for (const questionData of validQuestions) {
          const question = await this.saveQuestion(questionData, questionBankId, subjectIdNum, userId);
          savedQuestions.push(question);
        }

        // 清理临时文件
        await fs.promises.unlink(tempFilePath);

        ctx.body = {
          code: 200,
          message: '题目上传成功',
          data: {
            total: parsedQuestions.length,
            valid: validQuestions.length,
            invalid: invalidQuestions.length,
            saved: savedQuestions.length,
            questions: savedQuestions,
            invalidQuestions: invalidQuestions
          }
        };

      } catch (parseError) {
        // 清理临时文件
        await fs.promises.unlink(tempFilePath);
        throw parseError;
      }

    } catch (error) {
      console.error('智能上传失败:', error);
      ctx.body = {
        code: 500,
        message: '上传失败: ' + error.message
      };
    }
  }

  /**
   * 保存题目到数据库
   */
  async saveQuestion(questionData, questionBankId, subjectId, userId) {
    console.log('=== 保存题目到数据库 ===');
    console.log('题目数据:', {
      content: questionData.content,
      options: questionData.options,
      answer: questionData.answer,
      type: questionData.type,
      explanation: questionData.explanation
    });
    
    // 处理选项
    const options = questionData.options.map(opt => ({
      key: opt.key,
      content: opt.content
    }));
    
    console.log('处理后的选项:', options);
    console.log('选项JSON字符串:', JSON.stringify(options));

    // 处理图片
    const images = questionData.images || [];

    const question = await Question.create({
      content: questionData.content,
      type: questionData.type,
      options: JSON.stringify(options),
      answer: questionData.answer,
      analysis: questionData.explanation, // 修复字段映射：explanation -> analysis
      images: JSON.stringify(images),
      questionBankId: questionBankId,
      subjectId: subjectId,
      chapter: '',
      createBy: userId,
      status: 'active'
    });
    
    console.log('保存成功，题目ID:', question.id);
    console.log('========================');

    return question;
  }

  /**
   * 预览解析结果
   */
  async previewParse(ctx) {
    try {
      console.log('=== 预览解析请求 ===');
      console.log('ctx.request.files:', ctx.request.files);
      console.log('ctx.request.body:', ctx.request.body);
      console.log('ctx.request.headers:', ctx.request.headers);
      
      const file = ctx.request.file;
      if (!file) {
        console.log('没有找到文件，返回错误');
        ctx.body = { code: 400, message: '请选择要预览的文件' };
        return;
      }
      
      console.log('找到文件:', file);

      const fileExtension = path.extname(file.originalname).toLowerCase().slice(1);
      const allowedTypes = ['docx', 'doc', 'xlsx', 'xls', 'pdf', 'txt'];
      
      if (!allowedTypes.includes(fileExtension)) {
        ctx.body = { code: 400, message: '不支持的文件格式' };
        return;
      }

      // 解析文档
      console.log('开始解析文档:', file.path, '类型:', fileExtension);
      const parsedQuestions = await this.documentParser.parseDocument(file.path, fileExtension);
      console.log('解析完成，题目数量:', parsedQuestions.length);

      // 返回预览数据
      ctx.body = {
        code: 200,
        message: '解析成功',
        data: {
          total: parsedQuestions.length,
          valid: parsedQuestions.filter(q => q.isValid).length,
          invalid: parsedQuestions.filter(q => !q.isValid).length,
          questions: parsedQuestions.map(q => ({
            number: q.number,
            content: q.content,
            type: q.type,
            options: q.options,
            answer: q.answer,
            explanation: q.explanation,
            isValid: q.isValid,
            images: q.images
          }))
        }
      };

    } catch (error) {
      console.error('预览解析失败:', error);
      console.error('错误堆栈:', error.stack);
      ctx.body = {
        code: 500,
        message: '解析失败: ' + error.message
      };
    }
  }

  /**
   * 获取支持的文档格式
   */
  async getSupportedFormats(ctx) {
    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        formats: [
          {
            type: 'docx',
            name: 'Word文档',
            extensions: ['.docx', '.doc'],
            description: '支持包含图片的Word文档'
          },
          {
            type: 'xlsx',
            name: 'Excel表格',
            extensions: ['.xlsx', '.xls'],
            description: '支持Excel格式的题目表格'
          },
          {
            type: 'pdf',
            name: 'PDF文档',
            extensions: ['.pdf'],
            description: '支持PDF格式的题目文档'
          },
          {
            type: 'txt',
            name: '文本文档',
            extensions: ['.txt'],
            description: '支持纯文本格式的题目'
          }
        ]
      }
    };
  }

  /**
   * 获取解析模板
   */
  async getParseTemplate(ctx) {
    const { format } = ctx.query;
    
    const templates = {
      docx: {
        name: 'Word文档模板',
        description: 'Word文档中题目的标准格式',
        example: `1. 以下哪个选项是正确的？
A. 选项A的内容
B. 选项B的内容
C. 选项C的内容
D. 选项D的内容
答案：A
解析：这是解析内容

2. 第二道题目...
A. 选项A
B. 选项B
答案：B
解析：解析内容`
      },
      xlsx: {
        name: 'Excel表格模板',
        description: 'Excel表格中题目的标准格式',
        columns: [
          { name: '题目内容', description: '题目的具体内容' },
          { name: '选项A', description: '选项A的内容' },
          { name: '选项B', description: '选项B的内容' },
          { name: '选项C', description: '选项C的内容' },
          { name: '选项D', description: '选项D的内容' },
          { name: '答案', description: '正确答案（如：A、B、AB等）' },
          { name: '解析', description: '题目解析内容' }
        ]
      },
      txt: {
        name: '文本文档模板',
        description: '文本文档中题目的标准格式',
        example: `1. 以下哪个选项是正确的？
A. 选项A的内容
B. 选项B的内容
C. 选项C的内容
D. 选项D的内容
答案：A
解析：这是解析内容

2. 第二道题目...
A. 选项A
B. 选项B
答案：B
解析：解析内容`
      }
    };

    ctx.body = {
      code: 200,
      message: '获取成功',
      data: templates[format] || templates.docx
    };
  }
}

module.exports = new EnhancedQuestionController();
