const { QuestionBank, Subject, Question } = require('../models/associations')

// 获取题库列表
const getQuestionBanks = async (ctx) => {
  try {
    const { page = 1, limit = 10, keyword = '' } = ctx.query
    const offset = (page - 1) * limit

    const whereClause = {}
    if (keyword) {
      whereClause.name = {
        [require('sequelize').Op.like]: `%${keyword}%`
      }
    }

    const { count, rows } = await QuestionBank.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: Subject,
          as: 'subjects',
          attributes: ['id', 'name'],
          include: [
            {
              model: Question,
              as: 'questions',
              attributes: ['id'],
              where: { status: 'active' },
              required: false
            }
          ]
        }
      ],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['createdAt', 'DESC']]
    })

    // 计算每个题库的科目数量和题目数量
    const questionBanks = rows.map(bank => {
      const subjectCount = bank.subjects.length
      const questionCount = bank.subjects.reduce((total, subject) => {
        return total + subject.questions.length
      }, 0)

      return {
        id: bank.id,
        name: bank.name,
        description: bank.description,
        status: bank.status,
        subjectCount,
        questionCount,
        createdAt: bank.createdAt,
        updatedAt: bank.updatedAt
      }
    })

    ctx.body = {
      code: 200,
      message: '获取题库列表成功',
      data: {
        list: questionBanks,
        total: count,
        page: parseInt(page),
        limit: parseInt(limit)
      }
    }
  } catch (error) {
    console.error('获取题库列表失败:', error)
    ctx.body = {
      code: 500,
      message: '获取题库列表失败: ' + error.message
    }
  }
}

// 创建题库
const createQuestionBank = async (ctx) => {
  try {
    const userId = ctx.state.user?.id
    if (!userId) {
      ctx.body = { code: 401, message: '未提供认证token' }
      return
    }

    const { name, description } = ctx.request.body

    if (!name) {
      ctx.body = { code: 400, message: '题库名称不能为空' }
      return
    }

    // 检查题库名称是否已存在
    const existingBank = await QuestionBank.findOne({
      where: { name }
    })

    if (existingBank) {
      ctx.body = { code: 400, message: '题库名称已存在' }
      return
    }

    const questionBank = await QuestionBank.create({
      name,
      description: description || '',
      createdBy: userId
    })

    ctx.body = {
      code: 200,
      message: '创建题库成功',
      data: questionBank
    }
  } catch (error) {
    console.error('创建题库失败:', error)
    ctx.body = {
      code: 500,
      message: '创建题库失败: ' + error.message
    }
  }
}

// 更新题库
const updateQuestionBank = async (ctx) => {
  try {
    const userId = ctx.state.user?.id
    if (!userId) {
      ctx.body = { code: 401, message: '未提供认证token' }
      return
    }

    const { id } = ctx.params
    const { name, description, status } = ctx.request.body

    const questionBank = await QuestionBank.findByPk(id)
    if (!questionBank) {
      ctx.body = { code: 404, message: '题库不存在' }
      return
    }

    // 检查权限（只有创建者可以修改）
    if (questionBank.createdBy !== userId) {
      ctx.body = { code: 403, message: '无权限修改此题库' }
      return
    }

    // 如果修改名称，检查是否重复
    if (name && name !== questionBank.name) {
      const existingBank = await QuestionBank.findOne({
        where: { name, id: { [require('sequelize').Op.ne]: id } }
      })

      if (existingBank) {
        ctx.body = { code: 400, message: '题库名称已存在' }
        return
      }
    }

    await questionBank.update({
      name: name || questionBank.name,
      description: description !== undefined ? description : questionBank.description,
      status: status || questionBank.status
    })

    ctx.body = {
      code: 200,
      message: '更新题库成功',
      data: questionBank
    }
  } catch (error) {
    console.error('更新题库失败:', error)
    ctx.body = {
      code: 500,
      message: '更新题库失败: ' + error.message
    }
  }
}

