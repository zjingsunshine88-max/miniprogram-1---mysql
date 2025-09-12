const Router = require('koa-router');
const activationCodeController = require('../controllers/activationCodeController');
const { auth } = require('../middlewares/auth');

const router = new Router({
  prefix: '/api/activation-code'
});

// 创建激活码（需要认证）
router.post('/', auth, activationCodeController.createActivationCode);

// 获取激活码列表（需要认证）
router.get('/', auth, activationCodeController.getActivationCodes);

// 获取激活码详情（需要认证）
router.get('/:id', auth, activationCodeController.getActivationCodeById);

// 更新激活码（需要认证）
router.put('/:id', auth, activationCodeController.updateActivationCode);

// 删除激活码（需要认证）
router.delete('/:id', auth, activationCodeController.deleteActivationCode);

// 小程序端：验证激活码（需要认证）
router.post('/verify', auth, activationCodeController.verifyActivationCode);

// 小程序端：获取用户已激活的科目（需要认证）
router.get('/user/subjects', auth, activationCodeController.getUserActivatedSubjects);

module.exports = router;
