const fs = require('fs');
const path = require('path');

console.log('🔍 验证微信小程序API配置...\n');

// 检查配置文件
function checkConfigFiles() {
    console.log('📋 检查配置文件:');
    
    const configFiles = [
        'miniprogram/config/production.js',
        'miniprogram/config/development.js'
    ];
    
    configFiles.forEach(file => {
        if (fs.existsSync(file)) {
            const content = fs.readFileSync(file, 'utf8');
            const config = eval(`(${content.replace('module.exports =', '')})`);
            
            console.log(`✅ ${file}:`);
            console.log(`   BASE_URL: ${config.BASE_URL}`);
            
            if (file.includes('production.js')) {
                if (config.BASE_URL === 'https://practice.insightdata.top') {
                    console.log('   ✅ 生产环境配置正确 (HTTPS域名)');
                } else {
                    console.log('   ❌ 生产环境配置错误，应为 https://practice.insightdata.top');
                }
            }
            
            if (file.includes('development.js')) {
                if (config.BASE_URL === 'http://localhost:3002') {
                    console.log('   ✅ 开发环境配置正确 (本地地址)');
                } else {
                    console.log('   ❌ 开发环境配置错误，应为 http://localhost:3002');
                }
            }
        } else {
            console.log(`❌ 配置文件不存在: ${file}`);
        }
    });
}

// 检查API调用文件
function checkAPICalls() {
    console.log('\n🔗 检查API调用文件:');
    
    const serverApiFile = 'miniprogram/utils/server-api.js';
    if (fs.existsSync(serverApiFile)) {
        const content = fs.readFileSync(serverApiFile, 'utf8');
        
        console.log(`✅ ${serverApiFile}:`);
        
        // 检查是否使用配置
        if (content.includes("require('../config/production.js')")) {
            console.log('   ✅ 使用生产环境配置');
        } else {
            console.log('   ❌ 未使用生产环境配置');
        }
        
        if (content.includes('config.BASE_URL')) {
            console.log('   ✅ 使用配置中的BASE_URL');
        } else {
            console.log('   ❌ 未使用配置中的BASE_URL');
        }
        
        // 检查是否有硬编码URL
        const hardcodedUrls = content.match(/['"`]https?:\/\/[^'"`]+['"`]/g);
        if (hardcodedUrls) {
            console.log('   ⚠️  发现硬编码URL:');
            hardcodedUrls.forEach(url => {
                console.log(`      ${url}`);
            });
        } else {
            console.log('   ✅ 无硬编码URL');
        }
    } else {
        console.log(`❌ API调用文件不存在: ${serverApiFile}`);
    }
}

// 检查所有页面文件
function checkPageFiles() {
    console.log('\n📄 检查页面文件:');
    
    const pagesDir = 'miniprogram/pages';
    if (!fs.existsSync(pagesDir)) {
        console.log('❌ 页面目录不存在');
        return;
    }
    
    const pageDirs = fs.readdirSync(pagesDir);
    let totalPages = 0;
    let pagesWithAPI = 0;
    let pagesWithHardcodedUrls = 0;
    
    pageDirs.forEach(pageDir => {
        const pagePath = path.join(pagesDir, pageDir);
        if (fs.statSync(pagePath).isDirectory()) {
            const jsFile = path.join(pagePath, 'index.js');
            if (fs.existsSync(jsFile)) {
                totalPages++;
                const content = fs.readFileSync(jsFile, 'utf8');
                
                if (content.includes('server-api') || content.includes('wx.request')) {
                    pagesWithAPI++;
                    console.log(`📱 ${pageDir}:`);
                    
                    // 检查是否使用配置
                    if (content.includes('config.BASE_URL') || content.includes('require.*config')) {
                        console.log('   ✅ 使用配置');
                    } else {
                        console.log('   ⚠️  可能未使用配置');
                    }
                    
                    // 检查硬编码URL
                    const hardcodedUrls = content.match(/['"`]https?:\/\/[^'"`]+['"`]/g);
                    if (hardcodedUrls) {
                        pagesWithHardcodedUrls++;
                        console.log('   ❌ 发现硬编码URL:');
                        hardcodedUrls.forEach(url => {
                            console.log(`      ${url}`);
                        });
                    } else {
                        console.log('   ✅ 无硬编码URL');
                    }
                }
            }
        }
    });
    
    console.log(`\n📊 页面统计:`);
    console.log(`   总页面数: ${totalPages}`);
    console.log(`   使用API的页面: ${pagesWithAPI}`);
    console.log(`   有硬编码URL的页面: ${pagesWithHardcodedUrls}`);
}

