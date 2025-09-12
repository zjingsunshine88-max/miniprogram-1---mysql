const { Question, User, UserRecord, Favorite, ErrorRecord } = require('../models');
const { QuestionBank, Subject } = require('../models/associations');
const { Op } = require('sequelize');
const { sequelize } = require('../config/database');

// 获取管理员统计数据
const getAdminStats = async (ctx) => {
  try {
    console.log('开始获取管理员统计数据...');
    
    // 获取用户总数
    const userCount = await User.count({
      where: { isAdmin: false } // 排除管理员用户
    });
    
    // 获取题目总数
    const questionCount = await Question.count({
      where: { status: 'active' }
    });
    
    // 获取题库总数
    const questionBankCount = await QuestionBank.count();
    
    // 获取科目总数
    const subjectCount = await Subject.count();
    
    // 获取总做题量（答题记录总数）
    const practiceCount = await UserRecord.count();
    
    // 获取错题总数
    const errorCount = await ErrorRecord.count();
    
    // 计算错题率
    const errorRate = practiceCount > 0 ? ((errorCount / practiceCount) * 100).toFixed(1) : 0;
    
    // 获取收藏总数
    const favoriteCount = await Favorite.count();
    
    // 获取今日新增用户数
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayUserCount = await User.count({
      where: {
        isAdmin: false,
        created_at: {
          [Op.gte]: today
        }
      }
    });
    
    // 获取今日做题量
    const todayPracticeCount = await UserRecord.count({
      where: {
        created_at: {
          [Op.gte]: today
        }
      }
    });
    
    // 获取最近7天的数据趋势
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    sevenDaysAgo.setHours(0, 0, 0, 0);
    
    const dailyStats = await UserRecord.findAll({
      attributes: [
        [sequelize.fn('DATE', sequelize.col('created_at')), 'date'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: {
        created_at: {
          [Op.gte]: sevenDaysAgo
        }
      },
      group: [sequelize.fn('DATE', sequelize.col('created_at'))],
      order: [[sequelize.fn('DATE', sequelize.col('created_at')), 'ASC']],
      raw: true
    });
    
    console.log('统计数据计算完成:', {
      userCount,
      questionCount,
      questionBankCount,
      subjectCount,
      practiceCount,
      errorCount,
      errorRate,
      favoriteCount,
      todayUserCount,
      todayPracticeCount
    });
    
    ctx.body = {
      code: 200,
      message: '获取统计数据成功',
      data: {
        userCount,
        questionCount,
        questionBankCount,
        subjectCount,
        practiceCount,
        errorCount,
        errorRate: parseFloat(errorRate),
        favoriteCount,
        todayUserCount,
        todayPracticeCount,
        dailyStats: dailyStats.map(item => ({
          date: item.date,
          count: parseInt(item.count)
        }))
      }
    };
  } catch (error) {
    console.error('获取管理员统计数据失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取统计数据失败',
      error: error.message
    };
  }
};

module.exports = {
  getAdminStats
};
