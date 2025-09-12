const { Question, UserRecord, Favorite, User, ErrorRecord } = require('../models');
const { QuestionBank, Subject } = require('../models/associations');
const { Op } = require('sequelize');
const { sequelize } = require('../config/database');

// 获取题目列表
const getQuestions = async (ctx) => {
  try {
    const {
      page = 1,
      limit,
      questionBankId,
      subjectId,
      chapter,
      type,
      difficulty,
      keyword
    } = ctx.query;

    const where = { status: 'active' };
    
    if (questionBankId) where.questionBankId = questionBankId;
    if (subjectId) where.subjectId = subjectId;
    if (chapter) where.chapter = chapter;
    if (type) where.type = type;
    if (difficulty) where.difficulty = difficulty;
    if (keyword) {
      where.content = {
        [Op.like]: `%${keyword}%`
      };
    }

    // 获取总数
    const total = await Question.count({ where });

    let result;
    
    // 如果没有指定limit，则获取所有题目
    if (!limit) {
      result = await Question.findAll({
        where,
        include: [
          {
            model: QuestionBank,
            as: 'questionBank',
            attributes: ['id', 'name']
          },
          {
            model: Subject,
            as: 'subject',
            attributes: ['id', 'name']
          }
        ],
        order: [['createdAt', 'DESC']]
      });
    } else {
      // 如果指定了limit，则进行分页查询
      result = await Question.findAll({
        where,
        include: [
          {
            model: QuestionBank,
            as: 'questionBank',
            attributes: ['id', 'name']
          },
          {
            model: Subject,
            as: 'subject',
            attributes: ['id', 'name']
          }
        ],
        order: [['createdAt', 'DESC']],
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit)
      });
    }

    // 处理返回数据，添加前端需要的字段
    const processedResult = result.map(question => {
      const questionData = question.toJSON();
      // 添加subject字段（从关联的subject获取）
      if (questionData.subject) {
        questionData.subject = questionData.subject.name;
      }
      // 添加questionBank字段（从关联的questionBank获取）
      if (questionData.questionBank) {
        questionData.questionBank = questionData.questionBank.name;
      }
      return questionData;
    });

    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        list: processedResult,
        total,
        page: parseInt(page),
        limit: limit || total,
        pages: limit ? Math.ceil(total / parseInt(limit)) : 1
      }
    };
  } catch (error) {
    console.error('获取题目列表错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取题目列表失败',
      error: error.message
    };
  }
};

// 获取题目详情
const getQuestionDetail = async (ctx) => {
  try {
    const { id } = ctx.params;

    // 确保id是整数
    const questionIdInt = parseInt(id);
    if (isNaN(questionIdInt)) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '题目ID格式不正确'
      };
      return;
    }

    const question = await Question.findByPk(questionIdInt);

    if (!question) {
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '题目不存在'
      };
      return;
    }

    ctx.body = {
      code: 200,
      message: '获取成功',
      data: question
    };
  } catch (error) {
    console.error('获取题目详情错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取题目详情失败',
      error: error.message
    };
  }
};

// 通过ID获取题目 (支持练习模式)
const getQuestionById = async (ctx) => {
  try {
    // 支持两种参数名：questionId 和 id
    const questionId = ctx.query.questionId || ctx.query.id;
    
    console.log('=== 获取题目详情 ===');
    console.log('原始questionId:', questionId);
    console.log('questionId类型:', typeof questionId);
    console.log('query参数:', ctx.query);
    
    // 确保questionId是整数
    const questionIdInt = parseInt(questionId);
    console.log('转换后的questionIdInt:', questionIdInt);
    console.log('是否为NaN:', isNaN(questionIdInt));
    
    if (isNaN(questionIdInt)) {
      console.log('题目ID格式不正确，无法转换为整数');
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '题目ID格式不正确'
      };
      return;
    }
    
    const question = await Question.findByPk(questionIdInt);
    
    if (!question) {
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '题目不存在'
      };
      return;
    }
    
    // 转换数据格式以兼容答题页面
    const formattedQuestion = {
      ...question.toJSON(),
      _id: question.id,
      id: question.id
    };
    
    // 如果options是数组格式，转换为选项文本
    if (Array.isArray(question.options)) {
      question.options.forEach((option, index) => {
        const key = String.fromCharCode(65 + index); // A, B, C, D
        formattedQuestion[`option${key}`] = option.content || option.text || option;
      });
    }
    
    console.log('获取到的题目:', formattedQuestion);
    
    ctx.body = {
      code: 200,
      message: '获取成功',
      data: [formattedQuestion] // 返回数组格式以兼容答题页面
    };
  } catch (error) {
    console.error('获取题目失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取题目失败',
      error: error.message
    };
  }
};

