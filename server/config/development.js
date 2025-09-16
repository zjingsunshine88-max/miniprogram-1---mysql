// 开发环境配置
module.exports = {
  // 数据库配置
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    username: process.env.DB_USERNAME || 'root',
    password: process.env.DB_PASSWORD || '1234', // 开发环境密码
    database: process.env.DB_NAME || 'practice',
    dialect: 'mysql',
    logging: console.log, // 开发环境显示SQL日志
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  },
  
  // 服务器配置
  server: {
    port: process.env.PORT || 3002,
    host: process.env.HOST || 'localhost'
  },
  
  // JWT配置
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-jwt-secret-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '24h'
  },
  
  // 文件上传配置
  upload: {
    maxFileSize: 10 * 1024 * 1024, // 10MB
    allowedTypes: ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
    uploadPath: process.env.UPLOAD_PATH || './public/uploads'
  },
  
  // 跨域配置
  cors: {
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : ['http://localhost:3000', 'http://localhost:3001', 'http://127.0.0.1:3000'],
    credentials: true
  },
  
  // 环境标识
  env: 'development'
}
