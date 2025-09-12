const Router = require('koa-router');
const userController = require('../controllers/userController');
const questionController = require('../controllers/questionController');
const { auth, optionalAuth } = require('../middlewares/auth');

const router = new Router({
  prefix: '/api'
});

// 云函数API路由 - 匹配云函数的action结构
router.post('/cloud-function', async (ctx) => {
  const { action, ...params } = ctx.request.body;
  
  console.log('云函数API调用:', action, params);
  
  try {
    switch (action) {
      // 用户相关
      case 'user.login':
        return await userController.login(ctx);
      case 'user.sendVerificationCode':
        return await userController.sendVerificationCode(ctx);
      case 'user.loginWithVerificationCode':
        return await userController.loginWithVerificationCode(ctx);
      case 'user.loginWithPhone':
        return await userController.loginWithPhone(ctx);
      case 'user.getInfo':
        return await userController.getUserInfo(ctx);
      case 'user.getStats':
        return await userController.getStats(ctx);
      case 'user.checkAdminPermission':
        return await userController.checkAdminPermission(ctx);
      
      // 题目相关
      case 'question.getList':
        return await questionController.getQuestions(ctx);
      case 'question.getDetail':
        return await questionController.getQuestionDetail(ctx);
      case 'question.getById':
        return await questionController.getQuestionById(ctx);
      case 'question.getRandom':
        return await questionController.getRandomQuestions(ctx);
      case 'question.submitAnswer':
        return await questionController.submitAnswer(ctx);
      case 'question.getUserRecords':
        return await questionController.getUserRecords(ctx);
      case 'question.getErrorQuestions':
        return await questionController.getErrorQuestions(ctx);
      case 'question.importQuestions':
        return await questionController.importQuestions(ctx);
      case 'question.getStats':
        return await questionController.getQuestionStats(ctx);
      case 'question.deleteQuestionBank':
        return await questionController.deleteQuestionBank(ctx);
      case 'question.addToFavorites':
        return await questionController.addToFavorites(ctx);
      case 'question.getFavorites':
        return await questionController.getFavorites(ctx);
      case 'question.addToErrorBook':
        return await questionController.addToErrorBook(ctx);
      case 'question.removeFromFavorites':
        return await questionController.removeFromFavorites(ctx);
      case 'question.removeFromErrorBook':
        return await questionController.removeFromErrorBook(ctx);
      
      default:
        ctx.status = 400;
        ctx.body = {
          code: 400,
          message: '未知的操作类型',
          action
        };
    }
  } catch (error) {
    console.error('云函数API执行错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误',
      error: error.message
    };
  }
});

module.exports = router;