// 随机获取题目
const getRandomQuestions = async (ctx) => {
  try {
    const {
      limit = 10,
      subject,
      chapter,
      type,
      difficulty
    } = ctx.query;

    const where = { status: 'active' };
    
    if (subject) where.subject = subject;
    if (chapter) where.chapter = chapter;
    if (type) where.type = type;
    if (difficulty) where.difficulty = difficulty;

    // 获取总数
    const total = await Question.count({ where });
    
    if (total === 0) {
      ctx.body = {
        code: 200,
        message: '暂无题目',
        data: {
          list: [],
          total: 0
        }
      };
      return;
    }
    
    // 随机获取题目
    const randomSkip = Math.floor(Math.random() * Math.max(0, total - parseInt(limit)));
    const questions = await Question.findAll({
      where,
      order: [['id', 'ASC']],
      limit: parseInt(limit),
      offset: randomSkip
    });

    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        list: questions,
        total: questions.length
      }
    };
  } catch (error) {
    console.error('随机获取题目错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取随机题目失败',
      error: error.message
    };
  }
};

// 提交答题记录
const submitAnswer = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { questionId, questionContent, userAnswer, correctAnswer, isCorrect, subject, chapter, timestamp } = ctx.request.body;
    
    console.log('收到提交答题记录请求，用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }

    const record = {
      userId,
      questionId: parseInt(questionId), // 确保是整数
      questionContent,
      userAnswer,
      correctAnswer,
      isCorrect,
      subject,
      chapter,
      timestamp: new Date(timestamp)
    };
    
    const result = await UserRecord.create(record);
    
    console.log('答题记录保存成功，记录ID:', result.id);
    
    ctx.body = {
      code: 200,
      message: '答题记录保存成功',
      data: {
        id: result.id
      }
    };
  } catch (error) {
    console.error('保存答题记录失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '保存答题记录失败',
      error: error.message
    };
  }
};

// 获取用户答题记录
const getUserRecords = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { page = 1, limit = 20 } = ctx.query;
    
    console.log('收到获取用户答题记录请求，用户ID:', userId);
    
    // 如果用户未登录，返回空数据
    if (!userId) {
      console.log('用户未登录，返回空数据');
      ctx.body = {
        code: 200,
        message: '获取成功',
        data: {
          list: [],
          total: 0,
          page: parseInt(page),
          limit: parseInt(limit)
        }
      };
      return;
    }
    
    const result = await UserRecord.findAll({
      where: {
        userId: userId // 只查询当前用户的记录
      },
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit)
    });
    
    console.log('获取用户答题记录成功，数量:', result.length);
    
    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        list: result,
        total: result.length,
        page: parseInt(page),
        limit: parseInt(limit)
      }
    };
  } catch (error) {
    console.error('获取答题记录失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取答题记录失败',
      error: error.message
    };
  }
};

// 获取错题列表
const getErrorQuestions = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { page = 1, limit = 20 } = ctx.query;
    
    console.log('收到获取错题列表请求，用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    const result = await ErrorRecord.findAll({
      where: {
        userId: userId // 只查询当前用户的错题
      },
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit)
    });
    
    console.log('获取用户错题列表成功，数量:', result.length);
    
    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        list: result,
        total: result.length,
        page: parseInt(page),
        limit: parseInt(limit)
      }
    };
  } catch (error) {
    console.error('获取错题列表失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取错题列表失败',
      error: error.message
    };
  }
};