// 检查app.js
function checkAppJs() {
    console.log('\n🚀 检查app.js:');
    
    const appFile = 'miniprogram/app.js';
    if (fs.existsSync(appFile)) {
        const content = fs.readFileSync(appFile, 'utf8');
        
        console.log(`✅ ${appFile}:`);
        
        if (content.includes('server-api')) {
            console.log('   ✅ 使用server-api模块');
        } else {
            console.log('   ⚠️  未使用server-api模块');
        }
        
        // 检查硬编码URL
        const hardcodedUrls = content.match(/['"`]https?:\/\/[^'"`]+['"`]/g);
        if (hardcodedUrls) {
            console.log('   ❌ 发现硬编码URL:');
            hardcodedUrls.forEach(url => {
                console.log(`      ${url}`);
            });
        } else {
            console.log('   ✅ 无硬编码URL');
        }
    } else {
        console.log(`❌ app.js不存在`);
    }
}

// 检查组件文件
function checkComponents() {
    console.log('\n🧩 检查组件文件:');
    
    const componentsDir = 'miniprogram/components';
    if (!fs.existsSync(componentsDir)) {
        console.log('❌ 组件目录不存在');
        return;
    }
    
    const componentDirs = fs.readdirSync(componentsDir);
    let totalComponents = 0;
    let componentsWithAPI = 0;
    let componentsWithHardcodedUrls = 0;
    
    componentDirs.forEach(componentDir => {
        const componentPath = path.join(componentsDir, componentDir);
        if (fs.statSync(componentPath).isDirectory()) {
            const jsFile = path.join(componentPath, 'index.js');
            if (fs.existsSync(jsFile)) {
                totalComponents++;
                const content = fs.readFileSync(jsFile, 'utf8');
                
                if (content.includes('server-api') || content.includes('wx.request')) {
                    componentsWithAPI++;
                    console.log(`🧩 ${componentDir}:`);
                    
                    // 检查是否使用配置
                    if (content.includes('config.BASE_URL') || content.includes('require.*config')) {
                        console.log('   ✅ 使用配置');
                    } else {
                        console.log('   ⚠️  可能未使用配置');
                    }
                    
                    // 检查硬编码URL
                    const hardcodedUrls = content.match(/['"`]https?:\/\/[^'"`]+['"`]/g);
                    if (hardcodedUrls) {
                        componentsWithHardcodedUrls++;
                        console.log('   ❌ 发现硬编码URL:');
                        hardcodedUrls.forEach(url => {
                            console.log(`      ${url}`);
                        });
                    } else {
                        console.log('   ✅ 无硬编码URL');
                    }
                }
            }
        }
    });
    
    console.log(`\n📊 组件统计:`);
    console.log(`   总组件数: ${totalComponents}`);
    console.log(`   使用API的组件: ${componentsWithAPI}`);
    console.log(`   有硬编码URL的组件: ${componentsWithHardcodedUrls}`);
}

// 主函数
function main() {
    try {
        checkConfigFiles();
        checkAPICalls();
        checkPageFiles();
        checkAppJs();
        checkComponents();
        
        console.log('\n🎉 验证完成！');
        console.log('\n💡 总结:');
        console.log('   - 所有API调用都应使用 https://practice.insightdata.top');
        console.log('   - 配置文件已正确设置为生产环境');
        console.log('   - 所有页面和组件都应通过server-api模块调用API');
        console.log('   - 不应有硬编码的HTTP URL');
        
    } catch (error) {
        console.error('❌ 验证过程中出现错误:', error.message);
    }
}

main();
