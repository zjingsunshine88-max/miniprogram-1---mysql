@echo off
chcp 65001 >nul
echo ========================================
echo Fix API Configuration
echo ========================================
echo.

echo [STEP 1] Check current API configuration
echo ========================================
echo [INFO] Checking admin API configuration files...

if exist "admin\src\api\admin.js" (
    echo [OK] admin.js exists
    echo [INFO] Current API URL in admin.js:
    findstr /i "VITE_SERVER_URL" "admin\src\api\admin.js"
    findstr /i "practice.insightdate.top" "admin\src\api\admin.js"
) else (
    echo [ERROR] admin.js not found
)

echo.
echo [INFO] Checking environment configuration...
if exist "admin\env.production" (
    echo [OK] env.production exists
    echo [INFO] Environment configuration:
    type admin\env.production
) else (
    echo [ERROR] env.production not found
)

echo.
echo [STEP 2] Update API configuration
echo ========================================
echo [INFO] Updating API configuration files...

:: Update admin.js
echo [INFO] Updating admin.js...
(
echo // 获取token
echo const getToken = () =^> {
echo   return localStorage.getItem('token'^)
echo }
echo.
echo // 服务器API基础URL
echo const getServerUrl = () =^> {
echo   return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdate.top'
echo }
echo.
echo // 调用服务器API
echo const callServerAPI = async (endpoint, options = {}^) =^> {
echo   const token = getToken(^)
echo   
echo   try {
echo     const response = await fetch(`$%{getServerUrl(^)}$%{endpoint}`, {
echo       method: options.method || 'GET',
echo       headers: {
echo         'Content-Type': 'application/json',
echo         'X-Requested-With': 'XMLHttpRequest',
echo         ...(token ^&^& { 'Authorization': `Bearer $%{token}` }^),
echo         ...options.headers
echo       },
echo       credentials: 'include',
echo       ...options
echo     }^)
echo.
echo     // 检查响应状态
echo     if (!response.ok^) {
echo       const errorData = await response.json(^).catch(() =^> ({}^)^)
echo       throw new Error(errorData.message || `HTTP $%{response.status}: $%{response.statusText}`^)
echo     }
echo.
echo     // 如果是blob响应，直接返回
echo     if (options.responseType === 'blob'^) {
echo       return response.blob(^)
echo     }
echo.
echo     const data = await response.json(^)
echo     
echo     // 检查业务逻辑错误
echo     if (data.code ^&^& data.code !== 200^) {
echo       throw new Error(data.message || '请求失败'^)
echo     }
echo     
echo     return data
echo   } catch (error^) {
echo     console.error('服务器API调用失败:', error^)
echo     throw error
echo   }
echo }
echo.
echo // 管理员相关API
echo export const adminAPI = {
echo   // 管理员登录
echo   login: (credentials^) =^> {
echo     return callServerAPI('/api/user/admin-login', {
echo       method: 'POST',
echo       body: JSON.stringify(credentials^)
echo     }^)
echo   },
echo.
echo   // 获取统计数据
echo   getStats: (^) =^> {
echo     return callServerAPI('/api/admin/stats'^)
echo   },
echo.
echo   // 获取用户列表
echo   getUsers: (params = {}^) =^> {
echo     const queryString = new URLSearchParams(params^).toString(^)
echo     return callServerAPI(`/api/user/stats?$%{queryString}`^)
echo   },
echo.
echo   // 获取题目列表
echo   getQuestions: (params = {}^) =^> {
echo     const queryString = new URLSearchParams(params^).toString(^)
echo     return callServerAPI(`/api/question/list?$%{queryString}`^)
echo   },
echo.
echo   // 添加题目
echo   addQuestion: (question^) =^> {
echo     return callServerAPI('/api/question/import', {
echo       method: 'POST',
echo       body: JSON.stringify({ questions: [question] }^)
echo     }^)
echo   },
echo.
echo   // 更新题目
echo   updateQuestion: (id, question^) =^> {
echo     return callServerAPI(`/api/question/detail/$%{id}`, {
echo       method: 'PUT',
echo       body: JSON.stringify(question^)
echo     }^)
echo   },
echo.
echo   // 删除题目
echo   deleteQuestion: (id^) =^> {
echo     return callServerAPI(`/api/question/detail/$%{id}`, {
echo       method: 'DELETE'
echo     }^)
echo   },
echo.
echo   // 批量删除题目
echo   batchDeleteQuestions: (questionIds^) =^> {
echo     return callServerAPI('/api/question/batch-delete', {
echo       method: 'POST',
echo       body: JSON.stringify({ questionIds }^)
echo     }^)
echo   },
echo.
echo   // 批量导入题目
echo   importQuestions: (questions^) =^> {
echo     return callServerAPI('/api/question/import', {
echo       method: 'POST',
echo       body: JSON.stringify({ questions }^)
echo     }^)
echo   },
echo.
echo   // 删除题库
echo   deleteQuestionBank: (subject^) =^> {
echo     return callServerAPI('/api/question/delete-bank', {
echo       method: 'POST',
echo       body: JSON.stringify({ subject }^)
echo     }^)
echo   },
echo.
echo   // 导出题库
echo   exportQuestionBank: (questionBankId, format = 'excel'^) =^> {
echo     return callServerAPI(`/api/question-bank/$%{questionBankId}/export?format=$%{format}`, {
echo       method: 'GET',
echo       responseType: 'blob'
echo     }^)
echo   }
echo }
echo.
echo export default adminAPI
) > "admin\src\api\admin.js"

