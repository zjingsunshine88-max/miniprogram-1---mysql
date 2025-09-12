const { sequelize } = require('../config/database')

async function resetDatabase() {
  try {
    console.log('开始重置数据库...')
    
    // 删除现有表（如果存在）- 按依赖关系顺序删除
    await sequelize.query('DROP TABLE IF EXISTS answer_records')
    await sequelize.query('DROP TABLE IF EXISTS error_records')
    await sequelize.query('DROP TABLE IF EXISTS favorites')
    await sequelize.query('DROP TABLE IF EXISTS user_records')
    await sequelize.query('DROP TABLE IF EXISTS questions')
    await sequelize.query('DROP TABLE IF EXISTS subjects')
    await sequelize.query('DROP TABLE IF EXISTS question_banks')
    console.log('✅ 删除现有表成功')
    
    // 重新创建表
    await sequelize.query(`
      CREATE TABLE question_banks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL COMMENT '题库名称',
        description TEXT COMMENT '题库描述',
        status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '题库状态',
        created_by INT NOT NULL COMMENT '创建者ID',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题库表'
    `)
    console.log('✅ 题库表创建成功')

    await sequelize.query(`
      CREATE TABLE subjects (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL COMMENT '科目名称',
        description TEXT COMMENT '科目描述',
        question_bank_id INT NOT NULL COMMENT '所属题库ID',
        status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '科目状态',
        created_by INT NOT NULL COMMENT '创建者ID',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='科目表'
    `)
    console.log('✅ 科目表创建成功')

    await sequelize.query(`
      CREATE TABLE questions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        question_bank_id INT NOT NULL COMMENT '所属题库ID',
        subject_id INT NOT NULL COMMENT '所属科目ID',
        chapter VARCHAR(255) COMMENT '章节',
        type ENUM('单选题', '多选题', '判断题', '填空题') NOT NULL COMMENT '题目类型',
        difficulty ENUM('简单', '中等', '困难') DEFAULT '中等' COMMENT '难度等级',
        content TEXT NOT NULL COMMENT '题目内容',
        options JSON COMMENT '选项（JSON格式）',
        optionA TEXT COMMENT '选项A',
        optionB TEXT COMMENT '选项B',
        optionC TEXT COMMENT '选项C',
        optionD TEXT COMMENT '选项D',
        answer VARCHAR(255) NOT NULL COMMENT '正确答案',
        analysis TEXT COMMENT '解析',
        tags VARCHAR(255) COMMENT '标签（JSON格式）',
        status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '题目状态',
        create_by INT COMMENT '创建者ID',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目表'
    `)
    console.log('✅ 题目表创建成功')

    // 创建默认题库和科目
    await sequelize.query(`
      INSERT INTO question_banks (name, description, created_by) 
      VALUES ('默认题库', '系统默认题库', 1)
    `)
    console.log('✅ 默认题库创建成功')

    const [defaultBank] = await sequelize.query(`
      SELECT id FROM question_banks WHERE name = '默认题库' LIMIT 1
    `)
    const defaultBankId = defaultBank[0]?.id

    if (defaultBankId) {
      const subjects = ['数学', '语文', '英语', '物理', '化学', '生物', '历史', '地理', '政治', '计算机']
      
      for (const subjectName of subjects) {
        await sequelize.query(`
          INSERT INTO subjects (name, question_bank_id, created_by) 
          VALUES (?, ?, 1)
        `, {
          replacements: [subjectName, defaultBankId]
        })
      }
      console.log('✅ 默认科目创建成功')
    }

    console.log('🎉 数据库重置完成！')
    
  } catch (error) {
    console.error('❌ 数据库重置失败:', error)
    throw error
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  resetDatabase()
    .then(() => {
      console.log('重置完成，退出进程')
      process.exit(0)
    })
    .catch((error) => {
      console.error('重置失败:', error)
      process.exit(1)
    })
}

module.exports = resetDatabase
