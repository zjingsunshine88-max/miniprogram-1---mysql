const { verifyToken, extractToken } = require('../utils/jwt');
const { User } = require('../models');

// 认证中间件
const auth = async (ctx, next) => {
  try {
    const token = extractToken(ctx);
    if (!token) {
      ctx.status = 401;
      ctx.body = {
        code: 401,
        message: '未提供认证token'
      };
      return;
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      ctx.status = 401;
      ctx.body = {
        code: 401,
        message: 'token无效或已过期'
      };
      return;
    }

    // 获取用户信息
    const user = await User.findByPk(decoded.userId);
    if (!user || user.status !== 'active') {
      ctx.status = 401;
      ctx.body = {
        code: 401,
        message: '用户不存在或已被禁用'
      };
      return;
    }

    // 将用户信息添加到ctx中
    ctx.state.user = user;
    await next();
  } catch (error) {
    console.error('认证中间件错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误'
    };
  }
};

// 可选认证中间件（不强制要求登录）
const optionalAuth = async (ctx, next) => {
  try {
    const token = extractToken(ctx);
    if (token) {
      const decoded = verifyToken(token);
      if (decoded) {
        const user = await User.findByPk(decoded.userId);
        if (user && user.status === 'active') {
          ctx.state.user = user;
        }
      }
    }
    await next();
  } catch (error) {
    console.error('可选认证中间件错误:', error);
    await next();
  }
};

// 管理员权限中间件
const adminAuth = async (ctx, next) => {
  try {
    const user = ctx.state.user;
    if (!user || user.role !== 'admin') {
      ctx.status = 403;
      ctx.body = {
        code: 403,
        message: '需要管理员权限'
      };
      return;
    }
    await next();
  } catch (error) {
    console.error('管理员权限中间件错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误'
    };
  }
};

module.exports = {
  auth,
  optionalAuth,
  adminAuth
};
