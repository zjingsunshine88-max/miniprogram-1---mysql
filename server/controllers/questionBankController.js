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

module.exports = {
  getQuestionBanks,
  createQuestionBank,
  updateQuestionBank,
  deleteQuestionBank,
  getQuestionBankDetail
}