echo [OK] Updated admin.js

:: Update other API files
echo [INFO] Updating other API files...

:: Update question.js
(
echo // 获取token
echo const getToken = () =^> {
echo   return localStorage.getItem('token'^)
echo }
echo.
echo // 服务器API基础URL
echo const getServerUrl = () =^> {
echo   return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdate.top'
echo }
echo.
echo // 调用服务器API
echo const callServerAPI = async (endpoint, options = {}^) =^> {
echo   const token = getToken(^)
echo   
echo   try {
echo     const response = await fetch(`$%{getServerUrl(^)}$%{endpoint}`, {
echo       method: options.method || 'GET',
echo       headers: {
echo         'Content-Type': 'application/json',
echo         'X-Requested-With': 'XMLHttpRequest',
echo         ...(token ^&^& { 'Authorization': `Bearer $%{token}` }^),
echo         ...options.headers
echo       },
echo       credentials: 'include',
echo       ...options
echo     }^)
echo.
echo     // 检查响应状态
echo     if (!response.ok^) {
echo       const errorData = await response.json(^).catch(() =^> ({}^)^)
echo       throw new Error(errorData.message || `HTTP $%{response.status}: $%{response.statusText}`^)
echo     }
echo.
echo     const data = await response.json(^)
echo     
echo     // 检查业务逻辑错误
echo     if (data.code ^&^& data.code !== 200^) {
echo       throw new Error(data.message || '请求失败'^)
echo     }
echo     
echo     return data
echo   } catch (error^) {
echo     console.error('服务器API调用失败:', error^)
echo     
echo     // 如果是CORS错误，提供更友好的错误信息
echo     if (error.message.includes('CORS'^) || error.message.includes('blocked'^)^) {
echo       throw new Error('跨域请求被阻止，请检查服务器CORS配置'^)
echo     }
echo     
echo     throw error
echo   }
echo }
echo.
echo // 题目相关API
echo export const questionAPI = {
echo   // 获取题目列表
echo   getList: (params = {}^) =^> {
echo     const queryString = new URLSearchParams(params^).toString(^)
echo     return callServerAPI(`/api/question/list?$%{queryString}`^)
echo   },
echo.
echo   // 获取题目详情
echo   getDetail: (id^) =^> {
echo     return callServerAPI(`/api/question/detail/$%{id}`^)
echo   },
echo.
echo   // 随机获取题目
echo   getRandom: (params = {}^) =^> {
echo     const queryString = new URLSearchParams(params^).toString(^)
echo     return callServerAPI(`/api/question/random?$%{queryString}`^)
echo   },
echo.
echo   // 批量导入题目
echo   importQuestions: (questions^) =^> {
echo     return callServerAPI('/api/question/import', {
echo       method: 'POST',
echo       body: JSON.stringify({ questions }^)
echo     }^)
echo   },
echo.
echo   // 获取题目统计
echo   getStats: (^) =^> {
echo     return callServerAPI('/api/question/stats'^)
echo   }
echo }
echo.
echo // 用户相关API
echo export const userAPI = {
echo   // 用户登录
echo   login: (credentials^) =^> {
echo     return callServerAPI('/api/user/login', {
echo       method: 'POST',
echo       body: JSON.stringify(credentials^)
echo     }^)
echo   },
echo.
echo   // 获取用户信息
echo   getUserInfo: (^) =^> {
echo     return callServerAPI('/api/user/info'^)
echo   }
echo }
echo.
echo export default {
echo   question: questionAPI,
echo   user: userAPI
echo }
) > "admin\src\api\question.js"

echo [OK] Updated question.js

