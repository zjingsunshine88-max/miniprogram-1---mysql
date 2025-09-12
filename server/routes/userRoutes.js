const Router = require('koa-router');
const userController = require('../controllers/userController');
const { auth, optionalAuth } = require('../middlewares/auth');

const router = new Router({
  prefix: '/api/user'
});

// 用户注册
router.post('/register', userController.register);

// 用户登录
router.post('/login', userController.login);

// 管理员登录
router.post('/admin-login', userController.adminLogin);

// 微信登录
router.post('/wechat-login', userController.wechatLogin);

// 发送验证码
router.post('/send-verification-code', userController.sendVerificationCode);

// 验证码登录
router.post('/login-with-verification-code', userController.loginWithVerificationCode);

// 手机号登录
router.post('/login-with-phone', userController.loginWithPhone);

// 获取用户信息（需要认证）
router.get('/info', auth, userController.getUserInfo);

// 更新用户信息（需要认证）
router.put('/info', auth, userController.updateUserInfo);

// 获取用户统计信息（可选认证）
router.get('/stats', optionalAuth, userController.getStats);

// 检查管理员权限（需要认证）
router.get('/check-admin-permission', auth, userController.checkAdminPermission);

module.exports = router;
