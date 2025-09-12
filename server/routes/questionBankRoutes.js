const Router = require('koa-router')
const questionBankController = require('../controllers/questionBankController')
const { auth } = require('../middlewares/auth')

const router = new Router({ prefix: '/api/question-bank' })

// 获取题库列表
router.get('/', auth, questionBankController.getQuestionBanks)

// 创建题库
router.post('/', auth, questionBankController.createQuestionBank)

// 获取题库详情
router.get('/:id', auth, questionBankController.getQuestionBankDetail)

// 更新题库
router.put('/:id', auth, questionBankController.updateQuestionBank)

// 删除题库
router.delete('/:id', auth, questionBankController.deleteQuestionBank)

module.exports = router
