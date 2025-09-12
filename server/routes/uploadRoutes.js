const Router = require('koa-router');
const { auth } = require('../middlewares/auth');
const { imageUpload, koaMulter } = require('../middlewares/multer');
const path = require('path');
const fs = require('fs');

const router = new Router({
  prefix: '/api/upload'
});

// 图片上传
router.post('/image', auth, koaMulter(imageUpload.single('file')), async (ctx) => {
  try {
    if (!ctx.request.file) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '请选择要上传的文件'
      };
      return;
    }

    const file = ctx.request.file;
    
    // 检查文件类型
    if (!file.mimetype.startsWith('image/')) {
      // 删除已上传的文件
      fs.unlinkSync(file.path);
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '只能上传图片文件'
      };
      return;
    }

    // 检查文件大小 (2MB)
    if (file.size > 2 * 1024 * 1024) {
      // 删除已上传的文件
      fs.unlinkSync(file.path);
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '图片大小不能超过2MB'
      };
      return;
    }

    // 生成访问URL
    const fileName = path.basename(file.path);
    const imagePath = `images/${fileName}`;
    const url = `http://localhost:3002/uploads/${imagePath}`;

    console.log('图片上传成功:', {
      originalName: file.originalname,
      fileName: fileName,
      imagePath: imagePath,
      size: file.size,
      url: url
    });

    ctx.body = {
      code: 200,
      message: '上传成功',
      data: {
        originalName: file.originalname,
        fileName: fileName,
        path: imagePath,
        url: url,
        size: file.size
      }
    };
  } catch (error) {
    console.error('图片上传失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '上传失败',
      error: error.message
    };
  }
});

module.exports = router;
