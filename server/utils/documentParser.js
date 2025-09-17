const mammoth = require('mammoth');
const xlsx = require('xlsx');
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const AdmZip = require('adm-zip');

/**
 * 智能文档解析器
 * 支持多种格式：Word、Excel、PDF、TXT
 * 自动识别题目结构：序号、标题、选项、答案、解析、图片
 */
class DocumentParser {
  constructor() {
    this.questionPatterns = {
      // 题目序号模式
      questionNumber: [
        /^(\d+)[\.、]\s*/,           // 1. 或 1、
        /^第(\d+)题\s*/,             // 第1题
        /^(\d+)\s*[\.、]\s*/,        // 1. 或 1、
        /^\((\d+)\)\s*/,             // (1)
        /^(\d+)\s*\)\s*/             // 1)
      ],
      
      // 选项模式
      options: [
        /^[A-Z][\.、]\s*(.+)/,       // A. 选项内容
        /^[A-Z][\.、](.+)/,          // A.选项内容 (没有空格)
        /^[A-Z]\s*[\.、]\s*(.+)/,    // A. 选项内容
        /^\([A-Z]\)\s*(.+)/,         // (A) 选项内容
        /^[A-Z]\)\s*(.+)/,           // A) 选项内容
        /^[A-Z]\s*[\.、]\s*(.+)/     // A. 选项内容
      ],
      
      // 答案模式
      answer: [
        /^答案[：:]\s*([A-Z]+)/i,    // 答案：A
        /^正确答案[：:]\s*([A-Z]+)/i, // 正确答案：A
        /^正确答案([A-Z]+)/i,        // 正确答案ABD (没有冒号)
        /^答案\s*([A-Z]+)/i,         // 答案A
        /^[A-Z]+$/                   // 单独的字母
      ],
      
