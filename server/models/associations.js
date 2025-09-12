const QuestionBank = require('./QuestionBank')
const Subject = require('./Subject')
const Question = require('./Question')
const User = require('./User')
const ActivationCode = require('./ActivationCode')
const ActivationCodeSubject = require('./ActivationCodeSubject')

// 定义模型关联关系

// 题库与科目的关系：一个题库包含多个科目
QuestionBank.hasMany(Subject, {
  foreignKey: 'questionBankId',
  as: 'subjects'
})

Subject.belongsTo(QuestionBank, {
  foreignKey: 'questionBankId',
  as: 'questionBank'
})

// 科目与题目的关系：一个科目包含多个题目
Subject.hasMany(Question, {
  foreignKey: 'subjectId',
  as: 'questions'
})

Question.belongsTo(Subject, {
  foreignKey: 'subjectId',
  as: 'subject'
})

// 题库与题目的关系：一个题库包含多个题目
QuestionBank.hasMany(Question, {
  foreignKey: 'questionBankId',
  as: 'questions'
})

Question.belongsTo(QuestionBank, {
  foreignKey: 'questionBankId',
  as: 'questionBank'
})

// 用户与题库的关系：一个用户可以创建多个题库
User.hasMany(QuestionBank, {
  foreignKey: 'createdBy',
  as: 'questionBanks'
})

QuestionBank.belongsTo(User, {
  foreignKey: 'createdBy',
  as: 'creator'
})

// 用户与科目的关系：一个用户可以创建多个科目
User.hasMany(Subject, {
  foreignKey: 'createdBy',
  as: 'subjects'
})

Subject.belongsTo(User, {
  foreignKey: 'createdBy',
  as: 'creator'
})

// 激活码与用户的关系：一个激活码绑定一个用户
ActivationCode.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
})

User.hasMany(ActivationCode, {
  foreignKey: 'userId',
  as: 'activationCodes'
})

// 激活码与创建者的关系
ActivationCode.belongsTo(User, {
  foreignKey: 'createdBy',
  as: 'creator'
})

User.hasMany(ActivationCode, {
  foreignKey: 'createdBy',
  as: 'createdActivationCodes'
})

// 激活码与科目的多对多关系
ActivationCode.belongsToMany(Subject, {
  through: ActivationCodeSubject,
  foreignKey: 'activationCodeId',
  otherKey: 'subjectId',
  as: 'subjects'
})

Subject.belongsToMany(ActivationCode, {
  through: ActivationCodeSubject,
  foreignKey: 'subjectId',
  otherKey: 'activationCodeId',
  as: 'activationCodes'
})

module.exports = {
  QuestionBank,
  Subject,
  Question,
  User,
  ActivationCode,
  ActivationCodeSubject
}
