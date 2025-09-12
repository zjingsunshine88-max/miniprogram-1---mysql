# Admin 云函数配置说明

## 环境变量配置

在 `admin` 目录下创建以下环境变量文件：

### 开发环境 (.env.development)

```bash
# 云开发环境ID
VITE_CLOUD_ENV_ID=your-env-id

# 云函数HTTP触发器URL
VITE_CLOUD_FUNCTION_URL=https://your-env-id.service.tcloudbase.com/question-bank-api
```

### 生产环境 (.env.production)

```bash
# 云开发环境ID
VITE_CLOUD_ENV_ID=your-env-id

# 云函数HTTP触发器URL
VITE_CLOUD_FUNCTION_URL=https://your-env-id.service.tcloudbase.com/question-bank-api
```

## 配置步骤

1. **获取云开发环境ID**
   - 在微信开发者工具中打开云开发控制台
   - 复制环境ID

2. **配置云函数HTTP触发器**
   - 在云开发控制台中找到 `question-bank-api` 云函数
   - 在"触发器"选项卡中添加HTTP触发器
   - 复制HTTP触发器URL

3. **更新环境变量**
   - 将实际的云开发环境ID和HTTP触发器URL填入环境变量文件

4. **重启开发服务器**
   ```bash
   npm run dev
   ```

## 测试配置

启动开发服务器后，可以测试以下功能：

1. 用户登录
2. 题库导入
3. 题目列表查看
4. 统计信息显示

## 注意事项

- 确保云函数已正确部署
- 检查HTTP触发器配置
- 验证CORS设置
- 确认网络连接正常
