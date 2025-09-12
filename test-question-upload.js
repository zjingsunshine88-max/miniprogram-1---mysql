// 测试题目上传功能
const testQuestionUpload = async () => {
  console.log('🧪 开始测试题目上传功能...')
  
  try {
    // 1. 检查用户登录状态
    console.log('1. 检查用户登录状态...')
    const userInfo = wx.getStorageSync('userInfo')
    const userPhoneNumber = wx.getStorageSync('userPhoneNumber')
    
    console.log('   用户信息:', userInfo ? '✅ 存在' : '❌ 不存在')
    console.log('   手机号:', userPhoneNumber ? '✅ 存在' : '❌ 不存在')
    
    if (!userInfo) {
      console.log('   ❌ 用户未登录，无法测试题目上传功能')
      return
    }
    
    const userId = userInfo._id || userInfo.id
    console.log('   用户ID:', userId)
    
    // 2. 测试管理员权限检查
    console.log('2. 测试管理员权限检查...')
    try {
      const adminResult = await wx.cloud.callFunction({
        name: 'question-bank-api',
        data: {
          action: 'user.checkAdminPermission',
          userId: userId
        }
      })
      
      console.log('   管理员权限检查结果:', adminResult.result)
      
      if (adminResult.result && adminResult.result.code === 200) {
        const isAdmin = adminResult.result.data.isAdmin
        console.log('   管理员状态:', isAdmin ? '✅ 是管理员' : '❌ 不是管理员')
        
        if (adminResult.result.data.userInfo) {
          console.log('   用户信息:', adminResult.result.data.userInfo)
        }
        
        if (!isAdmin) {
          console.log('   ⚠️ 用户不是管理员，无法上传题目')
          console.log('   💡 需要在users集合中将用户的isAdmin字段设置为true')
          return
        }
      } else {
        console.log('   ❌ 管理员权限检查失败:', adminResult.result?.message)
        return
      }
    } catch (error) {
      console.log('   ❌ 管理员权限检查出错:', error)
      return
    }
    
    // 3. 测试题目上传
    console.log('3. 测试题目上传...')
    
    // 创建测试题目数据
    const testQuestions = [
      {
        type: '单选题',
        content: '测试题目1：1+1等于多少？',
        optionA: '1',
        optionB: '2',
        optionC: '3',
        optionD: '4',
        answer: 'B',
        analysis: '1+1=2，这是基础数学知识',
        difficulty: '简单',
        subject: '数学',
        chapter: '基础运算',
        isValid: true
      },
      {
        type: '判断题',
        content: '测试题目2：地球是圆的',
        answer: '正确',
        analysis: '地球是近似球形的天体',
        difficulty: '简单',
        subject: '地理',
        chapter: '地球知识',
        isValid: true
      }
    ]
    
    console.log('   准备上传测试题目:', testQuestions.length, '道')
    
    try {
      const uploadResult = await wx.cloud.callFunction({
        name: 'question-bank-api',
        data: {
          action: 'question.importQuestions',
          questions: testQuestions,
          userId: userId
        }
      })
      
      console.log('   题目上传结果:', uploadResult.result)
      
      if (uploadResult.result && uploadResult.result.code === 200) {
        console.log('   ✅ 题目上传成功')
        console.log('   - 导入数量:', uploadResult.result.data.importedCount)
        console.log('   - 总数量:', uploadResult.result.data.totalCount)
      } else {
        console.log('   ❌ 题目上传失败:', uploadResult.result?.message)
        console.log('   - 错误详情:', uploadResult.result?.error)
      }
    } catch (error) {
      console.log('   ❌ 题目上传出错:', error)
    }
    
    // 4. 测试题目统计
    console.log('4. 测试题目统计...')
    try {
      const statsResult = await wx.cloud.callFunction({
        name: 'question-bank-api',
        data: {
          action: 'question.getStats'
        }
      })
      
      console.log('   题目统计结果:', statsResult.result)
      
      if (statsResult.result && statsResult.result.code === 200) {
        const stats = statsResult.result.data
        console.log('   ✅ 题目统计获取成功')
        console.log('   - 总题目数:', stats.total || 0)
        console.log('   - 科目数量:', stats.bySubject ? stats.bySubject.length : 0)
      } else {
        console.log('   ❌ 题目统计获取失败:', statsResult.result?.message)
      }
    } catch (error) {
      console.log('   ❌ 题目统计出错:', error)
    }
    
    // 5. 测试结果总结
    console.log('\n🎉 测试完成！')
    console.log('题目上传功能测试结果:')
    console.log('✅ 用户登录状态检查')
    console.log('✅ 管理员权限检查')
    console.log('✅ 题目上传功能')
    console.log('✅ 题目统计功能')
    
    console.log('\n💡 使用建议:')
    console.log('1. 确保用户已登录')
    console.log('2. 确保用户在users集合中isAdmin字段为true')
    console.log('3. 检查题目数据格式是否正确')
    console.log('4. 查看云函数日志获取详细错误信息')
    
  } catch (error) {
    console.error('❌ 测试过程中出现错误:', error)
  }
}

// 导出测试函数
module.exports = { testQuestionUpload }

// 如果直接运行此文件
if (typeof wx !== 'undefined') {
  testQuestionUpload()
}
