const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Question = sequelize.define('Question', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  questionBankId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '所属题库ID'
    // 暂时不添加外键约束，避免数据迁移问题
  },
  subjectId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '所属科目ID'
    // 暂时不添加外键约束，避免数据迁移问题
  },
  chapter: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '章节'
  },
  type: {
    type: DataTypes.ENUM('单选题', '多选题', '判断题', '填空题'),
    allowNull: false,
    comment: '题目类型'
  },
  difficulty: {
    type: DataTypes.ENUM('简单', '中等', '困难'),
    defaultValue: '中等',
    comment: '难度等级'
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
    comment: '题目内容'
  },
  options: {
    type: DataTypes.JSON,
    allowNull: true,
    comment: '选项（JSON格式）'
  },
  optionA: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '选项A'
  },
  optionB: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '选项B'
  },
  optionC: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '选项C'
  },
  optionD: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '选项D'
  },
  answer: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: '正确答案'
  },
  analysis: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '解析'
  },
  images: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '题目图片（JSON格式）'
  },
  tags: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '标签（JSON格式）'
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active',
    comment: '题目状态'
  },
  createBy: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '创建者ID'
  }
}, {
  tableName: 'questions',
  underscored: true,
  timestamps: true,
  comment: '题目表'
});

module.exports = Question;