// 批量导入题目
const importQuestions = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { questions } = ctx.request.body;
    
    console.log('批量导入题目，用户ID:', userId, '题目数量:', questions.length);
    
    // 检查必要参数
    if (!userId) {
      console.error('用户ID为空');
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户ID不能为空'
      };
      return;
    }
    
    if (!questions || !Array.isArray(questions) || questions.length === 0) {
      console.error('题目数据无效');
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '题目数据无效'
      };
      return;
    }
    
    // 验证管理员权限
    console.log('检查管理员权限，用户ID:', userId);
    const user = await User.findByPk(userId);
    
    console.log('用户查询结果:', user);
    
    if (!user) {
      console.log('用户不存在，用户ID:', userId);
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '用户不存在'
      };
      return;
    }
    
    const isAdmin = user.isAdmin === true;
    
    if (!isAdmin) {
      console.log('用户不是管理员，用户ID:', userId);
      ctx.status = 403;
      ctx.body = {
        code: 403,
        message: '权限不足，仅限管理员操作'
      };
      return;
    }
    
    console.log('管理员权限验证通过，用户:', {
      userId: user.id,
      nickName: user.nickName,
      phoneNumber: user.phoneNumber,
      isAdmin: user.isAdmin
    });
    
    // 批量添加题目
    const addPromises = questions.map(question => {
      // 构建选项数组
      let options = [];
      
      // 优先使用传递的options字段（JSON字符串）
      if (question.options) {
        try {
          if (typeof question.options === 'string') {
            options = JSON.parse(question.options);
          } else if (Array.isArray(question.options)) {
            options = question.options;
          }
        } catch (error) {
          console.error('解析options字段失败:', error);
          options = [];
        }
      }
      
      // 如果没有options字段，则使用旧的optionA、optionB等字段
      if (options.length === 0) {
        if (question.optionA) options.push({ key: 'A', content: question.optionA });
        if (question.optionB) options.push({ key: 'B', content: question.optionB });
        if (question.optionC) options.push({ key: 'C', content: question.optionC });
        if (question.optionD) options.push({ key: 'D', content: question.optionD });
      }
      
      // 处理图片字段
      let images = null;
      if (question.images) {
        try {
          if (typeof question.images === 'string') {
            images = question.images; // 已经是JSON字符串
          } else if (Array.isArray(question.images)) {
            images = JSON.stringify(question.images);
          }
        } catch (error) {
          console.error('处理images字段失败:', error);
          images = null;
        }
      }
      
      // 处理判断题答案格式
      let normalizedAnswer = question.answer;
      if (question.type === '判断题') {
        if (['对', 'T', 'Y'].includes(question.answer)) {
          normalizedAnswer = '正确';
        } else if (['错', 'F', 'N'].includes(question.answer)) {
          normalizedAnswer = '错误';
        }
      }
      
      console.log('创建题目数据:', {
        type: question.type,
        content: question.content,
        options: options,
        images: images,
        answer: normalizedAnswer
      });
      
      return Question.create({
        type: question.type || '单选题',
        content: question.content,
        options: options.length > 0 ? JSON.stringify(options) : null,
        answer: normalizedAnswer,
        analysis: question.analysis || '',
        images: images,
        difficulty: question.difficulty || '中等',
        questionBankId: question.questionBankId,
        subjectId: question.subjectId,
        chapter: question.chapter || '',
        createBy: userId
      });
    });
    
    const results = await Promise.all(addPromises);
    
    console.log('题目导入成功，导入数量:', results.length);
    
    ctx.body = {
      code: 200,
      message: `成功导入 ${results.length} 道题目`,
      data: {
        importedCount: results.length,
        totalCount: questions.length
      }
    };
  } catch (error) {
    console.error('批量导入题目失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '导入题目失败',
      error: error.message
    };
  }
};

