const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const bcrypt = require('bcryptjs');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  openid: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: true,
    comment: '微信openid'
  },
  unionid: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '微信unionid'
  },
  phoneNumber: {
    type: DataTypes.STRING,
    allowNull: true,
    unique: true,
    comment: '手机号'
  },
  nickName: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '用户昵称'
  },
  avatarUrl: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '头像URL'
  },
  gender: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '性别'
  },
  country: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '国家'
  },
  province: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '省份'
  },
  city: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '城市'
  },
  email: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '邮箱'
  },
  password: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '密码（加密）'
  },
  isAdmin: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    comment: '是否为管理员'
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active',
    comment: '用户状态'
  },
  lastLoginTime: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '最后登录时间'
  }
}, {
  tableName: 'users',
  comment: '用户表'
});

// 密码加密中间件
User.beforeCreate(async (user) => {
  if (user.password) {
    user.password = await bcrypt.hash(user.password, 10);
  }
});

// 密码验证方法
User.prototype.validatePassword = async function(password) {
  return await bcrypt.compare(password, this.password);
};

module.exports = User;
