const Router = require('koa-router')
const subjectController = require('../controllers/subjectController')
const { auth } = require('../middlewares/auth')

const router = new Router({ prefix: '/api/subject' })

// 获取科目列表
router.get('/', auth, subjectController.getSubjects)

// 创建科目
router.post('/', auth, subjectController.createSubject)

// 获取科目详情
router.get('/:id', auth, subjectController.getSubjectDetail)

// 更新科目
router.put('/:id', auth, subjectController.updateSubject)

// 删除科目
router.delete('/:id', auth, subjectController.deleteSubject)

module.exports = router
