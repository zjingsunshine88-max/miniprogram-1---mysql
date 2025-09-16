const { User, VerificationCode } = require('../models');
const { generateToken } = require('../utils/jwt');
const bcrypt = require('bcryptjs');

// 用户注册
const register = async (ctx) => {
  try {
    const { nickname, phone, email, password } = ctx.request.body;

    // 验证必填字段
    if (!nickname) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '昵称不能为空'
      };
      return;
    }

    // 检查手机号是否已存在
    if (phone) {
      const existingUser = await User.findOne({ where: { phone } });
      if (existingUser) {
        ctx.status = 400;
        ctx.body = {
          code: 400,
          message: '手机号已被注册'
        };
        return;
      }
    }

    // 创建用户
    const user = await User.create({
      nickname,
      phone,
      email,
      password
    });

    // 生成token
    const token = generateToken({ userId: user.id });

    ctx.body = {
      code: 200,
      message: '注册成功',
      data: {
        token,
        user: {
          id: user.id,
          nickname: user.nickname,
          phone: user.phone,
          email: user.email,
          role: user.role
        }
      }
    };
  } catch (error) {
    console.error('用户注册错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误'
    };
  }
};

// 用户登录
const login = async (ctx) => {
  try {
    const { phone, password } = ctx.request.body;

    if (!phone || !password) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '手机号和密码不能为空'
      };
      return;
    }

    // 查找用户
    const user = await User.findOne({ where: { phone } });
    if (!user) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户不存在'
      };
      return;
    }

    // 验证密码
    const isValidPassword = await user.validatePassword(password);
    if (!isValidPassword) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '密码错误'
      };
      return;
    }

    // 更新最后登录时间
    await user.update({ last_login_at: new Date() });

    // 生成token
    const token = generateToken({ userId: user.id });

    ctx.body = {
      code: 200,
      message: '登录成功',
      data: {
        token,
        user: {
          id: user.id,
          nickname: user.nickname,
          phone: user.phone,
          email: user.email,
          role: user.role
        }
      }
    };
  } catch (error) {
    console.error('用户登录错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误'
    };
  }
};

// 微信登录
const wechatLogin = async (ctx) => {
  try {
    const { code, userInfo } = ctx.request.body;

    if (!code) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '微信授权码不能为空'
      };
      return;
    }

    // 这里应该调用微信API获取openid
    // 为了演示，我们模拟一个openid
    const openid = `mock_openid_${Date.now()}`;

    // 查找或创建用户
    let user = await User.findOne({ where: { openid } });
    
    if (!user) {
      // 创建新用户
      user = await User.create({
        openid,
        nickname: userInfo?.nickName || '微信用户',
        avatar: userInfo?.avatarUrl || ''
      });
    } else {
      // 更新用户信息
      await user.update({
        nickname: userInfo?.nickName || user.nickname,
        avatar: userInfo?.avatarUrl || user.avatar,
        last_login_at: new Date()
      });
    }

    // 生成token
    const token = generateToken({ userId: user.id });

    ctx.body = {
      code: 200,
      message: '登录成功',
      data: {
        token,
        user: {
          id: user.id,
          nickname: user.nickname,
          avatar: user.avatar,
          role: user.role
        }
      }
    };
  } catch (error) {
    console.error('微信登录错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误'
    };
  }
};

// 获取用户信息
const getUserInfo = async (ctx) => {
  try {
    const user = ctx.state.user;

    ctx.body = {
      code: 200,
      message: '获取成功',
      data: {
        id: user.id,
        nickname: user.nickname,
        avatar: user.avatar,
        phone: user.phone,
        email: user.email,
        role: user.role,
        last_login_at: user.last_login_at
      }
    };
  } catch (error) {
    console.error('获取用户信息错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误'
    };
  }
};

// 更新用户信息
const updateUserInfo = async (ctx) => {
  try {
    const user = ctx.state.user;
    const { nickname, avatar, phone, email } = ctx.request.body;

    const updateData = {};
    if (nickname) updateData.nickname = nickname;
    if (avatar) updateData.avatar = avatar;
    if (phone) updateData.phone = phone;
    if (email) updateData.email = email;

    await user.update(updateData);

    ctx.body = {
      code: 200,
      message: '更新成功',
      data: {
        id: user.id,
        nickname: user.nickname,
        avatar: user.avatar,
        phone: user.phone,
        email: user.email,
        role: user.role
      }
    };
  } catch (error) {
    console.error('更新用户信息错误:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '服务器内部错误'
    };
  }
};

