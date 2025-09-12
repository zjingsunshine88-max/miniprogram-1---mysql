const { sequelize } = require('../config/database');

async function up() {
  const queryInterface = sequelize.getQueryInterface();
  
  try {
    console.log('开始创建激活码相关表...');
    
    // 创建激活码表
    await queryInterface.createTable('activation_codes', {
      id: {
        type: 'INTEGER',
        primaryKey: true,
        autoIncrement: true,
        comment: '激活码ID'
      },
      code: {
        type: 'VARCHAR(50)',
        allowNull: false,
        unique: true,
        comment: '激活码'
      },
      name: {
        type: 'VARCHAR(100)',
        allowNull: false,
        comment: '激活码名称'
      },
      description: {
        type: 'TEXT',
        allowNull: true,
        comment: '激活码描述'
      },
      user_id: {
        type: 'INTEGER',
        allowNull: true,
        comment: '绑定的用户ID，null表示未绑定'
      },
      status: {
        type: 'ENUM("active", "inactive", "used")',
        allowNull: false,
        defaultValue: 'active',
        comment: '状态：active-有效，inactive-无效，used-已使用'
      },
      expires_at: {
        type: 'DATETIME',
        allowNull: true,
        comment: '过期时间'
      },
      used_at: {
        type: 'DATETIME',
        allowNull: true,
        comment: '使用时间'
      },
      created_by: {
        type: 'INTEGER',
        allowNull: false,
        comment: '创建者ID'
      },
      created_at: {
        type: 'DATETIME',
        allowNull: false,
        defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: 'DATETIME',
        allowNull: false,
        defaultValue: sequelize.literal('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP')
      }
    });

    // 创建激活码科目关联表
    await queryInterface.createTable('activation_code_subjects', {
      id: {
        type: 'INTEGER',
        primaryKey: true,
        autoIncrement: true,
        comment: '关联ID'
      },
      activation_code_id: {
        type: 'INTEGER',
        allowNull: false,
        comment: '激活码ID'
      },
      subject_id: {
        type: 'INTEGER',
        allowNull: false,
        comment: '科目ID'
      },
      created_at: {
        type: 'DATETIME',
        allowNull: false,
        defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: 'DATETIME',
        allowNull: false,
        defaultValue: sequelize.literal('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP')
      }
    });

    // 添加外键约束
    await queryInterface.addConstraint('activation_codes', {
      fields: ['user_id'],
      type: 'foreign key',
      name: 'fk_activation_codes_user_id',
      references: {
        table: 'users',
        field: 'id'
      },
      onDelete: 'SET NULL',
      onUpdate: 'CASCADE'
    });

    await queryInterface.addConstraint('activation_codes', {
      fields: ['created_by'],
      type: 'foreign key',
      name: 'fk_activation_codes_created_by',
      references: {
        table: 'users',
        field: 'id'
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE'
    });

    await queryInterface.addConstraint('activation_code_subjects', {
      fields: ['activation_code_id'],
      type: 'foreign key',
      name: 'fk_activation_code_subjects_activation_code_id',
      references: {
        table: 'activation_codes',
        field: 'id'
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE'
    });

    await queryInterface.addConstraint('activation_code_subjects', {
      fields: ['subject_id'],
      type: 'foreign key',
      name: 'fk_activation_code_subjects_subject_id',
      references: {
        table: 'subjects',
        field: 'id'
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE'
    });

    // 添加唯一约束
    await queryInterface.addConstraint('activation_code_subjects', {
      fields: ['activation_code_id', 'subject_id'],
      type: 'unique',
      name: 'uk_activation_code_subjects'
    });

    console.log('激活码相关表创建成功！');
  } catch (error) {
    console.error('创建激活码表失败:', error);
    throw error;
  }
}

async function down() {
  const queryInterface = sequelize.getQueryInterface();
  
  try {
    console.log('开始删除激活码相关表...');
    
    // 删除外键约束
    await queryInterface.removeConstraint('activation_code_subjects', 'fk_activation_code_subjects_subject_id');
    await queryInterface.removeConstraint('activation_code_subjects', 'fk_activation_code_subjects_activation_code_id');
    await queryInterface.removeConstraint('activation_codes', 'fk_activation_codes_created_by');
    await queryInterface.removeConstraint('activation_codes', 'fk_activation_codes_user_id');
    
    // 删除表
    await queryInterface.dropTable('activation_code_subjects');
    await queryInterface.dropTable('activation_codes');
    
    console.log('激活码相关表删除成功！');
  } catch (error) {
    console.error('删除激活码表失败:', error);
    throw error;
  }
}

module.exports = { up, down };
