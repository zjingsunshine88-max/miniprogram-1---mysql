const Koa = require('koa');
const Router = require('koa-router');
const bodyParser = require('koa-bodyparser');
const cors = require('koa-cors');
const serve = require('koa-static');
const path = require('path');

// 导入数据库配置和模型
const { sequelize, testConnection } = require('./config/database');
const { User, Question, UserRecord, Favorite, VerificationCode, ErrorRecord } = require('./models');
const { QuestionBank, Subject } = require('./models/associations');

// 导入路由
const userRoutes = require('./routes/userRoutes');
const questionRoutes = require('./routes/questionRoutes');
const cloudApiRoutes = require('./routes/cloudApiRoutes');
const questionBankRoutes = require('./routes/questionBankRoutes');
const subjectRoutes = require('./routes/subjectRoutes');
const enhancedQuestionRoutes = require('./routes/enhancedQuestionRoutes');
const activationCodeRoutes = require('./routes/activationCodeRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const adminRoutes = require('./routes/adminRoutes');

const app = new Koa();
const router = new Router();


// 配置CORS，允许小程序和后台管理系统访问
app.use(cors({
  origin: [
    '*'  // 微信开发者工具
  ],
  credentials: true,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],
  optionsSuccessStatus: 200
}));

// 解析请求体
app.use(bodyParser());

// 静态文件服务
app.use(serve(path.join(__dirname, 'public')));

// 错误处理中间件
app.use(async (ctx, next) => {
  try {
    await next();
  } catch (err) {
    ctx.status = err.status || 500;
    ctx.body = {
      code: ctx.status,
      message: err.message || '服务器内部错误'
    };
    console.error('服务器错误:', err);
  }
});

// 请求日志中间件
app.use(async (ctx, next) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  console.log(`${ctx.method} ${ctx.url} - ${ctx.status} - ${ms}ms`);
});


// 处理OPTIONS预检请求
router.options('/(.*)', async (ctx) => {
  ctx.status = 200;
  ctx.body = '';
});

// 基础路由
router.get('/health', async (ctx) => {
  ctx.body = {
    code: 200,
    message: '服务器运行正常',
    timestamp: new Date().toISOString()
  };
});

router.get('/api', async (ctx) => {
  ctx.body = {
    code: 200,
    message: 'API服务正常',
    version: '1.0.0',
    endpoints: {
      user: '/api/user',
      question: '/api/question',
      cloudFunction: '/api/cloud-function'
    }
  };
});

// 注册路由
app.use(router.routes());
app.use(router.allowedMethods());
app.use(userRoutes.routes());
app.use(userRoutes.allowedMethods());
app.use(questionRoutes.routes());
app.use(questionRoutes.allowedMethods());
app.use(cloudApiRoutes.routes());
app.use(cloudApiRoutes.allowedMethods());
app.use(questionBankRoutes.routes());
app.use(questionBankRoutes.allowedMethods());
app.use(subjectRoutes.routes());
app.use(subjectRoutes.allowedMethods());
app.use(enhancedQuestionRoutes.routes());
app.use(enhancedQuestionRoutes.allowedMethods());
app.use(activationCodeRoutes.routes());
app.use(activationCodeRoutes.allowedMethods());
app.use(uploadRoutes.routes());
app.use(uploadRoutes.allowedMethods());
app.use(adminRoutes.routes());
app.use(adminRoutes.allowedMethods());

// 404处理
app.use(async (ctx) => {
  ctx.status = 404;
  ctx.body = {
    code: 404,
    message: '接口不存在'
  };
});

// 启动服务器
const PORT = process.env.PORT || 3002;

const startServer = async () => {
  try {
    // 测试数据库连接
    const dbConnected = await testConnection();
    if (!dbConnected) {
      console.error('❌ 数据库连接失败，服务器启动失败');
      process.exit(1);
    }

    // 同步数据库模型 - 使用force: false避免修改现有表结构
    try {
      await sequelize.sync({ force: false });
      console.log('✅ 数据库模型同步完成');
    } catch (syncError) {
      console.warn('⚠️ 数据库同步警告:', syncError.message);
      console.log('📝 继续启动服务器，但某些表结构可能未完全同步');
    }

    app.listen(PORT, () => {
      console.log(`🚀 服务器启动成功！`);
      console.log(`📍 本地访问: http://localhost:${PORT}`);
      console.log(`📍 健康检查: http://localhost:${PORT}/health`);
      console.log(`📍 API文档: http://localhost:${PORT}/api`);
    });
  } catch (error) {
    console.error('❌ 服务器启动失败:', error);
    process.exit(1);
  }
};

// 优雅关闭
process.on('SIGINT', () => {
  console.log('\n🛑 正在关闭服务器...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 正在关闭服务器...');
  process.exit(0);
});

startServer();