// 发送验证码
const sendVerificationCode = async (ctx) => {
  try {
    const { phoneNumber } = ctx.request.body;
    
    console.log('收到发送验证码请求:', { phoneNumber });
    
    if (!phoneNumber) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '缺少手机号参数'
      };
      return;
    }

    // 验证手机号格式
    if (!/^1[3-9]\d{9}$/.test(phoneNumber)) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '手机号格式不正确'
      };
      return;
    }

    // 生成6位验证码
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    
    // 保存验证码到数据库（设置5分钟过期）
    const expireTime = new Date(Date.now() + 5 * 60 * 1000); // 5分钟后过期
    
    await VerificationCode.create({
      phoneNumber,
      code: verificationCode,
      expireTime: expireTime,
      used: false
    });
    
    console.log('验证码已保存到数据库:', { phoneNumber, code: verificationCode });
    
    // 这里应该发送真实短信，开发环境下返回验证码
    ctx.body = {
      code: 200,
      message: '验证码发送成功（开发模式）',
      data: {
        phoneNumber: phoneNumber,
        code: verificationCode // 开发环境下返回验证码
      }
    };
  } catch (error) {
    console.error('发送验证码失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '发送验证码失败',
      error: error.message
    };
  }
};

// 使用验证码登录
const loginWithVerificationCode = async (ctx) => {
  try {
    const { phoneNumber, verificationCode } = ctx.request.body;
    
    console.log('收到验证码登录请求:', { phoneNumber, verificationCode });
    
    if (!phoneNumber || !verificationCode) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '缺少手机号或验证码参数'
      };
      return;
    }

    // 验证手机号格式
    if (!/^1[3-9]\d{9}$/.test(phoneNumber)) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '手机号格式不正确'
      };
      return;
    }

    // 验证验证码格式
    if (!/^\d{6}$/.test(verificationCode)) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '验证码格式不正确'
      };
      return;
    }

    // 查找验证码记录
    const codeRecord = await VerificationCode.findOne({
      where: {
        phoneNumber: phoneNumber,
        code: verificationCode,
        used: false,
        expireTime: {
          [require('sequelize').Op.gt]: new Date()
        }
      },
      order: [['createdAt', 'DESC']]
    });

    if (!codeRecord) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '验证码无效或已过期'
      };
      return;
    }
    
    // 标记验证码为已使用
    await codeRecord.update({
      used: true,
      useTime: new Date()
    });

    console.log('验证码验证成功，开始处理用户登录');

    // 检查用户是否已存在（基于手机号去重）
    let user = await User.findOne({
      where: { phoneNumber: phoneNumber }
    });
    
    if (user) {
      // 用户已存在，更新登录时间
      await user.update({
        lastLoginTime: new Date()
      });
      
      console.log('用户已存在，登录成功:', user.id);
      
      // 生成token
      const token = generateToken({ userId: user.id });
      
      ctx.body = {
        code: 200,
        message: '登录成功',
        data: {
          token,
          userInfo: {
            id: user.id,
            phoneNumber: user.phoneNumber,
            nickName: user.nickName,
            avatarUrl: user.avatarUrl,
            isAdmin: user.isAdmin,
            lastLoginTime: user.lastLoginTime,
            isNewUser: false
          }
        }
      };
    } else {
      // 新用户，创建记录
      user = await User.create({
        phoneNumber,
        nickName: `用户${phoneNumber.slice(-4)}`, // 使用手机号后4位作为昵称
        avatarUrl: '', // 默认头像
        openid: '', // 暂时为空，后续可以绑定微信
        isAdmin: false, // 默认非管理员
        lastLoginTime: new Date()
      });
      
      console.log('新用户创建成功:', user.id);
      
      // 生成token
      const token = generateToken({ userId: user.id });
      
      ctx.body = {
        code: 200,
        message: '注册成功',
        data: {
          token,
          userInfo: {
            id: user.id,
            phoneNumber: user.phoneNumber,
            nickName: user.nickName,
            avatarUrl: user.avatarUrl,
            isAdmin: user.isAdmin,
            lastLoginTime: user.lastLoginTime,
            isNewUser: true
          }
        }
      };
    }
  } catch (error) {
    console.error('验证码登录失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '登录失败',
      error: error.message
    };
  }
};

