const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const VerificationCode = sequelize.define('VerificationCode', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  phoneNumber: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: '手机号'
  },
  code: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: '验证码'
  },
  used: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    comment: '是否已使用'
  },
  useTime: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '使用时间'
  },
  expireTime: {
    type: DataTypes.DATE,
    allowNull: false,
    comment: '过期时间'
  }
}, {
  tableName: 'verification_codes',
  comment: '验证码表'
});

module.exports = VerificationCode;
