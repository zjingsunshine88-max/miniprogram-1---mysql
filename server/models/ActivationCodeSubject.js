const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ActivationCodeSubject = sequelize.define('ActivationCodeSubject', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    comment: '关联ID'
  },
  activationCodeId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '激活码ID'
  },
  subjectId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '科目ID'
  }
}, {
  tableName: 'activation_code_subjects',
  underscored: true,
  timestamps: true,
  comment: '激活码科目关联表'
});

module.exports = ActivationCodeSubject;