// 使用手机号登录
const loginWithPhone = async (ctx) => {
  try {
    const { phoneNumber } = ctx.request.body;
    
    if (!phoneNumber) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '缺少手机号参数'
      };
      return;
    }

    console.log('手机号登录请求:', phoneNumber);

    // 检查用户是否已存在（基于手机号去重）
    let user = await User.findOne({
      where: { phoneNumber: phoneNumber }
    });
    
    if (user) {
      // 用户已存在，更新登录时间
      await user.update({
        lastLoginTime: new Date()
      });
      
      console.log('用户已存在，登录成功:', user.id);
      
      // 生成token
      const token = generateToken({ userId: user.id });
      
      ctx.body = {
        code: 200,
        message: '登录成功',
        data: {
          token,
          userInfo: {
            id: user.id,
            phoneNumber: user.phoneNumber,
            nickName: user.nickName,
            avatarUrl: user.avatarUrl,
            isAdmin: user.isAdmin,
            lastLoginTime: user.lastLoginTime,
            isNewUser: false
          }
        }
      };
    } else {
      // 新用户，创建记录
      user = await User.create({
        phoneNumber,
        nickName: `用户${phoneNumber.slice(-4)}`, // 使用手机号后4位作为昵称
        avatarUrl: '', // 默认头像
        openid: '', // 暂时为空，后续可以绑定微信
        isAdmin: false, // 默认非管理员
        lastLoginTime: new Date()
      });
      
      console.log('新用户创建成功:', user.id);
      
      // 生成token
      const token = generateToken({ userId: user.id });
      
      ctx.body = {
        code: 200,
        message: '注册成功',
        data: {
          token,
          userInfo: {
            id: user.id,
            phoneNumber: user.phoneNumber,
            nickName: user.nickName,
            avatarUrl: user.avatarUrl,
            isAdmin: user.isAdmin,
            lastLoginTime: user.lastLoginTime,
            isNewUser: true
          }
        }
      };
    }
  } catch (error) {
    console.error('手机号登录失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '登录失败',
      error: error.message
    };
  }
};

// 获取用户统计信息
const getStats = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    
    console.log('获取用户统计信息，用户ID:', userId);
    
    // 如果用户未登录，返回空数据
    if (!userId) {
      console.log('用户未登录，返回空统计数据');
      ctx.body = {
        code: 200,
        message: '获取统计信息成功',
        data: {
          totalAnswered: 0,
          correctCount: 0,
          wrongCount: 0,
          favoritesCount: 0,
          accuracy: 0,
          studyDays: 0,
          continuousDays: 0,
          todayAnswered: 0,
          weekAnswered: 0,
          monthAnswered: 0
        }
      };
      return;
    }
    
    // 获取用户基本信息
    const user = await User.findByPk(userId);
    if (!user) {
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '用户不存在'
      };
      return;
    }
    
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
    const monthAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);
    
    // 获取答题记录统计
    const { UserRecord, Favorite, ErrorRecord } = require('../models');
    
    const answerRecords = await UserRecord.count({
      where: { userId }
    });
    
    // 获取错题统计
    const errorRecords = await ErrorRecord.count({
      where: { userId }
    });
    
    // 获取收藏统计
    const favorites = await Favorite.count({
      where: { userId }
    });
    
    // 计算正确率
    const correctRecords = await UserRecord.count({
      where: {
        userId,
        isCorrect: true
      }
    });
    
    // 获取今日答题数量
    const todayAnswered = await UserRecord.count({
      where: {
        userId,
        createdAt: {
          [require('sequelize').Op.gte]: today
        }
      }
    });
    
    // 获取本周答题数量
    const weekAnswered = await UserRecord.count({
      where: {
        userId,
        createdAt: {
          [require('sequelize').Op.gte]: weekAgo
        }
      }
    });
    
    // 获取本月答题数量
    const monthAnswered = await UserRecord.count({
      where: {
        userId,
        createdAt: {
          [require('sequelize').Op.gte]: monthAgo
        }
      }
    });
    
    // 计算学习天数（从用户首次登录开始）
    const firstLoginTime = user.createdAt || user.lastLoginTime;
    const studyDays = firstLoginTime ? 
      Math.ceil((now.getTime() - new Date(firstLoginTime).getTime()) / (1000 * 3600 * 24)) : 0;
    
    // 计算连续学习天数（简化版本，基于最近7天的答题记录）
    const continuousDays = await calculateContinuousDays(userId, weekAgo);
    
    const totalAnswered = answerRecords;
    const accuracy = totalAnswered > 0 ? Math.round((correctRecords / totalAnswered) * 100) : 0;
    
    console.log('用户统计计算完成:', {
      userId,
      totalAnswered,
      correctCount: correctRecords,
      wrongCount: errorRecords,
      accuracy,
      studyDays,
      continuousDays,
      todayAnswered,
      weekAnswered,
      monthAnswered
    });
    
    ctx.body = {
      code: 200,
      message: '获取统计信息成功',
      data: {
        totalAnswered: totalAnswered,
        correctCount: correctRecords,
        wrongCount: errorRecords,
        favoritesCount: favorites,
        accuracy: accuracy,
        studyDays: Math.max(1, studyDays),
        continuousDays: continuousDays,
        todayAnswered: todayAnswered,
        weekAnswered: weekAnswered,
        monthAnswered: monthAnswered,
        lastUpdate: now
      }
    };
  } catch (error) {
    console.error('获取用户统计信息失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '获取统计信息失败',
      error: error.message
    };
  }
};