// 删除题库
const deleteQuestionBank = async (ctx) => {
  try {
    const userId = ctx.state.user?.id
    if (!userId) {
      ctx.body = { code: 401, message: '未提供认证token' }
      return
    }

    const { id } = ctx.params

    const questionBank = await QuestionBank.findByPk(id)
    if (!questionBank) {
      ctx.body = { code: 404, message: '题库不存在' }
      return
    }

    // 检查权限（只有创建者可以删除）
    if (questionBank.createdBy !== userId) {
      ctx.body = { code: 403, message: '无权限删除此题库' }
      return
    }

    // 统计要删除的题目数量
    const questionCount = await Question.count({
      where: { questionBankId: id }
    })

    // 删除题库（级联删除科目和题目）
    await questionBank.destroy()

    ctx.body = {
      code: 200,
      message: '删除题库成功',
      data: { deletedCount: questionCount }
    }
  } catch (error) {
    console.error('删除题库失败:', error)
    ctx.body = {
      code: 500,
      message: '删除题库失败: ' + error.message
    }
  }
}

// 获取题库详情
const getQuestionBankDetail = async (ctx) => {
  try {
    const { id } = ctx.params

    const questionBank = await QuestionBank.findByPk(id, {
      include: [
        {
          model: Subject,
          as: 'subjects',
          include: [
            {
              model: Question,
              as: 'questions',
              attributes: ['id'],
              where: { status: 'active' },
              required: false
            }
          ]
        }
      ]
    })

    if (!questionBank) {
      ctx.body = { code: 404, message: '题库不存在' }
      return
    }

    // 计算统计信息
    const subjectCount = questionBank.subjects.length
    const questionCount = questionBank.subjects.reduce((total, subject) => {
      return total + subject.questions.length
    }, 0)

    const result = {
      id: questionBank.id,
      name: questionBank.name,
      description: questionBank.description,
      status: questionBank.status,
      subjectCount,
      questionCount,
      subjects: questionBank.subjects.map(subject => ({
        id: subject.id,
        name: subject.name,
        description: subject.description,
        questionCount: subject.questions.length,
        createdAt: subject.createdAt
      })),
      createdAt: questionBank.createdAt,
      updatedAt: questionBank.updatedAt
    }

    ctx.body = {
      code: 200,
      message: '获取题库详情成功',
      data: result
    }
  } catch (error) {
    console.error('获取题库详情失败:', error)
    ctx.body = {
      code: 500,
      message: '获取题库详情失败: ' + error.message
    }
  }
}

