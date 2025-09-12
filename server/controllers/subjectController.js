const { QuestionBank, Subject, Question } = require('../models/associations')

// 获取科目列表
const getSubjects = async (ctx) => {
  try {
    const { page = 1, limit = 10, keyword = '', questionBankId } = ctx.query
    const offset = (page - 1) * limit

    const whereClause = {}
    if (keyword) {
      whereClause.name = {
        [require('sequelize').Op.like]: `%${keyword}%`
      }
    }
    if (questionBankId) {
      whereClause.questionBankId = questionBankId
    }

    const { count, rows } = await Subject.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: QuestionBank,
          as: 'questionBank',
          attributes: ['id', 'name']
        },
        {
          model: Question,
          as: 'questions',
          attributes: ['id'],
          where: { status: 'active' },
          required: false
        }
      ],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['createdAt', 'DESC']]
    })

    // 计算每个科目的题目数量
    const subjects = rows.map(subject => ({
      id: subject.id,
      name: subject.name,
      description: subject.description,
      status: subject.status,
      questionCount: subject.questions.length,
      questionBank: {
        id: subject.questionBank.id,
        name: subject.questionBank.name
      },
      createdAt: subject.createdAt,
      updatedAt: subject.updatedAt
    }))

    ctx.body = {
      code: 200,
      message: '获取科目列表成功',
      data: {
        list: subjects,
        total: count,
        page: parseInt(page),
        limit: parseInt(limit)
      }
    }
  } catch (error) {
    console.error('获取科目列表失败:', error)
    ctx.body = {
      code: 500,
      message: '获取科目列表失败: ' + error.message
    }
  }
}

// 创建科目
const createSubject = async (ctx) => {
  try {
    const userId = ctx.state.user?.id
    if (!userId) {
      ctx.body = { code: 401, message: '未提供认证token' }
      return
    }

    const { name, description, questionBankId } = ctx.request.body

    if (!name) {
      ctx.body = { code: 400, message: '科目名称不能为空' }
      return
    }

    if (!questionBankId) {
      ctx.body = { code: 400, message: '题库ID不能为空' }
      return
    }

    // 检查题库是否存在
    const questionBank = await QuestionBank.findByPk(questionBankId)
    if (!questionBank) {
      ctx.body = { code: 404, message: '题库不存在' }
      return
    }

    // 检查科目名称在同一题库中是否已存在
    const existingSubject = await Subject.findOne({
      where: { name, questionBankId }
    })

    if (existingSubject) {
      ctx.body = { code: 400, message: '该题库中已存在同名科目' }
      return
    }

    const subject = await Subject.create({
      name,
      description: description || '',
      questionBankId,
      createdBy: userId
    })

    ctx.body = {
      code: 200,
      message: '创建科目成功',
      data: subject
    }
  } catch (error) {
    console.error('创建科目失败:', error)
    ctx.body = {
      code: 500,
      message: '创建科目失败: ' + error.message
    }
  }
}

// 更新科目
const updateSubject = async (ctx) => {
  try {
    const userId = ctx.state.user?.id
    if (!userId) {
      ctx.body = { code: 401, message: '未提供认证token' }
      return
    }

    const { id } = ctx.params
    const { name, description, status } = ctx.request.body

    const subject = await Subject.findByPk(id, {
      include: [{ model: QuestionBank, as: 'questionBank' }]
    })

    if (!subject) {
      ctx.body = { code: 404, message: '科目不存在' }
      return
    }

    // 检查权限（只有创建者可以修改）
    if (subject.createdBy !== userId) {
      ctx.body = { code: 403, message: '无权限修改此科目' }
      return
    }

    // 如果修改名称，检查是否重复
    if (name && name !== subject.name) {
      const existingSubject = await Subject.findOne({
        where: { 
          name, 
          questionBankId: subject.questionBankId,
          id: { [require('sequelize').Op.ne]: id }
        }
      })

      if (existingSubject) {
        ctx.body = { code: 400, message: '该题库中已存在同名科目' }
        return
      }
    }

    await subject.update({
      name: name || subject.name,
      description: description !== undefined ? description : subject.description,
      status: status || subject.status
    })

    ctx.body = {
      code: 200,
      message: '更新科目成功',
      data: subject
    }
  } catch (error) {
    console.error('更新科目失败:', error)
    ctx.body = {
      code: 500,
      message: '更新科目失败: ' + error.message
    }
  }
}

// 删除科目
const deleteSubject = async (ctx) => {
  try {
    const userId = ctx.state.user?.id
    if (!userId) {
      ctx.body = { code: 401, message: '未提供认证token' }
      return
    }

    const { id } = ctx.params

    const subject = await Subject.findByPk(id)
    if (!subject) {
      ctx.body = { code: 404, message: '科目不存在' }
      return
    }

    // 检查权限（只有创建者可以删除）
    if (subject.createdBy !== userId) {
      ctx.body = { code: 403, message: '无权限删除此科目' }
      return
    }

    // 统计要删除的题目数量
    const questionCount = await Question.count({
      where: { subjectId: id }
    })

    // 删除科目（级联删除题目）
    await subject.destroy()

    ctx.body = {
      code: 200,
      message: '删除科目成功',
      data: { deletedCount: questionCount }
    }
  } catch (error) {
    console.error('删除科目失败:', error)
    ctx.body = {
      code: 500,
      message: '删除科目失败: ' + error.message
    }
  }
}

// 获取科目详情
const getSubjectDetail = async (ctx) => {
  try {
    const { id } = ctx.params

    const subject = await Subject.findByPk(id, {
      include: [
        {
          model: QuestionBank,
          as: 'questionBank',
          attributes: ['id', 'name', 'description']
        },
        {
          model: Question,
          as: 'questions',
          where: { status: 'active' },
          required: false,
          attributes: ['id', 'type', 'difficulty', 'content']
        }
      ]
    })

    if (!subject) {
      ctx.body = { code: 404, message: '科目不存在' }
      return
    }

    // 按类型和难度统计题目
    const questionStats = {
      total: subject.questions.length,
      byType: {},
      byDifficulty: {}
    }

    subject.questions.forEach(question => {
      // 按类型统计
      questionStats.byType[question.type] = (questionStats.byType[question.type] || 0) + 1
      // 按难度统计
      questionStats.byDifficulty[question.difficulty] = (questionStats.byDifficulty[question.difficulty] || 0) + 1
    })

    const result = {
      id: subject.id,
      name: subject.name,
      description: subject.description,
      status: subject.status,
      questionBank: subject.questionBank,
      questionStats,
      createdAt: subject.createdAt,
      updatedAt: subject.updatedAt
    }

    ctx.body = {
      code: 200,
      message: '获取科目详情成功',
      data: result
    }
  } catch (error) {
    console.error('获取科目详情失败:', error)
    ctx.body = {
      code: 500,
      message: '获取科目详情失败: ' + error.message
    }
  }
}

module.exports = {
  getSubjects,
  createSubject,
  updateSubject,
  deleteSubject,
  getSubjectDetail
}
