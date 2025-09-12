const { sequelize } = require('../config/database')

async function migrateDatabase() {
  try {
    console.log('开始数据库迁移...')
    
    // 1. 创建题库表
    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS question_banks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL COMMENT '题库名称',
        description TEXT COMMENT '题库描述',
        status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '题库状态',
        created_by INT NOT NULL COMMENT '创建者ID',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_created_by (created_by),
        INDEX idx_status (status)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题库表'
    `)
    console.log('✅ 题库表创建成功')

    // 2. 创建科目表
    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS subjects (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL COMMENT '科目名称',
        description TEXT COMMENT '科目描述',
        question_bank_id INT NOT NULL COMMENT '所属题库ID',
        status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '科目状态',
        created_by INT NOT NULL COMMENT '创建者ID',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_question_bank_id (question_bank_id),
        INDEX idx_created_by (created_by),
        INDEX idx_status (status),
        FOREIGN KEY (question_bank_id) REFERENCES question_banks(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='科目表'
    `)
    console.log('✅ 科目表创建成功')

    // 3. 备份现有题目数据
    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS questions_backup AS 
      SELECT * FROM questions
    `)
    console.log('✅ 题目数据备份成功')

    // 4. 修改题目表结构
    await sequelize.query(`
      ALTER TABLE questions 
      ADD COLUMN question_bank_id INT COMMENT '所属题库ID' AFTER id,
      ADD COLUMN subject_id INT COMMENT '所属科目ID' AFTER question_bank_id
    `)
    console.log('✅ 题目表结构更新成功')

    // 5. 创建默认题库和科目
    const [questionBankResult] = await sequelize.query(`
      INSERT INTO question_banks (name, description, created_by) 
      VALUES ('默认题库', '系统默认题库', 1)
      ON DUPLICATE KEY UPDATE name = name
    `)
    console.log('✅ 默认题库创建成功')

    // 获取默认题库ID
    const [defaultBank] = await sequelize.query(`
      SELECT id FROM question_banks WHERE name = '默认题库' LIMIT 1
    `)
    const defaultBankId = defaultBank[0]?.id

    if (defaultBankId) {
      // 创建默认科目
      const subjects = ['数学', '语文', '英语', '物理', '化学', '生物', '历史', '地理', '政治', '计算机']
      
      for (const subjectName of subjects) {
        await sequelize.query(`
          INSERT INTO subjects (name, question_bank_id, created_by) 
          VALUES (?, ?, 1)
          ON DUPLICATE KEY UPDATE name = name
        `, {
          replacements: [subjectName, defaultBankId]
        })
      }
      console.log('✅ 默认科目创建成功')

      // 6. 迁移现有题目数据
      const [existingQuestions] = await sequelize.query(`
        SELECT id, subject FROM questions WHERE subject IS NOT NULL
      `)

      for (const question of existingQuestions) {
        // 查找对应的科目ID
        const [subjectResult] = await sequelize.query(`
          SELECT id FROM subjects WHERE name = ? AND question_bank_id = ?
        `, {
          replacements: [question.subject, defaultBankId]
        })

        if (subjectResult.length > 0) {
          const subjectId = subjectResult[0].id
          
          // 更新题目记录
          await sequelize.query(`
            UPDATE questions 
            SET question_bank_id = ?, subject_id = ?
            WHERE id = ?
          `, {
            replacements: [defaultBankId, subjectId, question.id]
          })
        }
      }
      console.log('✅ 现有题目数据迁移成功')
    }

    // 7. 添加外键约束
    await sequelize.query(`
      ALTER TABLE questions 
      ADD CONSTRAINT fk_questions_question_bank 
      FOREIGN KEY (question_bank_id) REFERENCES question_banks(id) ON DELETE CASCADE
    `)

    await sequelize.query(`
      ALTER TABLE questions 
      ADD CONSTRAINT fk_questions_subject 
      FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
    `)
    console.log('✅ 外键约束添加成功')

    // 8. 删除旧的subject字段（可选，保留作为备份）
    // await sequelize.query(`ALTER TABLE questions DROP COLUMN subject`)
    // console.log('✅ 旧字段清理完成')

    console.log('🎉 数据库迁移完成！')
    
  } catch (error) {
    console.error('❌ 数据库迁移失败:', error)
    throw error
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  migrateDatabase()
    .then(() => {
      console.log('迁移完成，退出进程')
      process.exit(0)
    })
    .catch((error) => {
      console.error('迁移失败:', error)
      process.exit(1)
    })
}

module.exports = migrateDatabase
