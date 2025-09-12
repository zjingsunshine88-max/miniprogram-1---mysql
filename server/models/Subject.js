const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/database')

const Subject = sequelize.define('Subject', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false,
    comment: '科目名称'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '科目描述'
  },
  questionBankId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '所属题库ID'
    // 暂时不添加外键约束，避免数据迁移问题
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active',
    comment: '科目状态'
  },
  createdBy: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '创建者ID'
    // 暂时不添加外键约束，避免数据迁移问题
  }
}, {
  tableName: 'subjects',
  underscored: true,
  timestamps: true,
  comment: '科目表'
})

module.exports = Subject