// 导出题库
const exportQuestionBank = async (ctx) => {
  try {
    const { id, format = 'excel' } = ctx.query

    if (!id) {
      ctx.body = { code: 400, message: '请提供题库ID' }
      return
    }

    // 获取题库信息
    const questionBank = await QuestionBank.findByPk(id, {
      include: [
        {
          model: Subject,
          as: 'subjects',
          include: [
            {
              model: Question,
              as: 'questions',
              where: { status: 'active' },
              required: false
            }
          ]
        }
      ]
    })

    if (!questionBank) {
      ctx.body = { code: 404, message: '题库不存在' }
      return
    }

    // 准备导出数据
    const exportData = {
      questionBank: {
        id: questionBank.id,
        name: questionBank.name,
        description: questionBank.description,
        createdAt: questionBank.createdAt
      },
      subjects: []
    }

    // 处理科目和题目数据
    for (const subject of questionBank.subjects) {
      const subjectData = {
        id: subject.id,
        name: subject.name,
        description: subject.description,
        questions: []
      }

      for (const question of subject.questions) {
        let options = []
        try {
          if (question.options) {
            options = typeof question.options === 'string' 
              ? JSON.parse(question.options) 
              : question.options
          }
        } catch (error) {
          console.error('解析选项失败:', error)
          options = []
        }

        let images = []
        try {
          if (question.images) {
            images = typeof question.images === 'string' 
              ? JSON.parse(question.images) 
              : question.images
          }
        } catch (error) {
          console.error('解析图片失败:', error)
          images = []
        }

        const questionData = {
          id: question.id,
          chapter: question.chapter || '',
          type: question.type,
          difficulty: question.difficulty,
          content: question.content,
          options: options,
          answer: question.answer,
          analysis: question.analysis || '',
          images: images,
          createdAt: question.createdAt
        }

        subjectData.questions.push(questionData)
      }

      exportData.subjects.push(subjectData)
    }

    // 根据格式返回数据
    if (format === 'json') {
      ctx.set('Content-Type', 'application/json')
      ctx.set('Content-Disposition', `attachment; filename="${questionBank.name}_题库导出.json"`)
      ctx.body = JSON.stringify(exportData, null, 2)
    } else if (format === 'excel') {
      // 使用xlsx库生成Excel文件
      const XLSX = require('xlsx')
      
      // 创建工作簿
      const workbook = XLSX.utils.book_new()
      
      // 如果没有科目，创建一个空的工作表
      if (exportData.subjects.length === 0) {
        const emptyData = [['暂无题目数据']]
        const emptyWorksheet = XLSX.utils.aoa_to_sheet(emptyData)
        XLSX.utils.book_append_sheet(workbook, emptyWorksheet, '题库数据')
      } else {
        // 为每个科目创建工作表
        for (const subject of exportData.subjects) {
          const worksheetData = []
          
          // 添加表头
          worksheetData.push([
            '题目ID', '章节', '题目类型', '难度', '题目内容', 
            '选项A', '选项B', '选项C', '选项D', '选项E', '选项F',
            '正确答案', '解析', '图片路径', '创建时间'
          ])
          
          // 添加题目数据
          if (subject.questions && subject.questions.length > 0) {
            for (const question of subject.questions) {
              const row = [
                question.id || '',
                question.chapter || '',
                question.type || '',
                question.difficulty || '',
                question.content || '',
                (question.options && question.options[0]) || '',
                (question.options && question.options[1]) || '',
                (question.options && question.options[2]) || '',
                (question.options && question.options[3]) || '',
                (question.options && question.options[4]) || '',
                (question.options && question.options[5]) || '',
                question.answer || '',
                question.analysis || '',
                (question.images && question.images.length > 0) 
                  ? question.images.map(img => img.path || '').join('; ') 
                  : '',
                question.createdAt ? new Date(question.createdAt).toLocaleString('zh-CN') : ''
              ]
              worksheetData.push(row)
            }
          } else {
            // 如果没有题目，添加提示行
            worksheetData.push(['该科目暂无题目'])
          }
          
          // 创建工作表
          const worksheet = XLSX.utils.aoa_to_sheet(worksheetData)
          
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
          ]
          worksheet['!cols'] = colWidths
          
          // 添加工作表到工作簿，限制工作表名称长度并确保名称合法
          let sheetName = (subject.name || `科目${subject.id}`).substring(0, 31)
          // 移除Excel工作表名称中不允许的字符
          sheetName = sheetName.replace(/[\\\/\?\*\[\]]/g, '_')
          XLSX.utils.book_append_sheet(workbook, worksheet, sheetName)
        }
      }
      
      // 生成Excel文件buffer，使用最兼容的选项
      const excelBuffer = XLSX.write(workbook, { 
        type: 'buffer', 
        bookType: 'xlsx',
        compression: false,
        Props: {
          Title: `${questionBank.name}_题库导出`,
          Subject: '题库数据导出',
          Author: '系统管理员',
          CreatedDate: new Date()
        }
      })
      
      // 确保buffer不为空
      if (!excelBuffer || excelBuffer.length === 0) {
        throw new Error('Excel文件生成失败')
      }
      
      // 验证文件头
      const fileHeader = excelBuffer.toString('hex', 0, 4)
      if (fileHeader !== '504b0304') {
        console.warn('警告: 生成的Excel文件头不正确:', fileHeader)
      }
      
      // 设置响应头
      ctx.set('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      ctx.set('Content-Disposition', `attachment; filename="${questionBank.name}_题库导出.xlsx"`)
      ctx.set('Cache-Control', 'no-cache')
      ctx.set('Content-Length', excelBuffer.length.toString())
      
      // 直接返回buffer
      ctx.body = excelBuffer
    } else {
      ctx.body = { code: 400, message: '不支持的导出格式' }
    }

  } catch (error) {
    console.error('导出题库失败:', error)
    ctx.body = {
      code: 500,
      message: '导出题库失败: ' + error.message
    }
  }
}

module.exports = {
  getQuestionBanks,
  createQuestionBank,
  updateQuestionBank,
  deleteQuestionBank,
  getQuestionBankDetail,
  exportQuestionBank
}
