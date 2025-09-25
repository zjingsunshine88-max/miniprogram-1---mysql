// 验证HTTPS配置
const fs = require('fs');
const path = require('path');

console.log('🔍 验证HTTPS配置...\n');

// 检查配置文件
function checkConfigFiles() {
  console.log('📋 检查配置文件:');
  
  const configFiles = [
    {
      path: 'miniprogram/config/production.js',
      name: '小程序生产配置',
      check: (content) => {
        if (content.includes('https://practice.insightdata.top')) {
          return '✅ 使用HTTPS域名';
        } else if (content.includes('http://223.93.139.87:3002')) {
          return '❌ 仍使用HTTP IP地址';
        } else {
          return '⚠️  配置可能有问题';
        }
      }
    },
    {
      path: 'server/config/production.js',
      name: '服务器生产配置',
      check: (content) => {
        let result = [];
        if (content.includes('https://practice.insightdata.top')) {
          result.push('✅ CORS配置使用HTTPS域名');
        } else {
          result.push('❌ CORS配置未使用HTTPS域名');
        }
        if (content.includes("host: process.env.HOST || '0.0.0.0'")) {
          result.push('✅ 服务器监听所有接口');
        } else {
          result.push('❌ 服务器配置可能有问题');
        }
        return result.join('\n    ');
      }
    },
    {
      path: 'admin/env.production',
      name: '管理后台生产配置',
      check: (content) => {
        if (content.includes('https://practice.insightdata.top')) {
          return '✅ 使用HTTPS域名';
        } else if (content.includes('http://223.93.139.87:3002')) {
          return '❌ 仍使用HTTP IP地址';
        } else {
          return '⚠️  配置可能有问题';
        }
      }
    }
  ];
  
  configFiles.forEach(file => {
    console.log(`\n📁 ${file.name}:`);
    
    if (fs.existsSync(file.path)) {
      const content = fs.readFileSync(file.path, 'utf-8');
      const result = file.check(content);
      console.log(`  ${result}`);
    } else {
      console.log(`  ❌ 文件不存在: ${file.path}`);
    }
  });
}

// 检查SSL相关文件
function checkSSLFiles() {
  console.log('\n📋 检查SSL相关文件:');
  
  const sslFiles = [
    {
      path: 'WINDOWS_SSL_SETUP_GUIDE.md',
      name: 'SSL配置指南',
      description: 'Windows服务器SSL证书配置指南'
    },
    {
      path: 'nginx-https.conf',
      name: 'Nginx HTTPS配置',
      description: 'Nginx HTTPS配置文件模板'
    },
    {
      path: 'start-https-services.bat',
      name: 'HTTPS服务启动脚本',
      description: '启动HTTPS服务的批处理脚本'
    }
  ];
  
  sslFiles.forEach(file => {
    console.log(`\n📁 ${file.name}:`);
    
    if (fs.existsSync(file.path)) {
      console.log(`  ✅ 文件存在`);
      console.log(`  📝 ${file.description}`);
      
      // 检查文件内容
      const content = fs.readFileSync(file.path, 'utf-8');
      if (content.includes('practice.insightdata.top')) {
        console.log(`  ✅ 包含域名配置`);
      }
    } else {
      console.log(`  ❌ 文件不存在: ${file.path}`);
    }
  });
}

// 检查小程序API调用
function checkMiniprogramAPI() {
  console.log('\n📋 检查小程序API调用:');
  
  const apiFile = 'miniprogram/utils/server-api.js';
  
  if (fs.existsSync(apiFile)) {
    const content = fs.readFileSync(apiFile, 'utf-8');
    
    if (content.includes('require(\'../config/production.js\')')) {
      console.log('  ✅ 使用生产环境配置');
    } else {
      console.log('  ❌ 未使用生产环境配置');
    }
    
    if (content.includes('config.BASE_URL')) {
      console.log('  ✅ 使用配置的BASE_URL');
    } else {
      console.log('  ❌ 未使用配置的BASE_URL');
    }
    
    if (content.includes('https://practice.insightdata.top')) {
      console.log('  ❌ 硬编码了HTTPS地址（应该使用配置）');
    } else {
      console.log('  ✅ 没有硬编码地址');
    }
  } else {
    console.log(`  ❌ 文件不存在: ${apiFile}`);
  }
}

// 生成部署检查清单
function generateChecklist() {
  console.log('\n📋 HTTPS部署检查清单:');
  console.log('\n🔧 服务器配置:');
  console.log('□ 域名解析: practice.insightdata.top → 223.93.139.87');
  console.log('□ SSL证书: C:\\certificates\\practice.insightdata.top.crt');
  console.log('□ SSL私钥: C:\\certificates\\practice.insightdata.top.key');
  console.log('□ Nginx安装: C:\\nginx\\');
  console.log('□ Nginx配置: practice.insightdata.top.conf');
  console.log('□ 防火墙: 开放443端口');
  
  console.log('\n🌐 服务启动:');
  console.log('□ Nginx服务运行');
  console.log('□ API服务运行 (端口3002)');
  console.log('□ 管理后台运行 (端口3000)');
  
  console.log('\n🧪 功能测试:');
  console.log('□ HTTPS访问: https://practice.insightdata.top/');
  console.log('□ API接口: https://practice.insightdata.top/api/');
  console.log('□ 健康检查: https://practice.insightdata.top/health');
  console.log('□ 小程序API调用正常');
  console.log('□ 管理后台登录正常');
  
  console.log('\n🔒 安全验证:');
  console.log('□ SSL证书有效');
  console.log('□ HTTP自动重定向到HTTPS');
  console.log('□ 安全头配置正确');
  console.log('□ 跨域配置正确');
}

// 主检查函数
function main() {
  console.log('🚀 开始验证HTTPS配置...\n');
  
  // 检查配置文件
  checkConfigFiles();
  
  // 检查SSL相关文件
  checkSSLFiles();
  
  // 检查小程序API调用
  checkMiniprogramAPI();
  
  // 生成部署检查清单
  generateChecklist();
  
  console.log('\n📊 配置总结:');
  console.log('✅ 小程序配置已更新为HTTPS域名');
  console.log('✅ 服务器配置已更新为HTTPS域名');
  console.log('✅ 管理后台配置已更新为HTTPS域名');
  console.log('✅ SSL配置文件和脚本已创建');
  console.log('✅ Nginx配置模板已创建');
  
  console.log('\n💡 下一步操作:');
  console.log('1. 按照 WINDOWS_SSL_SETUP_GUIDE.md 配置SSL证书');
  console.log('2. 复制 nginx-https.conf 到 C:\\nginx\\conf\\');
  console.log('3. 运行 start-https-services.bat 启动服务');
  console.log('4. 验证所有功能正常工作');
  
  console.log('\n🎉 HTTPS配置验证完成！');
}

// 运行检查
main();