      // 解析模式
      explanation: [
        /^解析[：:]\s*(.+)/i,        // 解析：内容
        /^解答[：:]\s*(.+)/i,        // 解答：内容
        /^说明[：:]\s*(.+)/i,        // 说明：内容
        /^分析[：:]\s*(.+)/i,        // 分析：内容
        /^解析\s*(.+)/i,            // 解析 内容 (没有冒号)
        /^解答\s*(.+)/i,            // 解答 内容
        /^说明\s*(.+)/i,            // 说明 内容
        /^分析\s*(.+)/i             // 分析 内容
      ]
    };
  }

  /**
   * 解析文档
   * @param {string} filePath - 文件路径
   * @param {string} fileType - 文件类型
   * @returns {Promise<Array>} 解析后的题目数组
   */
  async parseDocument(filePath, fileType) {
    try {
      let content;
      
      switch (fileType.toLowerCase()) {
        case 'docx':
        case 'doc':
          content = await this.parseWordDocument(filePath);
          break;
        case 'xlsx':
        case 'xls':
          content = await this.parseExcelDocument(filePath);
          break;
        case 'pdf':
          content = await this.parsePdfDocument(filePath);
          break;
        case 'txt':
          content = await this.parseTextDocument(filePath);
          break;
        default:
          throw new Error(`不支持的文件格式: ${fileType}`);
      }
      
      return await this.extractQuestions(content, filePath);
    } catch (error) {
      console.error('文档解析失败:', error);
      throw error;
    }
  }

  /**
   * 解析Word文档
   */
  async parseWordDocument(filePath) {
    const result = await mammoth.extractRawText({ path: filePath });
    const images = await this.extractImagesFromWord(filePath);
    
    return {
      text: result.value,
      images: images,
      messages: result.messages
    };
  }

  /**
   * 从Word文档中提取图片
   */
  async extractImagesFromWord(filePath) {
    try {
      // 使用mammoth提取图片的正确方法
      const result = await mammoth.extractRawText({ path: filePath });
      
      // 暂时返回空数组，因为图片提取比较复杂
      // 后续可以集成其他库来提取图片
      console.log('Word文档解析完成，图片提取功能待完善');
      return [];
    } catch (error) {
      console.error('提取Word图片失败:', error);
      return [];
    }
  }

  /**
   * 解析Excel文档
   */
  async parseExcelDocument(filePath) {
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    const data = xlsx.utils.sheet_to_json(worksheet, { header: 1 });
    
    // 提取Excel中的图片
    const images = await this.extractImagesFromExcel(filePath);
    
    return {
      text: this.excelToText(data),
      images: images,
      data: data,
      isTableFormat: this.isTableFormat(data)
    };
  }

  /**
   * 从Excel文档中提取图片
   */
  async extractImagesFromExcel(filePath) {
    try {
      const zip = new AdmZip(filePath);
      const entries = zip.getEntries();
      const images = [];
      
      // 创建临时目录存储图片
      const tempDir = path.join(path.dirname(filePath), 'temp_images');
      if (!fs.existsSync(tempDir)) {
        fs.mkdirSync(tempDir, { recursive: true });
      }
      
      for (const entry of entries) {
        // 查找Excel中的图片文件
        if (entry.entryName.startsWith('xl/media/') && 
            (entry.entryName.endsWith('.png') || 
             entry.entryName.endsWith('.jpg') || 
             entry.entryName.endsWith('.jpeg') || 
             entry.entryName.endsWith('.gif'))) {
          
          const imageName = path.basename(entry.entryName);
          const imagePath = path.join(tempDir, imageName);
          
          // 提取图片文件
          fs.writeFileSync(imagePath, entry.getData());
          
          // 处理图片（压缩、调整大小等）
          const processedImagePath = path.join(tempDir, `processed_${imageName}`);
          await this.processImage(imagePath, processedImagePath);
          
          images.push({
            name: imageName,
            path: processedImagePath,
            originalName: entry.entryName
          });
          
          console.log(`提取Excel图片: ${imageName}`);
        }
      }
      
      return images;
    } catch (error) {
      console.error('提取Excel图片失败:', error);
      return [];
    }
  }

  /**
   * 检测是否为表格格式
   */
  isTableFormat(data) {
    if (data.length < 2) return false;
    
    const firstRow = data[0];
    // 检查是否包含题目相关的列标题
    const questionKeywords = ['题目类型', '题目内容', '选项', '答案', '解析'];
    const hasQuestionKeywords = questionKeywords.some(keyword => 
      firstRow.some(cell => cell && cell.toString().includes(keyword))
    );
    
    return hasQuestionKeywords;
  }

  /**
   * 解析表格格式的题目
   */
  parseTableFormatQuestions(data) {
    const questions = [];
    
    if (data.length < 2) return questions;
    
    const headers = data[0];
    const dataRows = data.slice(1);
    
    // 找到各列的索引
    const typeIndex = headers.findIndex(h => h && h.toString().includes('题目类型'));
    const contentIndex = headers.findIndex(h => h && h.toString().includes('题目内容'));
    const answerIndex = headers.findIndex(h => h && h.toString().includes('答案'));
    const explanationIndex = headers.findIndex(h => h && h.toString().includes('解析'));
    
    // 找到选项列
    const optionIndices = [];
    headers.forEach((header, index) => {
      if (header && header.toString().includes('选项')) {
        optionIndices.push(index);
      }
    });
    
    dataRows.forEach((row, rowIndex) => {
      if (!row[contentIndex]) return; // 跳过空行
      
      const question = {
        number: rowIndex + 1,
        content: row[contentIndex] || '',
        type: this.determineQuestionType(row[typeIndex], optionIndices.length),
        options: [],
        answer: row[answerIndex] || '',
        explanation: row[explanationIndex] || '',
        images: []
      };
      
      // 解析选项
      optionIndices.forEach((optionIndex, optionNumber) => {
        const optionContent = row[optionIndex];
        if (optionContent && optionContent.toString().trim()) {
          question.options.push({
            key: String.fromCharCode(65 + optionNumber), // A, B, C, D, E
            content: optionContent.toString().trim()
          });
        }
      });
      
      // 验证题目完整性
      const validation = this.validateQuestion(question);
      question.isValid = validation.isValid;
      question.invalidReasons = validation.reasons;
      
      if (question.isValid) {
        questions.push(question);
      }
    });
    
    return questions;
  }

  /**
   * 确定题目类型
   */
  determineQuestionType(typeStr, optionCount) {
    if (!typeStr) {
      // 根据选项数量推断
      if (optionCount <= 2) return '判断题';
      if (optionCount <= 4) return '单选题';
      return '多选题';
    }
    
    const type = typeStr.toString().toLowerCase();
    if (type.includes('单选')) return '单选题';
    if (type.includes('多选')) return '多选题';
    if (type.includes('判断')) return '判断题';
    
    return '单选题'; // 默认单选
  }

  /**
   * 将Excel数据转换为文本
   */
  excelToText(data) {
    return data.map(row => row.join('\t')).join('\n');
  }

  /**
   * 解析PDF文档（需要安装pdf-parse）
   */
  async parsePdfDocument(filePath) {
    const pdfParse = require('pdf-parse');
    const dataBuffer = fs.readFileSync(filePath);
    const data = await pdfParse(dataBuffer);
    
    return {
      text: data.text,
      images: [], // PDF图片提取需要更复杂的处理
      pages: data.numpages
    };
  }

  /**
   * 解析文本文档
   */
  async parseTextDocument(filePath) {
    const content = await fs.promises.readFile(filePath, 'utf-8');
    
    return {
      text: content,
      images: []
    };
  }

  /**
   * 从文档内容中提取题目
   */
  async extractQuestions(content, filePath) {
    let questions = [];
    
    // 如果是Excel表格格式，使用专门的解析方法
    if (content.isTableFormat && content.data) {
      questions = this.parseTableFormatQuestions(content.data);
    } else {
      // 使用原有的文本解析方法
      const textContent = content.text || content || '';
      const lines = textContent.split('\n').map(line => line.trim()).filter(line => line);
      let currentQuestion = null;
      let currentOptions = [];
      let currentImages = [];
      
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        
        // 检查是否是题目开始
        const questionMatch = this.matchQuestionNumber(line);
        if (questionMatch) {
          // 保存上一个题目
          if (currentQuestion) {
            questions.push(this.finalizeQuestion(currentQuestion, currentOptions, currentImages));
          }
          
          // 开始新题目
          currentQuestion = {
            number: questionMatch.number,
            content: line.replace(questionMatch.match, '').trim(),
            type: '单选题', // 默认为单选题
            options: [],
            answer: '',
            explanation: '',
            images: []
          };
          currentOptions = [];
          currentImages = [];
          continue;
        }
        
        // 检查是否是选项
        const optionMatch = this.matchOption(line);
        if (optionMatch && currentQuestion) {
          currentOptions.push({
            key: optionMatch.key,
            content: optionMatch.content
          });
          continue;
        }
        
        // 检查是否是答案
        const answerMatch = this.matchAnswer(line);
        if (answerMatch && currentQuestion) {
          currentQuestion.answer = answerMatch.answer;
          continue;
        }
        
        // 检查是否是解析
        const explanationMatch = this.matchExplanation(line);
        if (explanationMatch && currentQuestion) {
          currentQuestion.explanation = explanationMatch.explanation;
          continue;
        }
        
        // 如果当前题目已经有解析开始标记，继续收集解析内容
        if (currentQuestion && currentQuestion.explanation !== undefined && !this.isSpecialLine(line)) {
          // 去掉行开头的冒号
          let cleanLine = line.replace(/^[：:]\s*/, '').trim();
          currentQuestion.explanation += '\n' + cleanLine;
          continue;
        }
        
        // 如果当前有题目，这可能是题目内容的延续
        if (currentQuestion && !this.isSpecialLine(line)) {
          if (currentQuestion.content) {
            currentQuestion.content += '\n' + line;
          } else {
            currentQuestion.content = line;
          }
        }
      }
      
      // 保存最后一个题目
      if (currentQuestion) {
        questions.push(this.finalizeQuestion(currentQuestion, currentOptions, currentImages));
      }
    }
    
    // 处理文档中的图片
    if (content.images && content.images.length > 0) {
      await this.assignImagesToQuestions(questions, content.images, filePath);
    }
    
    return questions;
  }

  /**
   * 匹配题目序号
   */
  matchQuestionNumber(line) {
    for (const pattern of this.questionPatterns.questionNumber) {
      const match = line.match(pattern);
      if (match) {
        return {
          number: parseInt(match[1]),
          match: match[0]
        };
      }
    }
    return null;
  }

  /**
   * 匹配选项
   */
  matchOption(line) {
    for (const pattern of this.questionPatterns.options) {
      const match = line.match(pattern);
      if (match) {
        return {
          key: match[0].charAt(0),
          content: match[1]
        };
      }
    }
    return null;
  }

  /**
   * 匹配答案
   */
  matchAnswer(line) {
    for (const pattern of this.questionPatterns.answer) {
      const match = line.match(pattern);
      if (match) {
        return {
          answer: match[1] || match[0]
        };
      }
    }
    return null;
  }

  /**
   * 匹配解析
   */
  matchExplanation(line) {
    for (const pattern of this.questionPatterns.explanation) {
      const match = line.match(pattern);
      if (match) {
        let explanation = match[1] || ''; // 如果解析内容为空，返回空字符串
        
        // 去掉解析内容开头的冒号
        explanation = explanation.replace(/^[：:]\s*/, '').trim();
        
        return {
          explanation: explanation
        };
      }
    }
    
    // 检查是否是解析标记但没有内容
    if (/^解析[：:]?\s*$/i.test(line.trim())) {
      return {
        explanation: ''
      };
    }
    
    return null;
  }

  /**
   * 判断是否是特殊行（选项、答案、解析等）
   */
  isSpecialLine(line) {
    return this.matchOption(line) || 
           this.matchAnswer(line) || 
           this.matchExplanation(line) ||
           this.matchQuestionNumber(line);
  }

  /**
   * 完成题目构建
   */
  finalizeQuestion(question, options, images) {
    // 从题目内容中识别题目类型
    if (question.content.includes('[多选]')) {
      question.type = '多选题';
    } else if (question.content.includes('[单选]')) {
      question.type = '单选题';
    } else if (question.content.includes('[判断]')) {
      question.type = '判断题';
    } else if (question.content.includes('[填空]')) {
      question.type = '填空题';
    } else {
      // 根据选项数量推断题目类型
      if (options.length > 4) {
        question.type = '多选题'; // 多选题
      } else if (options.length === 2) {
        question.type = '判断题'; // 判断题
      } else {
        question.type = '单选题'; // 默认单选题
      }
    }
    
    // 设置选项
    question.options = options.map(opt => ({
      key: opt.key,
      content: opt.content
    }));
    
    // 设置图片
    question.images = images;
    
    // 验证题目完整性
    const validation = this.validateQuestion(question);
    question.isValid = validation.isValid;
    question.invalidReasons = validation.reasons;
    
    return question;
  }

  /**
   * 验证题目完整性
   */
  validateQuestion(question) {
    const reasons = [];
    
    // 检查题目内容
    if (!question.content) {
      reasons.push('缺少题目内容');
    } else if (question.content.length <= 10) {
      reasons.push('题目内容过短（少于10个字符）');
    }
    
    // 检查选项
    if (!question.options || question.options.length < 2) {
      reasons.push('选项数量不足（至少需要2个选项）');
    }
    
    // 检查答案
    if (!question.answer || question.answer.length === 0) {
      reasons.push('缺少答案');
    }
    
    // 检查题目类型
    if (!question.type) {
      reasons.push('缺少题目类型');
    }
    
    const isValid = reasons.length === 0;
    
    return {
      isValid: isValid,
      reasons: reasons
    };
  }

  /**
   * 将图片分配给题目
   */
  async assignImagesToQuestions(questions, images, filePath) {
    if (!images || images.length === 0) {
      return;
    }
    
    // 对于Excel文件，尝试根据图片名称或位置来分配
    if (filePath && (filePath.endsWith('.xlsx') || filePath.endsWith('.xls'))) {
      await this.assignExcelImagesToQuestions(questions, images);
    } else {
      // 简单的图片分配策略：按顺序分配
      for (let i = 0; i < images.length && i < questions.length; i++) {
        questions[i].images.push(images[i]);
      }
    }
  }

  /**
   * 为Excel题目分配图片
   */
  async assignExcelImagesToQuestions(questions, images) {
    // 将图片复制到服务器静态文件目录
    const staticDir = path.join(__dirname, '../public/uploads/images');
    if (!fs.existsSync(staticDir)) {
      fs.mkdirSync(staticDir, { recursive: true });
    }
    
    for (let i = 0; i < images.length; i++) {
      const image = images[i];
      const imageName = `question_image_${Date.now()}_${i}.${path.extname(image.name).slice(1)}`;
      const targetPath = path.join(staticDir, imageName);
      
      try {
        // 复制图片到静态目录
        fs.copyFileSync(image.path, targetPath);
        
        // 为每个题目添加图片（可以根据需要调整分配策略）
        if (questions.length > 0) {
          const questionIndex = i % questions.length;
          questions[questionIndex].images.push({
            name: imageName,
            path: `images/${imageName}`,
            originalName: image.name
          });
          
          console.log(`图片 ${image.name} 分配给题目 ${questionIndex + 1}`);
        } else {
          console.log(`图片 ${image.name} 无法分配，没有题目`);
        }
      } catch (error) {
        console.error(`复制图片失败: ${image.name}`, error);
      }
    }
  }

  /**
   * 处理图片：压缩、格式转换等
   */
  async processImage(imagePath, outputPath) {
    try {
      await sharp(imagePath)
        .resize(800, 600, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 80 })
        .toFile(outputPath);
      
      return outputPath;
    } catch (error) {
      console.error('图片处理失败:', error);
      return imagePath;
    }
  }
}

module.exports = DocumentParser;
