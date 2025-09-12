const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ErrorRecord = sequelize.define('ErrorRecord', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '用户ID'
  },
  questionId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '题目ID'
  },
  questionContent: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '题目内容'
  },
  userAnswer: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '用户答案'
  },
  correctAnswer: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '正确答案'
  },
  subject: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '科目'
  },
  chapter: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '章节'
  },
  timestamp: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '答题时间戳'
  }
}, {
  tableName: 'error_records',
  comment: '错题记录表'
});

module.exports = ErrorRecord;
