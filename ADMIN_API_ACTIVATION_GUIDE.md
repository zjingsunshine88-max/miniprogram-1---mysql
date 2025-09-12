# Admin API云函数HTTP触发器激活指南

## 问题诊断

通过测试发现，admin-api云函数返回错误：
```
{
  code: 'HTTPSERVICE_NONACTIVATED',
  message: 'HTTPService is not activated'
}
```

这表明admin-api云函数的HTTP触发器服务没有激活。

## 解决方案

### 第一步：激活HTTP触发器服务

#### 方法一：通过微信开发者工具

1. **打开微信开发者工具**
   - 打开您的项目
   - 确保已登录微信开发者账号

2. **进入云开发控制台**
   - 点击工具栏中的"云开发"按钮
   - 或直接访问 [微信云开发控制台](https://console.cloud.tencent.com/tcb)

3. **找到admin-api云函数**
   - 在左侧菜单点击"云函数"
   - 找到 `admin-api` 云函数
   - 点击进入详情页

4. **配置HTTP触发器**
   - 在云函数详情页中，点击"触发器"选项卡
   - 如果没有看到"触发器"选项卡，说明HTTP服务未激活
   - 点击"添加触发器"或"开通HTTP触发器"

5. **设置触发器参数**
   - 触发方式：HTTP
   - 访问路径：`/admin-api`
   - 请求方法：POST
   - 认证方式：无认证

6. **获取触发器URL**
   - 配置完成后，系统会生成触发器URL
   - 格式：`https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/admin-api`
   - 记录此URL

#### 方法二：通过云开发控制台

1. **访问云开发控制台**
   - 打开 [微信云开发控制台](https://console.cloud.tencent.com/tcb)
   - 选择您的云开发环境

2. **进入云函数管理**
   - 点击左侧菜单"云函数"
   - 找到 `admin-api` 云函数

3. **配置触发器**
   - 点击云函数名称进入详情
   - 点击"触发器"选项卡
   - 点击"添加触发器"
   - 选择"HTTP触发器"
   - 配置访问路径为 `/admin-api`

### 第二步：重新部署云函数

1. **在微信开发者工具中**
   - 右键点击 `cloudfunctions/admin-api` 文件夹
   - 选择"上传并部署：云端安装依赖"

2. **等待部署完成**
   - 部署过程可能需要几分钟
   - 确保没有错误信息

### 第三步：验证触发器激活

1. **检查触发器状态**
   - 在云函数详情页查看"触发器"选项卡
   - 确认HTTP触发器显示为"已激活"状态

2. **测试触发器URL**
   - 使用浏览器或Postman访问触发器URL
   - 应该返回云函数的响应

### 第四步：更新配置

1. **确认触发器URL**
   - 在云函数详情页复制完整的触发器URL
   - 格式：`https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/admin-api`

2. **更新admin系统配置**
   - 确认 `admin/src/api/admin.js` 中的URL正确
   - 如果需要，更新URL

### 第五步：测试登录功能

1. **清除浏览器缓存**
   - 按F12打开开发者工具
   - 右键点击刷新按钮，选择"清空缓存并硬性重新加载"

2. **测试登录**
   - 访问静态托管域名
   - 使用管理员账号登录：
     - 用户名：admin
     - 密码：123456

3. **检查控制台**
   - 查看浏览器控制台是否有错误
   - 查看云函数执行日志

## 常见问题

### 1. 找不到"触发器"选项卡
**原因**：HTTP触发器服务未激活
**解决**：
- 联系微信云开发客服激活HTTP触发器服务
- 或使用云开发CLI工具配置

### 2. 触发器配置失败
**原因**：云函数代码有语法错误
**解决**：
- 检查云函数代码
- 重新部署云函数
- 查看云函数日志

### 3. 触发器URL无法访问
**原因**：触发器未正确配置
**解决**：
- 检查触发器配置
- 确认访问路径正确
- 重新部署云函数

## 验证步骤

### 1. 运行测试脚本
```bash
node test-admin-api.js
```

### 2. 检查响应
应该看到类似以下的成功响应：
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "admin_token_xxx",
    "adminInfo": {
      "id": "xxx",
      "username": "admin",
      "role": "admin"
    }
  }
}
```

### 3. 检查CORS配置
确保响应头包含正确的CORS配置：
```
Access-Control-Allow-Origin: https://cloudbase-5guq06yfe657e091-1371481450.tcloudbaseapp.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
```

## 总结

解决步骤：
1. ✅ 激活admin-api云函数的HTTP触发器
2. ✅ 重新部署云函数
3. ✅ 验证触发器URL可访问
4. ✅ 测试登录功能

完成这些步骤后，admin系统的登录功能应该能够正常工作。