// 获取题目统计信息
const getQuestionStats = async (ctx) => {
  try {
    // 获取题目总数
    const total = await Question.count({
      where: { status: 'active' }
    });
    
    // 按科目统计 - 使用关联查询获取科目名称
    const bySubject = await Question.findAll({
      attributes: [
        'subjectId',
        [sequelize.fn('COUNT', sequelize.col('Question.id')), 'count']
      ],
      include: [{
        model: Subject,
        as: 'subject',
        attributes: ['name'],
        required: true
      }],
      where: { status: 'active' },
      group: ['subjectId', 'subject.id'],
      raw: false
    });
    
    // 格式化科目统计数据
    const formattedBySubject = bySubject.map(item => ({
      subjectId: item.subjectId,
      subjectName: item.subject ? item.subject.name : '未知科目',
      count: parseInt(item.dataValues.count)
    }));
    
    // 按类型统计
    const byType = await Question.findAll({
      attributes: [
        'type',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { status: 'active' },
      group: ['type'],
      raw: true
    });
    
    // 按难度统计
    const byDifficulty = await Question.findAll({
      attributes: [
        'difficulty',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { status: 'active' },
      group: ['difficulty'],
      raw: true
    });
    
    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        total,
        bySubject: formattedBySubject,
        byType: byType.map(item => ({
          type: item.type,
          count: parseInt(item.count)
        })),
        byDifficulty: byDifficulty.map(item => ({
          difficulty: item.difficulty,
          count: parseInt(item.count)
        }))
      }
    };
  } catch (error) {
    console.error('获取题目统计错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取统计信息失败',
      error: error.message
    };
  }
};

// 删除单个题目
const deleteQuestion = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { id } = ctx.params;
    
    console.log('收到删除题目请求，题目ID:', id, '用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    // 验证管理员权限
    const user = await User.findByPk(userId);
    
    if (!user) {
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '用户不存在'
      };
      return;
    }
    
    const isAdmin = user.isAdmin === true;
    
    if (!isAdmin) {
      ctx.status = 403;
      ctx.body = {
        code: 403,
        message: '权限不足，只有管理员可以删除题目'
      };
      return;
    }
    
    // 确保id是整数
    const questionIdInt = parseInt(id);
    if (isNaN(questionIdInt)) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '题目ID格式不正确'
      };
      return;
    }
    
    // 删除题目
    const deletedCount = await Question.destroy({
      where: {
        id: questionIdInt
      }
    });
    
    if (deletedCount === 0) {
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '题目不存在'
      };
      return;
    }
    
    console.log('删除题目成功，题目ID:', questionIdInt);
    
    ctx.body = {
      code: 200,
      message: '删除题目成功',
      data: {
        deletedCount
      }
    };
  } catch (error) {
    console.error('删除题目失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '删除题目失败',
      error: error.message
    };
  }
};

// 删除题库
const deleteQuestionBank = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { subject } = ctx.request.body;
    
    console.log('收到删除题库请求，科目:', subject, '用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    // 验证管理员权限
    const user = await User.findByPk(userId);
    
    if (!user) {
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '用户不存在'
      };
      return;
    }
    
    const isAdmin = user.isAdmin === true;
    
    if (!isAdmin) {
      ctx.status = 403;
      ctx.body = {
        code: 403,
        message: '权限不足，只有管理员可以删除题库'
      };
      return;
    }
    
    // 删除该科目的所有题目
    const deletedCount = await Question.destroy({
      where: {
        subject: subject
      }
    });
    
    console.log('删除题库成功，删除题目数量:', deletedCount);
    
    ctx.body = {
      code: 200,
      message: '删除题库成功',
      data: {
        deletedCount
      }
    };
  } catch (error) {
    console.error('删除题库失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '删除题库失败',
      error: error.message
    };
  }
};

