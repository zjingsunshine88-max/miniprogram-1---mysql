const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const UserRecord = sequelize.define('UserRecord', {
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
  isCorrect: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    comment: '是否正确'
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
  },
  timeSpent: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '答题用时（秒）'
  },
  mode: {
    type: DataTypes.ENUM('random', 'sequential', 'error', 'favorite'),
    allowNull: true,
    comment: '答题模式'
  },
  sessionId: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '答题会话ID'
  }
}, {
  tableName: 'answer_records',
  comment: '用户答题记录表'
});

module.exports = UserRecord;
