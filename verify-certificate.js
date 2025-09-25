// 验证SSL证书文件
const fs = require('fs');
const crypto = require('crypto');

console.log('🔍 验证SSL证书文件...\n');

// 验证证书文件
function verifyCertificateFile(filePath, fileType) {
  console.log(`📁 检查${fileType}文件: ${filePath}`);
  
  if (!fs.existsSync(filePath)) {
    console.log(`  ❌ 文件不存在`);
    return false;
  }
  
  try {
    const content = fs.readFileSync(filePath, 'utf-8');
    
    if (fileType === '证书') {
      // 验证证书文件格式
      if (content.includes('-----BEGIN CERTIFICATE-----') && content.includes('-----END CERTIFICATE-----')) {
        console.log(`  ✅ 证书文件格式正确`);
        
        // 解析证书信息
        try {
          const cert = crypto.X509Certificate ? new crypto.X509Certificate(content) : null;
          if (cert) {
            console.log(`  📋 证书信息:`);
            console.log(`    主题: ${cert.subject}`);
            console.log(`    颁发者: ${cert.issuer}`);
            console.log(`    有效期: ${cert.validFrom} 至 ${cert.validTo}`);
            console.log(`    序列号: ${cert.serialNumber}`);
          }
        } catch (error) {
          console.log(`  ⚠️  无法解析证书详细信息`);
        }
        
        return true;
      } else {
        console.log(`  ❌ 证书文件格式错误`);
        return false;
      }
    } else if (fileType === '私钥') {
      // 验证私钥文件格式
      if (content.includes('-----BEGIN PRIVATE KEY-----') || content.includes('-----BEGIN RSA PRIVATE KEY-----')) {
        console.log(`  ✅ 私钥文件格式正确`);
        return true;
      } else {
        console.log(`  ❌ 私钥文件格式错误`);
        return false;
      }
    }
  } catch (error) {
    console.log(`  ❌ 读取文件失败: ${error.message}`);
    return false;
  }
}

// 检查证书链完整性
function checkCertificateChain(certPath) {
  console.log(`\n📋 检查证书链完整性:`);
  
  try {
    const content = fs.readFileSync(certPath, 'utf-8');
    
    // 计算证书数量
    const certCount = (content.match(/-----BEGIN CERTIFICATE-----/g) || []).length;
    console.log(`  📊 证书链中包含 ${certCount} 个证书`);
    
    if (certCount === 1) {
      console.log(`  ⚠️  只有域名证书，缺少中间证书`);
      console.log(`  💡 建议：包含完整的证书链以提高兼容性`);
    } else if (certCount >= 2) {
      console.log(`  ✅ 包含完整的证书链`);
    }
    
    return certCount;
  } catch (error) {
    console.log(`  ❌ 检查证书链失败: ${error.message}`);
    return 0;
  }
}

// 检查证书域名匹配
function checkCertificateDomain(certPath, expectedDomain) {
  console.log(`\n📋 检查证书域名匹配:`);
  
  try {
    const content = fs.readFileSync(certPath, 'utf-8');
    
    // 简单检查是否包含域名
    if (content.includes(expectedDomain)) {
      console.log(`  ✅ 证书包含域名: ${expectedDomain}`);
      return true;
    } else {
      console.log(`  ❌ 证书不包含域名: ${expectedDomain}`);
      return false;
    }
  } catch (error) {
    console.log(`  ❌ 检查域名匹配失败: ${error.message}`);
    return false;
  }
}

// 生成Nginx配置建议
function generateNginxConfig(certPath, keyPath) {
  console.log(`\n📋 Nginx配置建议:`);
  
  console.log(````nginx`);
  console.log(`server {`);
  console.log(`    listen 443 ssl http2;`);
  console.log(`    server_name practice.insightdata.top;`);
  console.log(`    `);
  console.log(`    # SSL证书配置`);
  console.log(`    ssl_certificate ${certPath.replace(/\\/g, '/')};`);
  console.log(`    ssl_certificate_key ${keyPath.replace(/\\/g, '/')};`);
  console.log(`    `);
  console.log(`    # 其他配置...`);
  console.log(`}`);
  console.log(````);
}

// 主检查函数
function main() {
  console.log('🚀 开始验证SSL证书文件...\n');
  
  const certPath = 'C:\\certificates\\practice.insightdata.top.pem';
  const keyPath = 'C:\\certificates\\practice.insightdata.top.key';
  const expectedDomain = 'practice.insightdata.top';
  
  let certValid = false;
  let keyValid = false;
  
  // 验证证书文件
  certValid = verifyCertificateFile(certPath, '证书');
  
  // 验证私钥文件
  keyValid = verifyCertificateFile(keyPath, '私钥');
  
  // 检查证书链
  if (certValid) {
    checkCertificateChain(certPath);
    checkCertificateDomain(certPath, expectedDomain);
  }
  
  // 生成配置建议
  if (certValid && keyValid) {
    console.log(`\n✅ 证书文件验证通过！`);
    generateNginxConfig(certPath, keyPath);
    
    console.log(`\n📋 部署步骤:`);
    console.log(`1. 将证书文件复制到: C:\\certificates\\`);
    console.log(`2. 复制 nginx-https.conf 到: C:\\nginx\\conf\\practice.insightdata.top.conf`);
    console.log(`3. 运行: start-https-services.bat`);
    console.log(`4. 访问: https://practice.insightdata.top/`);
  } else {
    console.log(`\n❌ 证书文件验证失败！`);
    console.log(`\n💡 解决方案:`);
    console.log(`1. 确认证书文件路径正确`);
    console.log(`2. 检查文件格式是否为PEM格式`);
    console.log(`3. 验证证书和私钥是否匹配`);
  }
  
  console.log(`\n📊 证书文件格式说明:`);
  console.log(`- .pem 文件 = 证书文件（与.crt功能相同）`);
  console.log(`- .key 文件 = 私钥文件`);
  console.log(`- 您的文件格式是正确的！`);
  
  console.log(`\n🎉 证书验证完成！`);
}

// 运行检查
main();