// 添加到收藏
const addToFavorites = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { questionId, questionContent, subject, chapter, timestamp } = ctx.request.body;
    
    console.log('收到收藏请求，用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    // 检查是否已经收藏（同一用户的同一题目）
    const existing = await Favorite.findOne({
      where: {
        questionId: questionId,
        userId: userId // 只检查当前用户的收藏
      }
    });
    
    console.log('检查是否已收藏，结果:', existing);
    
    if (existing) {
      console.log('该题目已收藏，返回错误');
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '该题目已收藏'
      };
      return;
    }
    
    const favorite = {
      questionId: parseInt(questionId), // 确保是整数
      questionContent,
      subject,
      chapter,
      userId, // 添加用户ID
      timestamp: new Date(timestamp)
    };
    
    console.log('准备保存收藏记录:', favorite);
    
    const result = await Favorite.create(favorite);
    
    console.log('收藏保存成功，结果:', result);
    
    ctx.body = {
      code: 200,
      message: '收藏成功',
      data: {
        id: result.id
      }
    };
  } catch (error) {
    console.error('收藏保存失败，错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '收藏失败',
      error: error.message
    };
  }
};

// 获取收藏列表
const getFavorites = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { page = 1, limit = 20 } = ctx.query;
    
    console.log('收到获取收藏列表请求，用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    const result = await Favorite.findAll({
      where: {
        userId: userId // 只查询当前用户的收藏
      },
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit)
    });
    
    console.log('获取用户收藏列表成功，数量:', result.length);
    
    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        list: result,
        total: result.length,
        page: parseInt(page),
        limit: parseInt(limit)
      }
    };
  } catch (error) {
    console.error('获取收藏列表失败，错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取收藏列表失败',
      error: error.message
    };
  }
};

// 添加到错题本
const addToErrorBook = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { questionId, questionContent, userAnswer, correctAnswer, subject, chapter, timestamp } = ctx.request.body;
    
    console.log('收到添加错题请求，用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    // 检查是否已经在错题本中（同一用户的同一题目）
    const existing = await ErrorRecord.findOne({
      where: {
        questionId: questionId,
        userId: userId // 只检查当前用户的错题
      }
    });
    
    console.log('检查是否已在错题本中，结果:', existing);
    
    if (existing) {
      console.log('该题目已在错题本中，返回错误');
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '该题目已在错题本中'
      };
      return;
    }
    
    const errorRecord = {
      questionId: parseInt(questionId), // 确保是整数
      questionContent,
      userAnswer,
      correctAnswer,
      subject,
      chapter,
      userId, // 添加用户ID
      timestamp: new Date(timestamp)
    };
    
    console.log('准备保存错题记录:', errorRecord);
    
    const result = await ErrorRecord.create(errorRecord);
    
    console.log('错题保存成功，结果:', result);
    
    ctx.body = {
      code: 200,
      message: '添加到错题本成功',
      data: {
        id: result.id
      }
    };
  } catch (error) {
    console.error('错题保存失败，错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '添加到错题本失败',
      error: error.message
    };
  }
};

// 从收藏中移除
const removeFromFavorites = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { questionId } = ctx.request.body;
    
    console.log('收到移除收藏请求，用户ID:', userId, '题目ID:', questionId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    const removed = await Favorite.destroy({
      where: {
        questionId: questionId,
        userId: userId // 只移除当前用户的收藏
      }
    });
    
    console.log('移除收藏成功，结果:', removed);
    
    ctx.body = {
      code: 200,
      message: '移除收藏成功',
      data: {
        removed
      }
    };
  } catch (error) {
    console.error('移除收藏失败，错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '移除收藏失败',
      error: error.message
    };
  }
};

// 从错题本中移除
const removeFromErrorBook = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    const { questionId } = ctx.request.body;
    
    console.log('收到移除错题请求，用户ID:', userId, '题目ID:', questionId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户未登录'
      };
      return;
    }
    
    const removed = await ErrorRecord.destroy({
      where: {
        questionId: questionId,
        userId: userId // 只移除当前用户的错题
      }
    });
    
    console.log('移除错题成功，结果:', removed);
    
    ctx.body = {
      code: 200,
      message: '移除错题成功',
      data: {
        removed
      }
    };
  } catch (error) {
    console.error('移除错题失败，错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '移除错题失败',
      error: error.message
    };
  }
};