// 计算连续学习天数
const calculateContinuousDays = async (userId, weekAgo) => {
  try {
    const { UserRecord } = require('../models');
    
    // 获取最近7天的答题记录
    const records = await UserRecord.findAll({
      where: {
        userId,
        createdAt: {
          [require('sequelize').Op.gte]: weekAgo
        }
      },
      order: [['createdAt', 'DESC']]
    });
    
    if (records.length === 0) {
      return 0;
    }
    
    // 按日期分组，统计每天是否有答题记录
    const dailyRecords = {};
    records.forEach(record => {
      const date = new Date(record.createdAt);
      const dateKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
      dailyRecords[dateKey] = true;
    });
    
    // 计算连续天数
    let continuousDays = 0;
    const today = new Date();
    
    for (let i = 0; i < 7; i++) {
      const checkDate = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      const dateKey = `${checkDate.getFullYear()}-${String(checkDate.getMonth() + 1).padStart(2, '0')}-${String(checkDate.getDate()).padStart(2, '0')}`;
      
      if (dailyRecords[dateKey]) {
        continuousDays++;
      } else {
        break;
      }
    }
    
    return continuousDays;
  } catch (error) {
    console.error('计算连续学习天数失败:', error);
    return 0;
  }
};

// 检查管理员权限
const checkAdminPermission = async (ctx) => {
  try {
    const userId = ctx.state.user?.id;
    
    console.log('检查管理员权限，用户ID:', userId);
    
    if (!userId) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户ID不能为空',
        data: { isAdmin: false }
      };
      return;
    }
    
    // 从users表中查询用户的管理员权限
    const user = await User.findByPk(userId);
    
    console.log('用户查询结果:', user);
    
    if (!user) {
      console.log('用户不存在，用户ID:', userId);
      ctx.status = 404;
      ctx.body = {
        code: 404,
        message: '用户不存在',
        data: { isAdmin: false }
      };
      return;
    }
    
    const isAdmin = user.isAdmin === true;
    
    console.log('用户信息:', {
      userId: user.id,
      nickName: user.nickName,
      phoneNumber: user.phoneNumber,
      isAdmin: user.isAdmin
    });
    
    ctx.body = {
      code: 200,
      message: isAdmin ? '用户是管理员' : '用户不是管理员',
      data: { 
        isAdmin: isAdmin,
        userId: userId,
        userInfo: {
          nickName: user.nickName,
          phoneNumber: user.phoneNumber
        }
      }
    };
  } catch (error) {
    console.error('检查管理员权限失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '检查管理员权限失败',
      error: error.message,
      data: { isAdmin: false }
    };
  }
};

// 管理员登录
const adminLogin = async (ctx) => {
  try {
    const { username, password } = ctx.request.body;

    if (!username || !password) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户名和密码不能为空'
      };
      return;
    }

    // 查找管理员用户（通过用户名或手机号）
    const user = await User.findOne({ 
      where: { 
        [require('sequelize').Op.or]: [
          { nickName: username },
          { phoneNumber: username }
        ]
      } 
    });

    if (!user) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: '用户不存在'
      };
      return;
    }

    // 检查是否为管理员
    if (!user.isAdmin) {
      ctx.status = 403;
      ctx.body = {
        code: 403,
        message: '权限不足，仅限管理员登录'
      };
      return;
    }

    // 验证密码
    const isValidPassword = await user.validatePassword(password);
    if (!isValidPassword) {
      ctx.status = 400;
      ctx.body = {
        code: 400,
        message: user.password ? '密码错误' : '管理员用户需要设置密码'
      };
      return;
    }

    // 生成token
    const token = generateToken({ userId: user.id });

    ctx.body = {
      code: 200,
      message: '登录成功',
      data: {
        token,
        user: {
          id: user.id,
          nickName: user.nickName,
          phoneNumber: user.phoneNumber,
          isAdmin: user.isAdmin
        }
      }
    };
  } catch (error) {
    console.error('管理员登录失败:', error);
    ctx.status = 500;
    ctx.body = {
      code: 500,
      message: '登录失败',
      error: error.message
    };
  }
};

module.exports = {
  register,
  login,
  adminLogin,
  wechatLogin,
  getUserInfo,
  updateUserInfo,
  sendVerificationCode,
  loginWithVerificationCode,
  loginWithPhone,
  getStats,
  checkAdminPermission
};
