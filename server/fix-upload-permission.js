#!/usr/bin/env node

const fs = require('fs')
const path = require('path')

console.log('🔧 修复题目上传权限问题...')

// 需要创建的目录
const directories = [
  path.join(__dirname, 'temp'),
  path.join(__dirname, 'public'),
  path.join(__dirname, 'public/uploads'),
  path.join(__dirname, 'public/uploads/images')
]

// 创建目录的函数
async function createDirectory(dirPath) {
  try {
    // 检查目录是否存在
    if (fs.existsSync(dirPath)) {
      console.log(`✅ 目录已存在: ${dirPath}`)
      
      // 检查目录权限
      try {
        fs.accessSync(dirPath, fs.constants.R_OK | fs.constants.W_OK)
        console.log(`✅ 目录权限正常: ${dirPath}`)
      } catch (error) {
        console.log(`⚠️  目录权限不足: ${dirPath}`)
        console.log(`   错误: ${error.message}`)
      }
    } else {
      // 创建目录
      console.log(`📁 创建目录: ${dirPath}`)
      await fs.promises.mkdir(dirPath, { recursive: true })
      console.log(`✅ 目录创建成功: ${dirPath}`)
    }
  } catch (error) {
    console.error(`❌ 目录操作失败: ${dirPath}`)
    console.error(`   错误: ${error.message}`)
  }
}

// 修复权限的函数
async function fixPermissions(dirPath) {
  try {
    // 在Windows上无法使用chmod
    if (process.platform === 'win32') {
      console.log(`ℹ️  Windows系统，跳过权限设置: ${dirPath}`)
      return
    }
    
    // 设置目录权限为 755
    await fs.promises.chmod(dirPath, 0o755)
    console.log(`✅ 权限设置成功: ${dirPath} (755)`)
  } catch (error) {
    console.log(`⚠️  权限设置失败: ${dirPath}`)
    console.log(`   错误: ${error.message}`)
  }
}

// 主函数
async function main() {
  console.log('🚀 开始修复题目上传权限问题...\n')
  
  // 创建所有需要的目录
  for (const dir of directories) {
    await createDirectory(dir)
  }
  
  console.log('\n📝 设置目录权限...')
  
  // 设置目录权限
  for (const dir of directories) {
    if (fs.existsSync(dir)) {
      await fixPermissions(dir)
    }
  }
  
  console.log('\n📊 检查结果:')
  
  // 检查每个目录
  for (const dir of directories) {
    const exists = fs.existsSync(dir)
    const readable = exists ? fs.constants.R_OK : false
    const writable = exists ? fs.constants.W_OK : false
    
    console.log(`\n目录: ${dir}`)
    console.log(`  存在: ${exists ? '✅' : '❌'}`)
    
    if (exists) {
      try {
        fs.accessSync(dir, fs.constants.R_OK | fs.constants.W_OK)
        console.log(`  权限: ✅ 可读写`)
      } catch (error) {
        console.log(`  权限: ❌ 不可读写`)
        console.log(`  错误: ${error.message}`)
      }
    }
  }
  
  console.log('\n💡 如果权限问题仍然存在，请手动执行以下命令:')
  console.log('\n在宝塔面板终端中执行:')
  console.log('cd /www/wwwroot')
  console.log('mkdir -p temp public/uploads/images')
  console.log('chmod -R 755 temp public/uploads')
  console.log('chown -R www:www temp public/uploads')
  
  console.log('\n或者使用宝塔面板文件管理器:')
  console.log('1. 打开宝塔面板文件管理器')
  console.log('2. 进入 /www/wwwroot 目录')
  console.log('3. 创建 temp 目录')
  console.log('4. 创建 public/uploads/images 目录')
  console.log('5. 设置目录权限为 755')
}

// 运行修复
main().catch(error => {
  console.error('❌ 修复过程中出现错误:', error)
  process.exit(1)
})
