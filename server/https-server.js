const https = require('https');
const fs = require('fs');
const path = require('path');
const Koa = require('koa');
const Router = require('koa-router');
const bodyParser = require('koa-bodyparser');
const cors = require('koa-cors');
const serve = require('koa-static');

// 导入数据库配置和模型
const { sequelize, testConnection } = require('./config/database');
const { User, Question, UserRecord, Favorite } = require('./models');

// 导入路由
const userRoutes = require('./routes/userRoutes');
const questionRoutes = require('./routes/questionRoutes');

const app = new Koa();
const router = new Router();

// 配置CORS，允许小程序访问
app.use(cors({
  origin: '*',
  credentials: true,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'Accept']
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

// 基础路由
router.get('/health', async (ctx) => {
  ctx.body = {
    code: 200,
    message: 'HTTPS服务器运行正常',
    timestamp: new Date().toISOString()
  };
});

router.get('/api', async (ctx) => {
  ctx.body = {
    code: 200,
    message: 'HTTPS API服务正常',
    version: '1.0.0',
    endpoints: {
      user: '/api/user',
      question: '/api/question'
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

// 404处理
app.use(async (ctx) => {
  ctx.status = 404;
  ctx.body = {
    code: 404,
    message: '接口不存在'
  };
});

// HTTPS配置
const PORT = process.env.HTTPS_PORT || 3443;

// 自签名证书配置（仅用于开发环境）
const options = {
  key: fs.readFileSync(path.join(__dirname, 'certs', 'localhost-key.pem')),
  cert: fs.readFileSync(path.join(__dirname, 'certs', 'localhost.pem'))
};

// 启动HTTPS服务器
const startHttpsServer = async () => {
  try {
    // 测试数据库连接
    const dbConnected = await testConnection();
    if (!dbConnected) {
      console.error('❌ 数据库连接失败，服务器启动失败');
      process.exit(1);
    }

    // 同步数据库模型
    await sequelize.sync({ alter: true });
    console.log('✅ 数据库模型同步完成');

    // 创建HTTPS服务器
    const server = https.createServer(options, app.callback());
    
    server.listen(PORT, () => {
      console.log(`🚀 HTTPS服务器启动成功！`);
      console.log(`📍 本地访问: https://localhost:${PORT}`);
      console.log(`📍 健康检查: https://localhost:${PORT}/health`);
      console.log(`📍 API文档: https://localhost:${PORT}/api`);
      console.log(`\n⚠️  注意：这是自签名证书，浏览器会显示安全警告，这是正常的`);
    });
  } catch (error) {
    console.error('❌ HTTPS服务器启动失败:', error);
    process.exit(1);
  }
};

// 优雅关闭
process.on('SIGINT', () => {
  console.log('\n🛑 正在关闭HTTPS服务器...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 正在关闭HTTPS服务器...');
  process.exit(0);
});

startHttpsServer();
