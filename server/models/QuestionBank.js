const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/database')

const QuestionBank = sequelize.define('QuestionBank', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    comment: '题库名称'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '题库描述'
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active',
    comment: '题库状态'
  },
  createdBy: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '创建者ID'
    // 暂时不添加外键约束，避免数据迁移问题
  }
}, {
  tableName: 'question_banks',
  underscored: true,
  timestamps: true,
  comment: '题库表'
})

module.exports = QuestionBank
