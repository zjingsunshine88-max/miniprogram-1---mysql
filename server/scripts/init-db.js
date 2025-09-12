const { sequelize, testConnection } = require('../config/database');
const { User, Question, UserRecord, Favorite } = require('../models');

// 初始化数据库
const initDatabase = async () => {
  try {
    console.log('🔄 开始初始化数据库...');

    // 测试数据库连接
    const isConnected = await testConnection();
    if (!isConnected) {
      console.error('❌ 数据库连接失败，请检查配置');
      process.exit(1);
    }

    // 同步所有模型到数据库
    await sequelize.sync({ force: true });
    console.log('✅ 数据库表创建成功');

    // 创建默认管理员用户
    const adminUser = await User.create({
      nickname: '管理员',
      phone: '13800138000',
      email: 'admin@example.com',
      password: 'admin123',
      role: 'admin',
      status: 'active'
    });
    console.log('✅ 默认管理员用户创建成功');

    // 创建测试用户
    const testUser = await User.create({
      nickname: '测试用户',
      phone: '13800138001',
      email: 'test@example.com',
      password: 'test123',
      role: 'user',
      status: 'active'
    });
    console.log('✅ 测试用户创建成功');

    // 创建测试题目数据
    const testQuestions = [
      {
        subject: '物理',
        chapter: '力学',
        type: '单选题',
        difficulty: '中等',
        content: '一个质量为2kg的物体在水平面上受到10N的水平拉力，如果摩擦系数为0.3，求物体的加速度。',
        option_a: '2 m/s²',
        option_b: '3 m/s²',
        option_c: '4 m/s²',
        option_d: '5 m/s²',
        answer: 'C',
        analysis: '根据牛顿第二定律：F - μmg = ma，代入数据：10 - 0.3×2×9.8 = 2a，解得a = 4 m/s²',
        created_by: adminUser.id
      },
      {
        subject: '物理',
        chapter: '电磁学',
        type: '单选题',
        difficulty: '中等',
        content: '在匀强磁场中，一个带电粒子以速度v垂直于磁场方向运动，粒子受到的洛伦兹力大小为多少？',
        option_a: '0',
        option_b: 'qvB',
        option_c: 'qvB/2',
        option_d: '2qvB',
        answer: 'B',
        analysis: '洛伦兹力公式：F = qvBsinθ，当θ=90°时，F = qvB',
        created_by: adminUser.id
      },
      {
        subject: '数学',
        chapter: '函数与导数',
        type: '单选题',
        difficulty: '中等',
        content: '已知函数 f(x) = x³ - 3x² + 2x + 1，在点 x = 1 处的导数为多少？',
        option_a: '0',
        option_b: '1',
        option_c: '2',
        option_d: '3',
        answer: 'B',
        analysis: '首先求导 f\'(x) = 3x² - 6x + 2，将 x = 1 代入得 f\'(1) = 3 - 6 + 2 = -1 + 2 = 1，因此答案为 B。',
        created_by: adminUser.id
      },
      {
        subject: '数学',
        chapter: '极限与连续',
        type: '单选题',
        difficulty: '简单',
        content: '求极限 lim(x→0) (sin x) / x 的值。',
        option_a: '0',
        option_b: '1',
        option_c: '∞',
        option_d: '不存在',
        answer: 'B',
        analysis: '这是一个重要的极限，lim(x→0) (sin x) / x = 1，这是基本极限之一。',
        created_by: adminUser.id
      },
      {
        subject: '英语',
        chapter: '阅读理解',
        type: '单选题',
        difficulty: '中等',
        content: 'What is the main idea of the passage?',
        option_a: 'The importance of education',
        option_b: 'The benefits of reading',
        option_c: 'The history of literature',
        option_d: 'The future of technology',
        answer: 'B',
        analysis: '根据文章内容，主要讨论的是阅读的好处和重要性。',
        created_by: adminUser.id
      }
    ];

    await Question.bulkCreate(testQuestions);
    console.log('✅ 测试题目数据创建成功');

    // 创建一些测试答题记录
    const testRecords = [
      {
        userId: testUser.id,
        questionId: 1,
        userAnswer: 'C',
        isCorrect: true,
        timeSpent: 30,
        mode: 'random'
      },
      {
        userId: testUser.id,
        questionId: 2,
        userAnswer: 'A',
        isCorrect: false,
        timeSpent: 45,
        mode: 'random'
      },
      {
        userId: testUser.id,
        questionId: 3,
        userAnswer: 'B',
        isCorrect: true,
        timeSpent: 60,
        mode: 'sequential'
      }
    ];

    await UserRecord.bulkCreate(testRecords);
    console.log('✅ 测试答题记录创建成功');

    // 创建一些收藏记录
    const testFavorites = [
      {
        userId: testUser.id,
        questionId: 1,
        note: '这道题很有意思'
      },
      {
        userId: testUser.id,
        questionId: 3,
        note: '需要重点复习'
      }
    ];

    await Favorite.bulkCreate(testFavorites);
    console.log('✅ 测试收藏记录创建成功');

    console.log('🎉 数据库初始化完成！');
    console.log('\n📋 默认账户信息：');
    console.log('管理员账户：');
    console.log('  手机号：13800138000');
    console.log('  密码：admin123');
    console.log('\n测试用户账户：');
    console.log('  手机号：13800138001');
    console.log('  密码：test123');

    process.exit(0);
  } catch (error) {
    console.error('❌ 数据库初始化失败:', error);
    process.exit(1);
  }
};

// 运行初始化
initDatabase();