// 更新题目
const updateQuestion = async (ctx) => {
  try {
    const { id } = ctx.params;
    const updateData = ctx.request.body;
    
    console.log('=== 更新题目 ===');
    console.log('题目ID:', id);
    console.log('更新数据:', updateData);
    
    // 确保ID是整数
    const questionId = parseInt(id);
    if (isNaN(questionId)) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '题目ID格式不正确'
      };
      return;
    }
    
    // 检查题目是否存在
    const existingQuestion = await Question.findByPk(questionId);
    if (!existingQuestion) {
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '题目不存在'
      };
      return;
    }
    
    // 准备更新数据
    const allowedFields = ['chapter', 'type', 'difficulty', 'content', 'options', 'answer', 'analysis', 'images'];
    const updateFields = {};
    
    allowedFields.forEach(field => {
      if (updateData[field] !== undefined) {
        updateFields[field] = updateData[field];
      }
    });
    
    // 更新题目
    const [updatedCount] = await Question.update(updateFields, {
      where: { id: questionId }
    });
    
    if (updatedCount === 0) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '更新失败，题目可能不存在'
      };
      return;
    }
    
    // 获取更新后的题目
    const updatedQuestion = await Question.findByPk(questionId, {
      include: [
        {
          model: QuestionBank,
          as: 'questionBank',
          attributes: ['id', 'name']
        },
        {
          model: Subject,
          as: 'subject',
          attributes: ['id', 'name']
        }
      ]
    });
    
    console.log('题目更新成功');
    
    ctx.body = {
      code: 200,
      message: '更新成功',
      data: updatedQuestion
    };
  } catch (error) {
    console.error('更新题目失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '更新失败',
      error: error.message
    };
  }
};

// 批量删除题目
const batchDeleteQuestions = async (ctx) => {
  try {
    const { questionIds } = ctx.request.body;
    
    if (!questionIds || !Array.isArray(questionIds) || questionIds.length === 0) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '请提供要删除的题目ID列表'
      };
      return;
    }

    console.log('批量删除题目ID:', questionIds);

    // 使用事务确保数据一致性
    const result = await sequelize.transaction(async (transaction) => {
      // 删除相关的收藏记录
      await Favorite.destroy({
        where: {
          questionId: {
            [Op.in]: questionIds
          }
        },
        transaction
      });

      // 删除相关的错题记录
      await ErrorRecord.destroy({
        where: {
          questionId: {
            [Op.in]: questionIds
          }
        },
        transaction
      });

      // 删除相关的答题记录
      await UserRecord.destroy({
        where: {
          questionId: {
            [Op.in]: questionIds
          }
        },
        transaction
      });

      // 删除题目
      const deletedCount = await Question.destroy({
        where: {
          id: {
            [Op.in]: questionIds
          }
        },
        transaction
      });

      return deletedCount;
    });

    console.log(`成功批量删除 ${result} 道题目`);

    ctx.body = {
      code: 200,
      message: '批量删除成功',
      data: {
        deletedCount: result,
        requestedCount: questionIds.length
      }
    };
  } catch (error) {
    console.error('批量删除题目失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '批量删除失败',
      error: error.message
    };
  }
};

module.exports = {
  getQuestions,
  getQuestionDetail,
  getQuestionById,
  getRandomQuestions,
  submitAnswer,
  getUserRecords,
  getErrorQuestions,
  importQuestions,
  getQuestionStats,
  updateQuestion,
  deleteQuestion,
  batchDeleteQuestions,
  deleteQuestionBank,
  addToFavorites,
  getFavorites,
  addToErrorBook,
  removeFromFavorites,
  removeFromErrorBook
};
