const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ActivationCode = sequelize.define('ActivationCode', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    comment: '激活码ID'
  },
  code: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    comment: '激活码'
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    comment: '激活码名称'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '激活码描述'
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '绑定的用户ID，null表示未绑定'
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'used'),
    allowNull: false,
    defaultValue: 'active',
    comment: '状态：active-有效，inactive-无效，used-已使用'
  },
  expiresAt: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '过期时间'
  },
  usedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '使用时间'
  },
  createdBy: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '创建者ID'
  }
}, {
  tableName: 'activation_codes',
  underscored: true,
  timestamps: true,
  comment: '激活码表'
});

module.exports = ActivationCode;