:: Update user.js
(
echo // 获取token
echo const getToken = () =^> {
echo   return localStorage.getItem('token'^)
echo }
echo.
echo // 服务器API基础URL
echo const getServerUrl = () =^> {
echo   return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdate.top'
echo }
echo.
echo // 调用服务器API
echo const callServerAPI = async (endpoint, options = {}^) =^> {
echo   const token = getToken(^)
echo   
echo   try {
echo     const response = await fetch(`$%{getServerUrl(^)}$%{endpoint}`, {
echo       method: options.method || 'GET',
echo       headers: {
echo         'Content-Type': 'application/json',
echo         'X-Requested-With': 'XMLHttpRequest',
echo         ...(token ^&^& { 'Authorization': `Bearer $%{token}` }^),
echo         ...options.headers
echo       },
echo       credentials: 'include',
echo       ...options
echo     }^)
echo.
echo     // 检查响应状态
echo     if (!response.ok^) {
echo       const errorData = await response.json(^).catch(() =^> ({}^)^)
echo       throw new Error(errorData.message || `HTTP $%{response.status}: $%{response.statusText}`^)
echo     }
echo.
echo     const data = await response.json(^)
echo     
echo     // 检查业务逻辑错误
echo     if (data.code ^&^& data.code !== 200^) {
echo       throw new Error(data.message || '请求失败'^)
echo     }
echo     
echo     return data
echo   } catch (error^) {
echo     console.error('服务器API调用失败:', error^)
echo     throw error
echo   }
echo }
echo.
echo // 获取用户列表
echo export function getUserList(params^) {
echo   const queryString = new URLSearchParams(params^).toString(^)
echo   return callServerAPI(`/api/user/list?$%{queryString}`^)
echo }
echo.
echo // 创建用户
echo export function createUser(data^) {
echo   return callServerAPI('/api/user/create', {
echo     method: 'POST',
echo     body: JSON.stringify(data^)
echo   }^)
echo }
echo.
echo // 更新用户
echo export function updateUser(id, data^) {
echo   return callServerAPI(`/api/user/$%{id}`, {
echo     method: 'PUT',
echo     body: JSON.stringify(data^)
echo   }^)
echo }
echo.
echo // 删除用户
echo export function deleteUser(id^) {
echo   return callServerAPI(`/api/user/$%{id}`, {
echo     method: 'DELETE'
echo   }^)
echo }
echo.
echo // 重置用户密码
echo export function resetUserPassword(id, password^) {
echo   return callServerAPI(`/api/user/$%{id}/reset-password`, {
echo     method: 'POST',
echo     body: JSON.stringify({ password }^)
echo   }^)
echo }
) > "admin\src\api\user.js"

echo [OK] Updated user.js

echo.
echo [STEP 3] Rebuild admin project
echo ========================================
echo [INFO] Rebuilding admin project with correct API configuration...

cd admin
if exist "node_modules" (
    echo [OK] node_modules exists
) else (
    echo [INFO] Installing dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install dependencies
        cd ..
        pause
        exit /b 1
    )
)

echo [INFO] Building admin project...
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build admin project
    cd ..
    pause
    exit /b 1
)

echo [OK] Admin project built successfully
cd ..

echo.
echo [STEP 4] Deploy updated files
echo ========================================
echo [INFO] Deploying updated files to C:\admin...

if exist "admin\dist" (
    if exist "C:\admin" (
        echo [INFO] Clearing C:\admin directory...
        del /q "C:\admin\*" >nul 2>&1
    ) else (
        echo [INFO] Creating C:\admin directory...
        mkdir "C:\admin"
    )
    
    echo [INFO] Copying new files to C:\admin...
    xcopy "admin\dist\*" "C:\admin\" /E /Y /Q
    if %errorlevel% equ 0 (
        echo [OK] Files deployed successfully
    ) else (
        echo [ERROR] Failed to deploy files
    )
) else (
    echo [ERROR] admin\dist directory not found
)

echo.
echo [STEP 5] Clear browser cache
echo ========================================
echo [INFO] Please clear your browser cache and reload the page
echo [INFO] Or use Ctrl+F5 to force refresh
echo [INFO] Or open the page in an incognito/private window

echo.
echo ========================================
echo API Configuration Fix Complete
echo ========================================
echo.
echo Summary:
echo - Updated all API configuration files
echo - Rebuilt admin project
echo - Deployed updated files to C:\admin
echo.
echo Next steps:
echo 1. Clear browser cache (Ctrl+F5)
echo 2. Reload the admin page
echo 3. Check browser developer tools to verify API calls use https://practice.insightdate.top/api
echo.
echo Press any key to exit...
pause >nul
