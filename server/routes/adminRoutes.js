const Router = require('koa-router');
const adminController = require('../controllers/adminController');
const { auth } = require('../middlewares/auth');

const router = new Router({
  prefix: '/api/admin'
});

// 获取管理员统计数据（需要认证）
router.get('/stats', auth, adminController.getAdminStats);

module.exports = router;
