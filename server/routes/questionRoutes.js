const Router = require('koa-router');
const questionController = require('../controllers/questionController');
const { auth, optionalAuth } = require('../middlewares/auth');

const router = new Router({
  prefix: '/api/question'
});

// 获取题目列表（可选认证）
router.get('/list', optionalAuth, questionController.getQuestions);

// 获取题目详情（可选认证）
router.get('/detail/:id', optionalAuth, questionController.getQuestionDetail);

// 通过ID获取题目（可选认证）
router.get('/get-by-id', optionalAuth, questionController.getQuestionById);

// 随机获取题目（可选认证）
router.get('/random', optionalAuth, questionController.getRandomQuestions);

// 提交答题记录（需要认证）
router.post('/submit', auth, questionController.submitAnswer);

// 获取用户答题记录（需要认证）
router.get('/records', auth, questionController.getUserRecords);

// 获取错题列表（需要认证）
router.get('/errors', auth, questionController.getErrorQuestions);

// 批量导入题目（需要认证）
router.post('/import', auth, questionController.importQuestions);

// 获取题目统计信息（可选认证）
router.get('/stats', optionalAuth, questionController.getQuestionStats);

// 更新题目（需要认证）
router.put('/detail/:id', auth, questionController.updateQuestion);

// 删除单个题目（需要认证）
router.delete('/detail/:id', auth, questionController.deleteQuestion);

// 批量删除题目（需要认证）
router.post('/batch-delete', auth, questionController.batchDeleteQuestions);

// 删除题库（需要认证）
router.post('/delete-bank', auth, questionController.deleteQuestionBank);

// 添加到收藏（需要认证）
router.post('/add-to-favorites', auth, questionController.addToFavorites);

// 获取收藏列表（需要认证）
router.get('/favorites', auth, questionController.getFavorites);

// 添加到错题本（需要认证）
router.post('/add-to-error-book', auth, questionController.addToErrorBook);

// 从收藏中移除（需要认证）
router.post('/remove-from-favorites', auth, questionController.removeFromFavorites);

// 从错题本中移除（需要认证）
router.post('/remove-from-error-book', auth, questionController.removeFromErrorBook);

module.exports = router;
