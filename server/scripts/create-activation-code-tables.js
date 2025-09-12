const { up } = require('../migrations/002_create_activation_code_tables');

async function runMigration() {
  try {
    console.log('开始运行激活码表迁移...');
    await up();
    console.log('激活码表迁移完成！');
    process.exit(0);
  } catch (error) {
    console.error('迁移失败:', error);
    process.exit(1);
  }
}

runMigration();
