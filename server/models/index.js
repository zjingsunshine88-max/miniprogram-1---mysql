const User = require('./User');
const Question = require('./Question');
const UserRecord = require('./UserRecord');
const Favorite = require('./Favorite');
const VerificationCode = require('./VerificationCode');
const ErrorRecord = require('./ErrorRecord');

// 定义模型关联关系
User.hasMany(UserRecord, { foreignKey: 'userId', as: 'records' });
UserRecord.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(Favorite, { foreignKey: 'userId', as: 'favorites' });
Favorite.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(ErrorRecord, { foreignKey: 'userId', as: 'errorRecords' });
ErrorRecord.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Question.hasMany(UserRecord, { foreignKey: 'questionId', as: 'records' });
UserRecord.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

Question.hasMany(Favorite, { foreignKey: 'questionId', as: 'favorites' });
Favorite.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

Question.hasMany(ErrorRecord, { foreignKey: 'questionId', as: 'errorRecords' });
ErrorRecord.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

User.hasMany(Question, { foreignKey: 'createBy', as: 'createdQuestions' });
Question.belongsTo(User, { foreignKey: 'createBy', as: 'creator' });

module.exports = {
  User,
  Question,
  UserRecord,
  Favorite,
  VerificationCode,
  ErrorRecord
};
