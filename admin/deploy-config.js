// 部署配置文件
module.exports = {
  // 云开发环境ID
  envId: 'cloudbase-5guq06yfe657e091',
  
  // 云函数配置
  cloudFunction: {
    // admin-api云函数URL
    adminApiUrl: 'https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/admin-api',
    // question-bank-api云函数URL
    questionApiUrl: 'https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/question-bank-api'
  },
  
  // 静态托管配置
  hosting: {
    // 静态网站域名
    domain: 'https://cloudbase-5guq06yfe657e091.tcloudbaseapp.com',
    // 自定义域名（可选）
    customDomain: '',
    // 部署目录
    distDir: 'dist'
  },
  
  // 构建配置
  build: {
    // 输出目录
    outDir: 'dist',
    // 是否压缩
    minify: true,
    // 是否生成sourcemap
    sourcemap: false
  }
}
