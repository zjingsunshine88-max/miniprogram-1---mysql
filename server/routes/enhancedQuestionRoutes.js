const Router = require('koa-router');
const enhancedQuestionController = require('../controllers/enhancedQuestionController');
const { auth } = require('../middlewares/auth');
const { upload, koaMulter } = require('../middlewares/multer');

const router = new Router({
  prefix: '/api/enhanced-question'
});

// 添加错误处理中间件
const handleMulterError = async (ctx, next) => {
  try {
    await next();
  } catch (err) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      ctx.body = { code: 400, message: '文件大小超过限制' };
      return;
    }
    if (err.code === 'LIMIT_UNEXPECTED_FILE') {
      ctx.body = { code: 400, message: '意外的文件字段' };
      return;
    }
    throw err;
  }
};

// 智能上传题目（需要认证）
router.post('/smart-upload', auth, koaMulter(upload.single('file')), enhancedQuestionController.smartUpload.bind(enhancedQuestionController));

// 测试路由 - 不包含认证中间件
router.post('/test-upload', koaMulter(upload.single('file')), (ctx) => {
  console.log('=== 测试上传路由 ===');
  console.log('ctx.request.files:', ctx.request.files);
  console.log('ctx.request.body:', ctx.request.body);
  console.log('ctx.request.file:', ctx.request.file);
  console.log('ctx.request.headers:', ctx.request.headers);
  console.log('========================');
  
  ctx.body = {
    code: 200,
    message: '测试成功',
    data: {
      hasFile: !!ctx.request.file,
      hasFiles: !!ctx.request.files,
      file: ctx.request.file,
      files: ctx.request.files
    }
  };
});

// 预览解析结果（需要认证）
router.post('/preview-parse', auth, handleMulterError, koaMulter(upload.single('file')), (ctx, next) => {
  console.log('=== Multer中间件调试 ===');
  console.log('ctx.request.files:', ctx.request.files);
  console.log('ctx.request.body:', ctx.request.body);
  console.log('ctx.request.file:', ctx.request.file);
  console.log('========================');
  return next();
}, enhancedQuestionController.previewParse.bind(enhancedQuestionController));

// 获取支持的文档格式
router.get('/supported-formats', enhancedQuestionController.getSupportedFormats.bind(enhancedQuestionController));

// 获取解析模板
router.get('/parse-template', enhancedQuestionController.getParseTemplate.bind(enhancedQuestionController));

module.exports = router;
