// 生产环境配置
module.exports = {
  // 数据库配置
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    username: process.env.DB_USERNAME || 'minipractice',
    password: process.env.DB_PASSWORD || 'LOVEjing96..',
    database: process.env.DB_NAME || 'minipractice',
    dialect: 'mysql',
    logging: false, // 生产环境关闭SQL日志
    pool: {
      max: 20,
      min: 5,
      acquire: 30000,
      idle: 10000
    }
  },
  
  // 服务器配置
  server: {
    port: process.env.PORT || 3002,
    host: process.env.HOST || '0.0.0.0' // 监听所有接口，由Nginx处理域名
  },
  
  // JWT配置
  jwt: {
    secret: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production',
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
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : [
      'https://practice.insightdata.top',
      'https://admin.practice.insightdata.top',
      'https://admin.practice.insightdata.top:8443'
    ],
    credentials: true
  },
  
  // 环境标识
  env: 'production'
}
