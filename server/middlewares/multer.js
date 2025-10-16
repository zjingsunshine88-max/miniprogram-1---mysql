const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 确保临时目录存在 - 使用相对路径（相对于middlewares目录）
let tempDir = process.env.TEMP_DIR || path.join(__dirname, '../temp');

try {
  if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir, { recursive: true });
    console.log('临时目录创建成功:', tempDir);
  } else {
    console.log('临时目录已存在:', tempDir);
  }
} catch (error) {
  console.error('临时目录创建失败:', error.message);
  // 尝试使用系统临时目录
  const os = require('os');
  const fallbackTempDir = path.join(os.tmpdir(), 'question-upload');
  try {
    if (!fs.existsSync(fallbackTempDir)) {
      fs.mkdirSync(fallbackTempDir, { recursive: true });
      console.log('使用系统临时目录:', fallbackTempDir);
    }
    tempDir = fallbackTempDir;
  } catch (fallbackError) {
    console.error('系统临时目录也创建失败:', fallbackError.message);
  }
}

// 确保uploads目录存在
const uploadsDir = path.join(__dirname, '../public/uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// 确保images子目录存在
const imagesDir = path.join(__dirname, '../public/uploads/images');
if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true });
}

// 文档存储配置
const documentStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, tempDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// 图片存储配置
const imageStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, imagesDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '_' + Math.round(Math.random() * 1E9);
    cb(null, 'question_image_' + uniqueSuffix + path.extname(file.originalname));
  }
});

// 文档文件过滤器
const documentFileFilter = (req, file, cb) => {
  console.log('文档文件过滤器 - 文件名:', file.originalname);
  console.log('文档文件过滤器 - 字段名:', file.fieldname);
  console.log('文档文件过滤器 - MIME类型:', file.mimetype);
  
  const allowedTypes = ['docx', 'doc', 'xlsx', 'xls', 'pdf', 'txt'];
  const fileExtension = file.originalname.split('.').pop().toLowerCase();
  
  if (allowedTypes.includes(fileExtension)) {
    console.log('文档文件类型验证通过');
    cb(null, true);
  } else {
    console.log('文档文件类型验证失败:', fileExtension);
    cb(new Error('不支持的文件格式'), false);
  }
};

// 图片文件过滤器
const imageFileFilter = (req, file, cb) => {
  console.log('图片文件过滤器 - 文件名:', file.originalname);
  console.log('图片文件过滤器 - 字段名:', file.fieldname);
  console.log('图片文件过滤器 - MIME类型:', file.mimetype);
  
  const allowedTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  const fileExtension = file.originalname.split('.').pop().toLowerCase();
  
  if (allowedTypes.includes(fileExtension)) {
    console.log('图片文件类型验证通过');
    cb(null, true);
  } else {
    console.log('图片文件类型验证失败:', fileExtension);
    cb(new Error('不支持的图片格式'), false);
  }
};

// 文档上传配置
const documentUpload = multer({
  storage: documentStorage,
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB
  },
  fileFilter: documentFileFilter
});

// 图片上传配置
const imageUpload = multer({
  storage: imageStorage,
  limits: {
    fileSize: 2 * 1024 * 1024 // 2MB
  },
  fileFilter: imageFileFilter
});

// Koa 中间件包装器
const koaMulter = (multerMiddleware) => {
  return (ctx, next) => {
    return new Promise((resolve, reject) => {
      multerMiddleware(ctx.req, ctx.res, (err) => {
        if (err) {
          console.error('Multer错误:', err);
          reject(err);
        } else {
          // 将 multer 处理后的文件信息复制到 Koa 的 request 对象
          ctx.request.files = ctx.req.files;
          ctx.request.file = ctx.req.file;
          ctx.request.body = ctx.req.body;
          resolve(next());
        }
      });
    });
  };
};

module.exports = {
  upload: documentUpload, // 保持向后兼容
  documentUpload,
  imageUpload,
  koaMulter
};
