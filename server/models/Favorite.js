const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Favorite = sequelize.define('Favorite', {
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
    comment: '收藏时间戳'
  },
  note: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '收藏备注'
  }
}, {
  tableName: 'favorites',
  comment: '收藏表'
});

module.exports = Favorite;
